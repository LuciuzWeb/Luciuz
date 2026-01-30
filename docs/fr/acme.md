# ACME (Let’s Encrypt)

Luciuz peut obtenir et renouveler automatiquement des certificats TLS via Let’s Encrypt grâce à `rustls-acme`.

## Configuration minimale
```toml
[acme]
enabled = true
prod = true
email = "you@example.com"
domains = ["example.com","www.example.com"]
cache_dir = "/var/lib/luciuz/acme"
challenge = "http-01" # ou "tls-alpn-01"
```

## Modes de challenge
### `http-01`
- Nécessite le port 80.
- Luciuz sert `/.well-known/acme-challenge/...` puis redirige le reste vers HTTPS.

### `tls-alpn-01`
- Utilise uniquement le port 443 : le challenge se fait pendant le handshake TLS.
- Permet à terme un mode **443-only** (pas d’écoute sur 80) selon la config.

## Cache et permissions
`cache_dir` doit être un dossier writable par l’utilisateur systemd de Luciuz.

Exemple :
```bash
sudo mkdir -p /var/lib/luciuz/acme
sudo chown -R zentra:zentra /var/lib/luciuz
sudo chmod 700 /var/lib/luciuz /var/lib/luciuz/acme
```

## Dépannage rapide
- Vérifie que le DNS des domaines pointe vers le serveur.
- Vérifie que le firewall autorise 80/443 (ou 443 seul en tls-alpn-01).
- Consulte les logs : `journalctl -u luciuz -f`
