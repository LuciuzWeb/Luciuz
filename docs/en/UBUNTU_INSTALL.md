\
# Luciuz — Ubuntu 24.04 installer (ubuntu_install.sh)

This document explains each interactive prompt.

## Run

```bash
chmod +x ubuntu_install.sh
sudo ./ubuntu_install.sh
```

## Prompts

1. **Git repository URL**: where Luciuz is cloned from.
2. **Systemd service name**: service name (default: `luciuz`).
3. **Dedicated system user**: Linux user that runs Luciuz (default: `luciuz`).
4. **Installation directory**: where the repo is cloned.
5. **Config path**: where Luciuz reads TOML.
6. **Apex domain**: canonical host, e.g. `luciuz.com`.
7. **Serve www**: includes `www` in the TLS certificate.
8. **ACME email**: Let’s Encrypt contact.
9. **Enable ACME**: whether Luciuz manages TLS automatically.
10. **ACME production**: real certs vs staging.
11. **Challenge type**:
    - `http-01` requires port 80
    - `tls-alpn-01` can be 443-only
12. **HTTPS listen**: usually `0.0.0.0:443`.
13. **HTTP listen**: empty disables port 80.
14. **Server profile**: `static_site` or `public_api`.
15. **Security headers**: baseline headers on HTTPS.
16. **HSTS**: enable Strict-Transport-Security.
17. **Static root**: directory for static files.
18. **Static index**: usually `index.html`.
19. **Proxy max body bytes**: upload size limit.
20. **Proxy prefix**: usually `/api`.
21. **Proxy upstream**: usually `http://127.0.0.1:8080`.

## After install

```bash
systemctl status luciuz --no-pager
journalctl -u luciuz -f --no-pager
curl -I https://YOUR_DOMAIN/healthz
```
