# Timeouts

Timeouts protect against slow clients and buggy handlers.

## Handler timeout
`timeouts.handler_secs` limits how long a request handler is allowed to run.

```toml
[timeouts]
handler_secs = 30
```

If the timeout triggers, Luciuz returns `504 Gateway Timeout`.

## Roadmap
Additional transport/proxy timeouts (header read, upstream connect/read, idle) are planned for v1.
