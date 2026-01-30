# Security model

Luciuz aims to be **secure by default**. This document describes the baseline protections and the intended operator experience.

## Threat model (practical)
Luciuz is designed for internet-facing deployments. The baseline assumes:
- Host header abuse (cache poisoning, open redirects, vhost confusion)
- Slow clients (resource exhaustion)
- Untrusted request input (headers/body/path)
- Misconfiguration (dangerous defaults)

## Core principles
1) **Fail closed**: reject what you do not explicitly serve.
2) **Minimize attack surface**: keep the HTTP :80 path minimal.
3) **Least privilege**: run as non-root, restrict filesystem writes.
4) **Progressive hardening**: security headers/HSTS are safe but must be rolled out carefully.

## Host and redirect policy
- Optional `server.canonical_host`:
  - redirects `www.<canonical>` → `<canonical>`
  - rejects unknown hosts with a clear status code, rather than redirecting them

This prevents accidental open-redirect behavior and makes vhost handling explicit.

## Port 80 behavior
In the default `http-01` ACME mode, port 80 is limited to:
- `/.well-known/acme-challenge/...` for Let's Encrypt
- redirect to HTTPS for everything else

In `tls-alpn-01`, port 80 can be "redirect-only" (and, in roadmap v1, optionally disabled).

## HTTPS response headers
When enabled, Luciuz emits baseline security headers on HTTPS responses:
- `X-Content-Type-Options: nosniff`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `X-Frame-Options: DENY`
- `Cross-Origin-Opener-Policy: same-origin`
- `Cross-Origin-Resource-Policy: same-site`

## HSTS guidance
HSTS is powerful and sticky.
Recommended rollout:
1) Start low (e.g. 1 day)
2) Observe for a few days
3) Increase gradually (1 week, 1 month, 6 months)
4) Only consider `includeSubDomains` and `preload` when you are confident

## System hardening
Run Luciuz under a hardened `systemd` unit:
- Run as a dedicated user
- Use `CAP_NET_BIND_SERVICE` instead of root
- Restrict writes to an explicit directory (e.g. `/var/lib/luciuz`)
- Enable sandboxing directives (see `systemd.md`)

## Disclosure
Please report security issues privately.
See `SECURITY.md`.
