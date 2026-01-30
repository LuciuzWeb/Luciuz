# Luciuz Documentation

This folder contains the **authoritative** project documentation (English, source of truth).

## Start here
- [Configuration](./configuration.md)
- [systemd (VPS)](./systemd.md)
- [Security model](./security-model.md)
- [Observability](./observability.md)
- [Architecture](./architecture.md)
- [Development](./development.md)
- [Community vs Pro (open-core)](./open-core.md)
- [Roadmap](./roadmap.md)

## Translations (i18n)
Translations live under `docs/i18n/`:
- [Translations index](./i18n/README.md)

## Project management
- [Backlog (copy/paste issues)](./project/issue-backlog.md)
- [Suggested labels](./project/labels.md)
- [Milestones](./project/milestones.md)

## Principles
Luciuz is designed around:
- **Secure defaults**: sensible timeouts, size limits, and hardening profiles.
- **Actionable observability**: built-in logs/metrics/traces and operator-friendly diagnostics.
- **Safe extensibility**: capability-based Wasm hooks, sandboxed and resource-limited.
