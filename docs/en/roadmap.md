# Roadmap

This roadmap describes the path to a production-grade v1.

## v0.x (current MVP)
- HTTPS on 443 with built-in ACME
- HTTP on 80 minimal (ACME + redirect)
- Canonical host (www → apex)
- Baseline security headers + HSTS (progressive)
- systemd hardening template
- Handler timeout (configurable)

## v1.0 goals (server-grade)
### Security-by-default
- Optional 443-only mode (TLS-ALPN-01)
- Transport-level timeouts (header read, idle/keepalive)
- Configurable limits (headers size/count, concurrency)

### Core server features
- Static file serving
- Reverse proxy (routes → upstream)
- Multi-site / virtual hosts
- Graceful config reload (no downtime)

### Observability-by-default
- Structured logs with request ids
- Basic metrics endpoint or exporter (TBD)

## Wasm roadmap
- Capability-based plugins, sandboxed and resource-limited
- Stable plugin API

## Community vs Pro
- Community (public repo): core web server and operator experience
- Pro (private commercial crate): advanced enterprise features and integrations
