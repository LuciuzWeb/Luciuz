# Configuration

Luciuz utilise un fichier de configuration au format TOML (souvent `luciuz.toml`).

## HTTPS + ACME (minimal)

```toml
[server]
http_listen = "0.0.0.0:80"
https_listen = "0.0.0.0:443"

# Hôte canonique optionnel (recommandé si un seul domaine)
# - redirige https://www.<domaine> → https://<domaine>
# - rejette les hôtes inconnus au lieu de les rediriger
canonical_host = "luciuz.com"

# Headers de sécurité (HTTPS uniquement)
security_headers = true

# HSTS : commencer bas, augmenter progressivement
hsts = true
hsts_max_age = 86400
hsts_include_subdomains = false
hsts_preload = false

[timeouts]
# Durée maximale accordée à un handler pour répondre
handler_secs = 30

[acme]
enabled = true
prod = false
email = "admin@example.com"
domains = ["example.com", "www.example.com"]
cache_dir = "/var/lib/luciuz/acme"

# `http-01` (nécessite le port 80 pour le challenge ACME)
# `tls-alpn-01` (ACME via 443 ; permet un mode 443-only)
challenge = "http-01"
```

Valider le fichier :

```bash
luciuz check -c luciuz.toml
```

## Modes ACME
- **http-01** : le port 80 sert `/.well-known/acme-challenge/...` + redirige tout le reste.
- **tls-alpn-01** : les challenges ACME passent par 443 lors du handshake TLS.

Voir : `acme.md`.

## Mode 443-only (roadmap v1)
Quand `acme.challenge = "tls-alpn-01"`, Luciuz pourra (optionnellement) fonctionner sans écouter sur le port 80.

Migration type :
1) Passer en `tls-alpn-01`.
2) Vérifier les renouvellements via 443.
3) Désactiver le port 80 (config + firewall).

(Les détails sont dans la roadmap tant que l’option n’est pas entièrement câblée.)
