use std::net::SocketAddr;

use axum::{
    body::Body,
    extract::State,
    http::{header::{HOST, STRICT_TRANSPORT_SECURITY}, HeaderMap, HeaderValue, Request, Uri},
    middleware::{from_fn_with_state, Next},
    response::{IntoResponse, Redirect, Response},
    routing::get,
    Router,
};
use clap::{Parser, Subcommand};
use tracing::{info, warn};

#[derive(Parser, Debug)]
#[command(name = "luciuz", version, about = "Luciuz web server (next-gen)")]
struct Cli {
    #[command(subcommand)]
    cmd: Command,
}

#[derive(Subcommand, Debug)]
enum Command {
    /// Validate config and print key effective values
    Check {
        #[arg(short, long, default_value = "luciuz.toml")]
        config: String,
    },
    /// Run server
    Run {
        #[arg(short, long, default_value = "luciuz.toml")]
        config: String,
    },
}

#[tokio::main]
async fn main() -> Result<(), anyhow::Error> {
    let cli = Cli::parse();

    match cli.cmd {
        Command::Check { config } => {
            let cfg = luciuz_config::load_from_path(&config).map_err(|e| anyhow::anyhow!(e))?;
            luciuz_telemetry::init(&cfg);

            info!("config ok");
            info!(
                http_listen = %cfg.server.http_listen,
                https_listen = %cfg.server.https_listen,
                profile = %cfg.server.profile,
                acme_enabled = cfg.acme.enabled,
                acme_prod = cfg.acme.prod,
                acme_domains = ?cfg.acme.domains,
                acme_cache_dir = %cfg.acme.cache_dir,
                "effective config"
            );
            Ok(())
        }
        Command::Run { config } => {
            let cfg = luciuz_config::load_from_path(&config).map_err(|e| anyhow::anyhow!(e))?;
            luciuz_telemetry::init(&cfg);

            let http_addr: SocketAddr = cfg.server.http_listen.parse()?;
            let https_addr: SocketAddr = cfg.server.https_listen.parse()?;

            let app = Router::new()
                .route("/healthz", get(|| async { "ok" }))
                .route("/", get(|| async { "luciuz: running" }));

            info!(
                http_listen = %cfg.server.http_listen,
                https_listen = %cfg.server.https_listen,
                profile = %cfg.server.profile,
                acme_enabled = cfg.acme.enabled,
                "starting luciuz"
            );

            if cfg.acme.enabled {
                run_https_with_acme_http01(cfg, http_addr, https_addr, app).await?;
            } else {
                // Plain HTTP only (dev mode / debugging).
                let listener = tokio::net::TcpListener::bind(http_addr).await?;
                axum::serve(listener, app).await?;
            }

            warn!("server stopped");
            Ok(())
        }
    }
}

#[derive(Clone)]
struct CanonicalHost(String);

async fn canonical_host_mw(
    State(state): State<CanonicalHost>,
    req: Request<Body>,
    next: Next,
) -> Response {
    let canonical = state.0.as_str();

    // Host header (strip optional port)
    let host = req
        .headers()
        .get(HOST)
        .and_then(|v| v.to_str().ok())
        .map(|s| s.split(':').next().unwrap_or(s));

    if let Some(host) = host {
        if host != canonical {
            let path = req
                .uri()
                .path_and_query()
                .map(|pq| pq.as_str())
                .unwrap_or(req.uri().path());

            let target = format!("https://{canonical}{path}");
            return Redirect::permanent(&target).into_response();
        }
    }

    next.run(req).await
}

#[derive(Clone)]
struct HstsState {
    value: HeaderValue,
}

async fn hsts_mw(
    State(state): State<HstsState>,
    req: Request<Body>,
    next: Next,
) -> Response {
    let mut res = next.run(req).await;
    res.headers_mut().insert(STRICT_TRANSPORT_SECURITY, state.value.clone());
    res
}

#[derive(Clone)]
struct RedirectState {
    canonical_host: Option<String>,
}

async fn run_https_with_acme_http01(
    cfg: luciuz_config::Config,
    http_addr: SocketAddr,
    https_addr: SocketAddr,
    https_app: Router,
) -> Result<(), anyhow::Error> {
    use axum_server::bind;
    use rustls_acme::caches::DirCache;
    use rustls_acme::tower::TowerHttp01ChallengeService;
    use rustls_acme::AcmeConfig;
    use rustls_acme::UseChallenge::Http01;
    use tokio_stream::StreamExt;

    // --- ACME state
    let mut state = AcmeConfig::new(cfg.acme.domains.clone())
        .contact_push(format!("mailto:{}", cfg.acme.email))
        .cache(DirCache::new(cfg.acme.cache_dir))
        .directory_lets_encrypt(cfg.acme.prod)
        .challenge_type(Http01)
        .state();

    // Rustls acceptor for axum-server.
    let acceptor = state.axum_acceptor(state.default_rustls_config());

    // Tower service that serves /.well-known/acme-challenge/<token>
    let acme_challenge_service: TowerHttp01ChallengeService = state.http01_challenge_tower_service();

    // Log ACME events in the background.
    tokio::spawn(async move {
        loop {
            match state.next().await {
                Some(Ok(evt)) => tracing::info!(?evt, "acme event"),
                Some(Err(err)) => tracing::error!(?err, "acme error"),
                None => break,
            }
        }
    });

    let canonical = cfg.server.canonical_host.clone();

    // --- HTTPS: apply canonical host redirect (www -> apex)
    let https_app = if let Some(ch) = canonical.clone() {
        https_app.layer(from_fn_with_state(CanonicalHost(ch), canonical_host_mw))
    } else {
        https_app
    };

    // --- HTTPS: HSTS (HTTPS only)
    let https_app = if cfg.server.hsts {
        let mut v = format!("max-age={}", cfg.server.hsts_max_age);
        if cfg.server.hsts_include_subdomains {
            v.push_str("; includeSubDomains");
        }
        if cfg.server.hsts_preload {
            v.push_str("; preload");
        }

        let hv = HeaderValue::from_str(&v)
            .map_err(|_| anyhow::anyhow!("invalid HSTS header value"))?;

        https_app.layer(from_fn_with_state(HstsState { value: hv }, hsts_mw))
    } else {
        https_app
    };

    // --- HTTP: ACME challenge + redirect only
    let http_app = Router::new()
        .route_service(
            "/.well-known/acme-challenge/{challenge_token}",
            acme_challenge_service,
        )
        .fallback(get(http_to_https_redirect))
        .with_state(RedirectState {
            canonical_host: canonical,
        });

    // --- Servers
    let http_future = bind(http_addr).serve(http_app.into_make_service());
    let https_future = bind(https_addr)
        .acceptor(acceptor)
        .serve(https_app.into_make_service());

    tokio::try_join!(https_future, http_future)?;
    Ok(())
}

async fn http_to_https_redirect(
    State(state): State<RedirectState>,
    uri: Uri,
    headers: HeaderMap,
) -> Redirect {
    let host = headers
        .get(HOST)
        .and_then(|v| v.to_str().ok())
        .map(|s| s.split(':').next().unwrap_or(s))
        .unwrap_or("luciuz.com");

    let path = uri
        .path_and_query()
        .map(|pq| pq.as_str())
        .unwrap_or(uri.path());

    let target_host = state.canonical_host.as_deref().unwrap_or(host);

    let target = format!("https://{target_host}{path}");
    Redirect::permanent(&target)
}
