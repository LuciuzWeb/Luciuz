# Roadmap

Cette roadmap décrit la trajectoire vers une v1 “production-grade”.

## v0.x (MVP actuel)
- HTTPS sur 443 avec ACME intégré
- HTTP sur 80 minimal (ACME + redirection)
- Hôte canonique (www → apex)
- Headers de sécurité + HSTS (progressif)
- Template systemd durci
- Timeout handler configurable

## Objectifs v1.0 (serveur web complet)
### Security-by-default
- Mode 443-only optionnel (TLS-ALPN-01)
- Timeouts et limites transport (headers, idle, keepalive)
- Contrôle du host strict par site (virtual hosts)

### Fonctions serveur
- Static files (dossier root, index, cache-control)
- Reverse proxy (routes → upstream, headers forwarded)
- Multi-sites (plusieurs domaines)
- Reload sans downtime (+ commande `check`)

### Observabilité
- Logs structurés par défaut
- Compteurs métriques de base

## Community vs Pro
- **Community** : cœur du serveur (TLS/ACME, statique/proxy, multi-site, observabilité)
- **Pro** : modules commerciaux (intégrations avancées, contrôle centralisé, packs de policies, etc.)

## Wasm (v1.x / v2)
- Plugins Wasm sandboxés avec API stable
- Capabilités explicites, limites CPU/mémoire
