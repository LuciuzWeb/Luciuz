<div align="center">

# Luciuz
### Secure-by-default web server & reverse proxy with observability-by-default and built-in ACME HTTPS

</div>

Luciuz is a Rust web server / reverse proxy designed to be **safe and operable by default**.

## Why Luciuz?
Most web servers are powerful, but easy to misconfigure. Luciuz aims to be the opposite:
- **Secure-by-default**: safe defaults, explicit weakening, clear policy knobs.
- **Observability-by-default**: structured logs first, metrics/traces as first-class features.
- **Built-in HTTPS**: automatic certificates via Let's Encrypt (no external certbot service).

## Status
Early development (v0.1). MVP today:
- HTTP :80 minimal (ACME HTTP-01 + redirect)
- HTTPS :443 service
- `/healthz`
- Canonical host support (www → apex) and strict Host validation

## Community vs Pro
Luciuz follows an **open-core** model:
- **Community (OSS)**: production-usable **single-node** server (TLS, static, proxy, logs, metrics).
- **Pro (commercial)**: **fleet management** + advanced security + advanced observability + Wasm platform.

Details: see [`docs/open-core.md`](./docs/open-core.md).

## Quick start (local)
```bash
cargo build --release
./target/release/luciuz check -c luciuz.toml
./target/release/luciuz run -c luciuz.toml
```

## Documentation
- Docs index: [`docs/README.md`](./docs/README.md)
- Configuration: [`docs/configuration.md`](./docs/configuration.md)
- systemd (VPS): [`docs/systemd.md`](./docs/systemd.md)
- Roadmap: [`docs/roadmap.md`](./docs/roadmap.md)
- Translations (i18n): [`docs/i18n/README.md`](./docs/i18n/README.md)

## Contributing
See [`CONTRIBUTING.md`](./CONTRIBUTING.md).

## Security
Please report vulnerabilities responsibly. See [`SECURITY.md`](./SECURITY.md).

## License
Apache-2.0. See [`LICENSE`](./LICENSE) and [`NOTICE`](./NOTICE).
