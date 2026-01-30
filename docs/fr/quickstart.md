<p align="center">
  <img src="../../assets/logo/luciuz-logo-256.png" alt="Logo Luciuz" width="160" />
</p>

# Démarrage rapide

Voici le chemin le plus court pour lancer Luciuz.

## 1) Compiler

```bash
cargo build -p luciuz --release
```

Binaire :
- `./target/release/luciuz`

## 2) Configurer

Édite `luciuz.toml` :

```toml
[server]
http_listen = "0.0.0.0:80"
https_listen = "0.0.0.0:443"
canonical_host = "luciuz.com"   # optionnel
security_headers = true
hsts = true
hsts_max_age = 86400

[timeouts]
handler_secs = 30

[acme]
enabled = true
prod = true
email = "you@example.com"
domains = ["luciuz.com","www.luciuz.com"]
cache_dir = "/var/lib/luciuz/acme"
challenge = "http-01"  # ou "tls-alpn-01"
```

Valider :

```bash
./target/release/luciuz check -c luciuz.toml
```

## 3) Lancer

```bash
./target/release/luciuz run -c luciuz.toml
```

Tester :

```bash
curl -I https://luciuz.com/healthz
curl -I http://www.luciuz.com/healthz
```

## 4) Lancer comme service (systemd)

Voir : `systemd.md`.
