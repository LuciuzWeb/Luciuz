# ACME (Let's Encrypt)

Luciuz can automatically obtain and renew TLS certificates using Let's Encrypt via `rustls-acme`.

## Required config
```toml
[acme]
enabled = true
prod = true
email = "you@example.com"
domains = ["example.com","www.example.com"]
cache_dir = "/var/lib/luciuz/acme"
challenge = "http-01" # or "tls-alpn-01"
```

## Challenge modes
### `http-01`
- Requires port 80.
- Luciuz serves `/.well-known/acme-challenge/...` and redirects everything else to HTTPS.

### `tls-alpn-01`
- Challenges are handled on port 443 during the TLS handshake.
- Port 80 can be left as "redirect only"; roadmap v1 adds optional 443-only mode.

## 443-only mode (TLS-ALPN-01)

Luciuz can run in **443-only** mode (no HTTP listener on port 80) when ACME uses **TLS-ALPN-01**.
This is useful if you want to eliminate port 80 entirely and keep the attack surface smaller.

### When to use TLS-ALPN-01
Use `tls-alpn-01` when:
- you want a **HTTPS-only** server (port 443 only)
- you do not want to expose the HTTP-01 challenge endpoint on port 80

Keep using `http-01` when:
- you prefer the simplest and most common ACME flow
- you want automatic validation via `/.well-known/acme-challenge/...` on port 80

### How to enable 443-only
1) Set ACME challenge mode to `tls-alpn-01`:
```toml
[acme]
enabled = true
challenge = "tls-alpn-01"

## Staging vs production
- `prod = false` uses Let's Encrypt staging (recommended while testing).
- Switch to `prod = true` once configuration is stable.

## Filesystem permissions
- `cache_dir` must be writable by the Luciuz service user.
- If you use a hardened systemd unit, allow writes to `cache_dir` (e.g. `ReadWritePaths=/var/lib/luciuz`).

## Troubleshooting
- If certificate issuance fails, check logs: `journalctl -u luciuz -f`.
- Verify DNS points to the correct server.
- Ensure firewall allows 80/443 as required by your chosen challenge.
