<p align="center">
  <img src="../../assets/logo/luciuz-logo-256.png" alt="Luciuz logo" width="160" />
</p>

# Quickstart

This is the shortest path to a working Luciuz instance.

## 1) Build

```bash
cargo build -p luciuz --release
```

Binary path:
- `./target/release/luciuz`

## 2) Configure

Edit `luciuz.toml`:

```toml
[server]
http_listen = "0.0.0.0:80"
https_listen = "0.0.0.0:443"
canonical_host = "luciuz.com"   # optional
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
challenge = "http-01"  # or "tls-alpn-01"
```

Validate:

```bash
./target/release/luciuz check -c luciuz.toml
```

## 3) Run

```bash
./target/release/luciuz run -c luciuz.toml
```

Test:

```bash
curl -I https://luciuz.com/healthz
curl -I http://www.luciuz.com/healthz
```

## 4) Run as a service (systemd)

See: `systemd.md`.
