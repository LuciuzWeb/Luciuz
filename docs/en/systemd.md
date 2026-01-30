# systemd (Linux service)

This document shows a secure baseline `systemd` unit for Luciuz.

## Example unit

Save as `/etc/systemd/system/luciuz.service`:

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

# Bind 80/443 without running as root
AmbientCapabilities=CAP_NET_BIND_SERVICE
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
NoNewPrivileges=true

# Restrict file writes (ACME cache + logs if any)
UMask=0077
ReadWritePaths=/var/lib/luciuz

# Basic sandboxing
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

### Create the ACME cache directory

```bash
sudo mkdir -p /var/lib/luciuz/acme
sudo chown -R zentra:zentra /var/lib/luciuz
sudo chmod 700 /var/lib/luciuz /var/lib/luciuz/acme
```

## Enable and start

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now luciuz
sudo systemctl status luciuz --no-pager
sudo journalctl -u luciuz -f
```

## Notes
- Adjust `User/Group`, paths, and `ReadWritePaths` to match your deployment.
- If you change `cache_dir`, update `ReadWritePaths` accordingly.
