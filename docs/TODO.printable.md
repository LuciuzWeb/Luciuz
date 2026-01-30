# Luciuz — Printable TODO (v1)

Date: ____________   Owner: ____________   Target: v1.0

## Security-by-default (core)
[ ] Canonical host enforcement (WWW → apex) + reject unknown hosts
[ ] Port 80 minimal: ACME + redirect only (GET/HEAD only; allowlist hosts)
[ ] ACME modes: `http-01` and `tls-alpn-01`
[ ] 443-only mode: allow disabling port 80 when `tls-alpn-01`
[ ] System hardening template (systemd): least privilege, sandboxing, minimal write paths
[ ] Progressive HSTS guidance (do not force preload)

## Observability-by-default
[ ] Structured logs (request id, host, status, latency)
[ ] Log security events (invalid host, invalid method, redirects, timeouts)
[ ] Minimal metrics counters (requests, errors, timeouts, acme errors)

## Server features (Community v1)
[ ] Static site serving (root dir, index, cache-control)
[ ] Reverse proxy (routes → upstream, forwarded headers)
[ ] Multi-site (virtual hosts)
[ ] Graceful reload (no downtime) + config test command

## Reliability
[ ] Transport timeouts (header read, idle/keepalive) with safe defaults
[ ] Limits: headers count/size, concurrency (configurable)
[ ] Clear error messages + troubleshooting docs

## Packaging & DX
[ ] Linux install guide + systemd unit
[ ] Example configs (minimal / static / proxy / multi-site)
[ ] Release checklist (versioning, changelog)

## Community vs Pro
[ ] Document boundaries (what is Community vs Pro)
[ ] Public extension interfaces/hooks
[ ] Private Pro crate skeleton and build pipeline

Notes:
____________________________________________________________________
____________________________________________________________________
