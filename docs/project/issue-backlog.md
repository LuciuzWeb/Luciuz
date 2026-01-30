# Issue backlog (copy/paste into GitHub)

This file is designed to be copied into GitHub issues. Each section below is one issue.

Tip: create labels first (see `docs/project/labels.md`) and then create milestones (see `docs/project/milestones.md`).

---

## Community — v0.2 (single-node prod-ready)

### Add optional 443-only mode (disable HTTP listener)
**Labels:** `tier/community`, `type/feature`, `prio/P0`, `area/http`, `area/acme`, `area/config`
**Milestone:** v0.2

**Goal**
Allow running Luciuz without binding port 80 when `acme.challenge=tls-alpn-01`.

**Tasks**
- [ ] Allow empty/disabled `server.http_listen` **only** when ACME is enabled and `acme.challenge=tls-alpn-01`.
- [ ] When disabled, do not bind HTTP listener at runtime.
- [ ] Document how to migrate from HTTP-01 to TLS-ALPN-01.

**Acceptance criteria**
- With `http_listen=""` and `tls-alpn-01`, Luciuz starts and serves HTTPS.
- With `http_listen=""` and `http-01`, config validation fails with a clear error.

---

### Add ACME staging/production switch documentation
**Labels:** `tier/community`, `type/docs`, `prio/P1`, `area/acme`, `area/docs`
**Milestone:** v0.2

**Goal**
Make it easy for newcomers to test ACME without rate-limit surprises.

**Tasks**
- [ ] Document `acme.prod=false` (staging) vs `true` (production).
- [ ] Provide example config snippets.

**Acceptance criteria**
- Docs explain how to test certificates safely and then switch to production.

---

### Static file server: serve directory + index + 404
**Labels:** `tier/community`, `type/feature`, `prio/P0`, `area/static`
**Milestone:** v0.2

**Goal**
Serve a local directory as a website (basic "static site" mode).

**Tasks**
- [ ] Add config: `static.enabled`, `static.root`, `static.index`.
- [ ] Serve files with correct content-type.
- [ ] Default index fallback and a clean 404 page.

**Acceptance criteria**
- A user can serve a folder with `index.html` via HTTPS.
- Missing file returns 404.

---

### Reverse proxy: single upstream (basic)
**Labels:** `tier/community`, `type/feature`, `prio/P0`, `area/proxy`, `area/config`
**Milestone:** v0.2

**Goal**
Proxy requests from Luciuz to one upstream (common deployment pattern).

**Tasks**
- [ ] Add config: `proxy.enabled`, `proxy.upstream`.
- [ ] Forward method/path/query, body streaming (no full buffering by default).
- [ ] Set forwarding headers: `Host`, `X-Forwarded-For`, `X-Forwarded-Proto`.

**Acceptance criteria**
- Requests to Luciuz are served by the upstream.
- Large bodies do not cause out-of-memory.

---

### Reverse proxy: websocket pass-through (if supported)
**Labels:** `tier/community`, `type/feature`, `prio/P1`, `area/proxy`
**Milestone:** v0.2

**Goal**
Support common websocket applications behind Luciuz.

**Tasks**
- [ ] Implement websocket upgrade pass-through.
- [ ] Add basic test (local). 

**Acceptance criteria**
- A websocket echo test works through Luciuz.

---

### Access logs: one structured entry per request
**Labels:** `tier/community`, `type/feature`, `prio/P0`, `area/observability`
**Milestone:** v0.2

**Goal**
Provide actionable logs by default.

**Tasks**
- [ ] Emit one log line per request with: host, method, path, status, latency, client IP, request id.
- [ ] Ensure logs are JSON when configured.

**Acceptance criteria**
- Access logs are consistent and easy to parse.

---

### Metrics endpoint: /metrics (Prometheus)
**Labels:** `tier/community`, `type/feature`, `prio/P1`, `area/observability`
**Milestone:** v0.2

**Goal**
Expose basic counters and latencies.

**Tasks**
- [ ] Add `/metrics` endpoint (configurable path and enable flag).
- [ ] Metrics: requests_total (by status), request_duration_seconds.

**Acceptance criteria**
- `curl https://.../metrics` returns Prometheus-compatible text.

---

### Config examples: static site + reverse proxy
**Labels:** `tier/community`, `type/docs`, `prio/P1`, `area/docs`, `area/config`
**Milestone:** v0.2

**Goal**
Ship working examples.

**Tasks**
- [ ] Add `docs/examples/static-site.toml`.
- [ ] Add `docs/examples/reverse-proxy.toml`.

**Acceptance criteria**
- Examples pass `luciuz check`.

---

### systemd template: hardened unit (documented)
**Labels:** `tier/community`, `type/docs`, `prio/P1`, `area/systemd`, `area/docs`
**Milestone:** v0.2

**Goal**
Provide a production-friendly unit file as a template.

**Tasks**
- [ ] Add `deploy/systemd/luciuz.service` template.
- [ ] Document required writable paths (ACME cache).

**Acceptance criteria**
- Users can copy/paste the template and run Luciuz as a service.

---

## Community — v0.3 (operator UX + reload)

### Add config reload (SIGHUP or command)
**Labels:** `tier/community`, `type/feature`, `prio/P0`, `area/control-plane`, `area/config`
**Milestone:** v0.3

**Goal**
Change config without full downtime.

**Tasks**
- [ ] Implement safe reload trigger (SIGHUP recommended).
- [ ] Validate new config before applying.
- [ ] Keep old config if validation fails.

**Acceptance criteria**
- Reload applies new routes without stopping the process.

---

### Add "diagnose" command (basic report)
**Labels:** `tier/community`, `type/feature`, `prio/P1`, `area/observability`, `area/control-plane`
**Milestone:** v0.3

**Goal**
Provide an operator-friendly status report.

**Tasks**
- [ ] `luciuz diagnose` prints config summary, TLS status, certificate age, listener status.
- [ ] Include last ACME error if present.

**Acceptance criteria**
- Diagnose output is readable and useful.

---

### Host/path routing v1 (simple rules)
**Labels:** `tier/community`, `type/feature`, `prio/P0`, `area/proxy`, `area/config`
**Milestone:** v0.3

**Goal**
Support multiple sites and multiple upstreams.

**Tasks**
- [ ] Add config: routes with host + path prefix.
- [ ] Route actions: static root or upstream.
- [ ] Deterministic rule matching.

**Acceptance criteria**
- Two hosts can be served by one Luciuz instance.

---

### Timeouts & limits config (transport/proxy)
**Labels:** `tier/community`, `type/feature`, `prio/P1`, `area/security`, `area/proxy`, `area/config`
**Milestone:** v0.3

**Goal**
Make anti-abuse behavior explicit and configurable.

**Tasks**
- [ ] Add config sections: `timeouts` and `limits` (connect/read/write/body/header).
- [ ] Enforce safe defaults.

**Acceptance criteria**
- Defaults are safe; operators can tune them.

---

### Docs i18n structure + contribution guide
**Labels:** `tier/community`, `type/docs`, `prio/P2`, `area/docs`
**Milestone:** v0.3

**Goal**
Make it easy to add translations.

**Tasks**
- [ ] Add `docs/i18n/README.md` describing the process.
- [ ] Add one starter translation folder (French) as an example.

**Acceptance criteria**
- Contributors can add new languages without guessing.

---

## Community — v1.0 (complete community server)

### Minimal Wasm hooks (experimental)
**Labels:** `tier/community`, `type/feature`, `prio/P1`, `area/wasm`, `area/security`
**Milestone:** v1.0

**Goal**
Allow safe, sandboxed request/response customization.

**Tasks**
- [ ] Define ABI v0: `on_request` and `on_response`.
- [ ] Enforce CPU and memory limits.
- [ ] Capability model (very small): read-only request info + header edits.
- [ ] Provide 2 example plugins.

**Acceptance criteria**
- A plugin can add a response header.
- A plugin can block a request with 403.

---

### ACME certificate hot-reload and graceful rotation
**Labels:** `tier/community`, `type/feature`, `prio/P1`, `area/tls`, `area/acme`
**Milestone:** v1.0

**Goal**
Rotate certificates without disruption.

**Tasks**
- [ ] Ensure renewed certs are used for new connections automatically.
- [ ] Document renewal behavior.

**Acceptance criteria**
- No manual restart required for renewal.

---

### Docker image + basic deployment docs
**Labels:** `tier/community`, `type/feature`, `prio/P2`, `area/docs`, `area/systemd`
**Milestone:** v1.0

**Goal**
Offer a simple container-based deployment option.

**Tasks**
- [ ] Add Dockerfile.
- [ ] Document volumes for ACME cache.

**Acceptance criteria**
- `docker run` example works.

---

### Security profiles (static_site / public_api / admin_panel)
**Labels:** `tier/community`, `type/feature`, `prio/P2`, `area/security`, `area/config`
**Milestone:** v1.0

**Goal**
Provide safe presets for common workloads.

**Tasks**
- [ ] Define profile defaults (timeouts, headers, limits).
- [ ] Allow explicit overrides.

**Acceptance criteria**
- Profile changes behavior without requiring many knobs.

---

## Pro — pro-v1 (fleet + advanced security/obs)

### Fleet controller: enroll nodes + inventory
**Labels:** `tier/pro`, `type/feature`, `prio/P0`, `area/fleet`, `area/control-plane`
**Milestone:** pro-v1

**Goal**
Operate Luciuz across many servers.

**Tasks**
- [ ] Secure enrollment mechanism.
- [ ] Node inventory: version, config hash, TLS status, uptime.

**Acceptance criteria**
- Controller sees registered nodes and their status.

---

### Fleet config deploy with rollback
**Labels:** `tier/pro`, `type/feature`, `prio/P0`, `area/fleet`, `area/config`
**Milestone:** pro-v1

**Goal**
Push config updates safely at scale.

**Tasks**
- [ ] Push config to selected nodes.
- [ ] Validate before apply.
- [ ] Rollback on failure.

**Acceptance criteria**
- A bad config does not break the fleet.

---

### Advanced rate limiting (per route / per IP)
**Labels:** `tier/pro`, `type/feature`, `prio/P1`, `area/security`
**Milestone:** pro-v1

**Goal**
Offer operator-friendly rate limiting.

**Tasks**
- [ ] Token bucket rules.
- [ ] Per-route scoping.
- [ ] Metrics for limited requests.

**Acceptance criteria**
- Operator can limit `/login` without affecting other routes.

---

### WAF rulesets (basic)
**Labels:** `tier/pro`, `type/feature`, `prio/P1`, `area/security`
**Milestone:** pro-v1

**Goal**
Provide a practical layer against common attacks.

**Tasks**
- [ ] Block obvious malicious patterns.
- [ ] Allow custom rules.
- [ ] Log decisions clearly.

**Acceptance criteria**
- Requests can be blocked with a clear reason.

---

### mTLS support (client certificates)
**Labels:** `tier/pro`, `type/feature`, `prio/P1`, `area/tls`, `area/security`
**Milestone:** pro-v1

**Goal**
Support internal services and zero-trust setups.

**Tasks**
- [ ] Configure trusted CAs.
- [ ] Require/optional client cert per route.

**Acceptance criteria**
- A route can require a client certificate.

---

### OIDC/SSO gate for protected routes
**Labels:** `tier/pro`, `type/feature`, `prio/P1`, `area/security`
**Milestone:** pro-v1

**Goal**
Protect admin endpoints behind a modern identity provider.

**Tasks**
- [ ] OIDC login flow for routes.
- [ ] Session handling.

**Acceptance criteria**
- An operator can protect `/admin` with OIDC.

---

### Wasm platform: SDK + signing + registry
**Labels:** `tier/pro`, `type/feature`, `prio/P0`, `area/wasm`
**Milestone:** pro-v1

**Goal**
Make Wasm plugins safe to distribute and operate.

**Tasks**
- [ ] Developer SDK and templates.
- [ ] Module signing and verification.
- [ ] Registry (local or remote).
- [ ] Hot-reload with rollback.

**Acceptance criteria**
- Only signed modules run in production mode.

---

### Advanced observability integrations
**Labels:** `tier/pro`, `type/feature`, `prio/P1`, `area/observability`
**Milestone:** pro-v1

**Goal**
Integrate with common operator stacks.

**Tasks**
- [ ] OTLP export configuration.
- [ ] SIEM/log pipeline configuration.

**Acceptance criteria**
- Traces export to an OTLP endpoint.
