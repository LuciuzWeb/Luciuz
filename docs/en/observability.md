# Observability

Luciuz is designed to be **observable by default**: it should be possible to operate it in production without guessing.

## Logs
- Structured logs (JSON or key=value) are preferred.
- Logs should include: method, path, host, status, latency, and request id.

## Key events to log
- ACME lifecycle events (issuance/renewal/errors)
- Canonical host redirects
- Rejected hosts and invalid methods
- Timeouts (handler, proxy, network)

## Metrics (roadmap)
Planned metrics include:
- Request counters by status code
- Timeout counters
- ACME errors
- Connection counts

## Traces (roadmap)
OpenTelemetry integration is planned for distributed tracing.
