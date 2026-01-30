# Configuration

Luciuz uses a TOML configuration file (commonly `luciuz.toml`).

## Minimal HTTPS + ACME

```toml
[server]
http_listen = "0.0.0.0:80"
https_listen = "0.0.0.0:443"

# Optional canonical host (recommended when you serve a single domain)
# - redirects https://www.<domain> → https://<domain>
# - rejects unknown hosts instead of redirecting them
canonical_host = "luciuz.com"

# HTTPS-only security headers
security_headers = true

# HSTS is powerful; start low, increase later
hsts = true
hsts_max_age = 86400
hsts_include_subdomains = false
hsts_preload = false

[timeouts]
# Max time allowed for a request handler to produce a response
handler_secs = 30

[acme]
enabled = true
prod = false
email = "admin@example.com"
domains = ["example.com", "www.example.com"]
cache_dir = "/var/lib/luciuz/acme"

# `http-01` (needs port 80 for ACME challenge)
# `tls-alpn-01` (ACME on 443; can enable 443-only setups)
challenge = "http-01"
```

Validate your file:

```bash
luciuz check -c luciuz.toml
```

## ACME modes
- **http-01**: port 80 serves `/.well-known/acme-challenge/...` + redirects everything else.
- **tls-alpn-01**: ACME challenges are handled on port 443 during TLS handshake.

See: `acme.md`.

## 443-only (roadmap v1)
When `acme.challenge = "tls-alpn-01"`, Luciuz can optionally run without binding port 80.

The general migration pattern:
1) Switch to `tls-alpn-01`.
2) Verify renewals work over 443.
3) Disable port 80 in config/firewall.

(Implementation details live in the roadmap until the flag is fully wired.)
