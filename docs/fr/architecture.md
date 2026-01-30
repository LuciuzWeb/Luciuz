# Architecture

Luciuz est organisé en workspace Rust avec des crates ciblées. L’architecture sépare :
- **Data plane** : le chemin rapide de traitement des requêtes.
- **Control plane** : validation de configuration, reload, diagnostics.

## Composants (cibles)
Crates prévues :
- `luciuz-config` : parsing TOML + validation + profils
- `luciuz-telemetry` : logs structurés + métriques + tracing
- `luciuz-proxy` : routing + reverse proxy
- `luciuz-tls` : rustls + ACME + stockage certs + hot reload
- `luciuz-policy` : limites par défaut, rate limiting, headers, timeouts
- `luciuz-wasm` : runtime Wasm + ABI + capacités
- `luciuz-control` : API locale (reload/rollback/diagnostic)

## Pipeline requête (cible)
1. Acceptation connexion
2. Terminaison TLS
3. Parsing HTTP
4. Match routes (host/path)
5. Application policies
6. Hooks Wasm `on_request`
7. Reverse proxy vers upstream
8. Hooks Wasm `on_response`
9. Émission télémétrie (logs/métriques/traces)

## Reload de config (cible)
- **atomique** : la nouvelle config s’active d’un coup
- **sûr** : config invalide rejetée
- **sans coupure** : les connexions existantes terminent correctement
