# systemd (service Linux)

Ce document montre une unité `systemd` de base, orientée sécurité, pour Luciuz.

## Exemple d'unité

À enregistrer dans `/etc/systemd/system/luciuz.service` :

```ini
[Unit]
Description=Luciuz Web Server
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=zentra
Group=zentra
WorkingDirectory=/home/zentra/LuciuzWeb
ExecStart=/home/zentra/LuciuzWeb/target/release/luciuz run -c /home/zentra/LuciuzWeb/luciuz.toml

# Binder 80/443 sans exécuter en root
AmbientCapabilities=CAP_NET_BIND_SERVICE
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
NoNewPrivileges=true

# Limiter les écritures (cache ACME + logs si besoin)
UMask=0077
ReadWritePaths=/var/lib/luciuz

# Sandboxing (base)
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ProtectControlGroups=true
ProtectKernelTunables=true
ProtectKernelModules=true
ProtectKernelLogs=true
LockPersonality=true
MemoryDenyWriteExecute=true
RestrictNamespaces=true
RestrictRealtime=true
RestrictSUIDSGID=true
RemoveIPC=true

Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
```

### Créer le dossier du cache ACME

```bash
sudo mkdir -p /var/lib/luciuz/acme
sudo chown -R zentra:zentra /var/lib/luciuz
sudo chmod 700 /var/lib/luciuz /var/lib/luciuz/acme
```

## Activer et démarrer

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now luciuz
sudo systemctl status luciuz --no-pager
sudo journalctl -u luciuz -f
```

## Notes
- Adapte `User/Group`, les chemins, et `ReadWritePaths` selon ton déploiement.
- Si tu changes `cache_dir`, adapte `ReadWritePaths` en conséquence.
