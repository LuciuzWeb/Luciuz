# Milestones

These milestones are designed so each release is usable.

## v0.2 — Single-node production-ready
Focus: TLS + config + basic serving + basic proxy + logs/metrics.

Exit criteria:
- ACME (HTTP-01 + TLS-ALPN-01) stable
- Optional 443-only mode
- Static file server minimal
- Reverse proxy minimal
- Access logs + /metrics
- Packaging: systemd template + docs

## v0.3 — Operator UX
Focus: safe reload, better diagnostics, better routing.

Exit criteria:
- Config reload (no downtime)
- Clear error messages + validation
- Routing rules (host/path) improved
- More timeouts/limits exposed in config

## v1.0 — Complete Community server
Focus: maturity and stability.

Exit criteria:
- Stable config model
- Reverse proxy correctness (headers, websocket, streaming)
- Security profiles (static_site/public_api/admin_panel) well-defined
- Observability polished (latency, codes, error budget basics)
- Documentation complete

## pro-v1 — Fleet + advanced controls
Focus: multi-node + governance.

Exit criteria:
- Fleet management (deploy, rollback, inventory)
- Advanced security (WAF/rate limit/mTLS/OIDC)
- Advanced observability (distributed tracing + integrations)
- Wasm platform (SDK, signing, registry, hot-reload)
