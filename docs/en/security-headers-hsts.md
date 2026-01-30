# Security headers & HSTS

## Baseline headers
When enabled, Luciuz sets a small baseline on HTTPS responses.

- `X-Content-Type-Options: nosniff`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `X-Frame-Options: DENY`
- `Cross-Origin-Opener-Policy: same-origin`
- `Cross-Origin-Resource-Policy: same-site`

## HSTS (Strict-Transport-Security)
HSTS instructs browsers to only use HTTPS for your domain.

Config keys:
```toml
[server]
hsts = true
hsts_max_age = 86400
hsts_include_subdomains = false
hsts_preload = false
```

### Recommended rollout
1) Start at 1 day
2) Increase to 1 week
3) Increase to 1 month
4) Only add `includeSubDomains` and `preload` once you're fully confident
