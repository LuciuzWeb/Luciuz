# Community vs Pro (open-core)

Luciuz follows an **open-core** model:
- **Community (OSS)**: a first-class, production-usable single-node web server.
- **Pro (commercial)**: fleet management, advanced security, and advanced observability.

## Product principles
1. **No crippleware**: Community must be genuinely useful.
2. **Security-by-default**: safe defaults, explicit weakening.
3. **Observability-by-default**: logs/metrics/traces designed for operators.
4. **Clear separation**: Community = single-node; Pro = scale and enterprise capabilities.
5. **Stable extension points**: Community provides APIs/hooks; Pro provides premium implementations.

## Community scope (what must stay OSS)
- Automatic HTTPS (ACME): HTTP-01 and TLS-ALPN-01.
- Optional **443-only** mode.
- Canonical host handling and strict Host validation.
- Static file serving.
- Reverse proxy (basic routing, websocket pass-through where possible).
- Structured access logs + Prometheus metrics endpoint.
- Config parsing + strong validation.
- Reasonable security defaults (timeouts, basic limits, headers).
- Minimal Wasm hooks (experimental): request/response filters with strict sandboxing.

## Pro scope (what must be paid)
- **Fleet management** (multi-node): deploy, rollback, inventory, config drift detection.
- **Advanced security**: WAF rulesets, advanced rate limiting, mTLS, OIDC/SSO auth gates.
- **Advanced observability**: distributed tracing pipelines, SIEM integrations, anomaly detection.
- **Wasm platform**: SDK, module signing, registry, hot-reload, richer capabilities.
- Compliance tooling, admin UI, and operator workflows.

## “Wasm minimal” vs “Wasm platform”
- Community: a small, stable ABI and a couple of safe hooks.
- Pro: developer experience (SDK), governance (signing), and operational tooling.

## What this enables
- Community users can replace common Nginx/Caddy setups on a single server.
- Pro users can operate Luciuz across fleets with strong governance and security.
