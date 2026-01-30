<div align="center">

<p align="center">
  <img src="assets/logo/luciuz-logo-256.png" alt="Luciuz logo" width="180" />
</p>
### Secure-by-default web server & reverse proxy with built-in observability and ACME HTTPS

</div>

## What is Luciuz?
Luciuz is a next-generation web server / reverse proxy written in Rust, designed around:
- **Security by default**: hardened defaults, strict host handling, minimal attack surface.
- **Observability by default**: operator-friendly logs and key lifecycle events.
- **Built-in HTTPS**: Let's Encrypt ACME with no external certbot service.

Luciuz targets the same problem space as Nginx or Caddy, with a roadmap for safe extensibility via Wasm.

## Status
Early development (v0.1). Current MVP includes:
- HTTP :80 minimal (ACME HTTP-01 challenge + redirect only)
- HTTPS :443 service
- `/healthz` endpoint
- Canonical host support (www → apex)
- Baseline security headers on HTTPS

## Quick start (local)
```bash
cargo build -p luciuz --release
./target/release/luciuz check -c luciuz.toml
./target/release/luciuz run -c luciuz.toml
```

## Minimal configuration
`luciuz.toml`:

```toml
[server]
http_listen = "0.0.0.0:80"
https_listen = "0.0.0.0:443"
canonical_host = "example.com"        # optional
security_headers = true
hsts = true
hsts_max_age = 86400

[timeouts]
handler_secs = 30

[acme]
enabled = true
prod = false
email = "admin@example.com"
domains = ["example.com", "www.example.com"]
cache_dir = "/var/lib/luciuz/acme"
challenge = "http-01"  # or "tls-alpn-01"
```

## Run in production (systemd)
See `docs/en/systemd.md` (or `docs/fr/systemd.md`).

## Documentation
- Docs index: `docs/README.md`
- English overview: `docs/en/overview.md`
- Français (aperçu) : `docs/fr/overview.md`

## Community vs Pro
Luciuz is developed as:
- **Community (public repo)**: the full core server (secure + observable defaults).
- **Pro (private crate)**: commercial advanced modules/integrations.

## Security
Please report vulnerabilities privately.
See `SECURITY.md`.

## License
Apache-2.0. See `LICENSE`.
