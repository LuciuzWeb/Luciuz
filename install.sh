#!/usr/bin/env bash
set -euo pipefail

# Luciuz Community - interactive installer for Ubuntu 24.04+
# This script:
# - installs OS deps
# - creates/uses a dedicated user
# - clones/pulls the repo into an install directory
# - builds the luciuz binary (release)
# - installs config + systemd service
# - opens firewall ports (UFW)

red() { printf "\033[31m%s\033[0m\n" "$*"; }
grn() { printf "\033[32m%s\033[0m\n" "$*"; }
ylw() { printf "\033[33m%s\033[0m\n" "$*"; }

need_root() {
  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    red "Please run as root (example: sudo ./install.sh)"
    exit 1
  fi
}

ask() {
  local prompt="$1"; local default="$2"; local out
  if [[ -n "$default" ]]; then
    read -r -p "$prompt [$default]: " out || true
    echo "${out:-$default}"
  else
    read -r -p "$prompt: " out || true
    echo "$out"
  fi
}

confirm() {
  local prompt="$1"; local default_yes="$2"; local out
  if [[ "$default_yes" == "yes" ]]; then
    read -r -p "$prompt [Y/n]: " out || true
    out="${out:-Y}"
  else
    read -r -p "$prompt [y/N]: " out || true
    out="${out:-N}"
  fi
  [[ "$out" =~ ^[Yy]$ ]]
}

need_root

ylw "== Luciuz Community installer (Ubuntu 24.04) =="

ylw "1) Basic info"
RUN_USER=$(ask "Linux user that will run the service" "LuciusHQ")
INSTALL_DIR=$(ask "Install directory (repo clone path)" "/home/${RUN_USER}/Lucius")
REPO_URL=$(ask "Git repository URL" "https://github.com/LuciusHQ/Luciuz")
REPO_BRANCH=$(ask "Git branch" "main")

ylw "2) HTTPS / ACME"
DOMAIN=$(ask "Apex domain" "luciuz.com")
WANT_WWW="yes"
if confirm "Also include www.${DOMAIN} in certificate?" "yes"; then
  WANT_WWW="yes"
else
  WANT_WWW="no"
fi
ACME_EMAIL=$(ask "Let's Encrypt email" "admin@${DOMAIN}")
ACME_PROD="true"
if confirm "Use Let's Encrypt PRODUCTION (not staging)?" "yes"; then
  ACME_PROD="true"
else
  ACME_PROD="false"
fi

CHALLENGE=$(ask "ACME challenge (http-01 or tls-alpn-01)" "tls-alpn-01")
if [[ "$CHALLENGE" != "http-01" && "$CHALLENGE" != "tls-alpn-01" ]]; then
  red "Invalid challenge type: $CHALLENGE (allowed: http-01, tls-alpn-01)"
  exit 1
fi

HTTP_LISTEN=""
if [[ "$CHALLENGE" == "http-01" ]]; then
  HTTP_LISTEN="0.0.0.0:80"
fi
HTTPS_LISTEN="0.0.0.0:443"

ylw "3) Luciuz profile"
PROFILE=$(ask "server.profile (static_site or public_api or admin_panel)" "public_api")
case "$PROFILE" in
  static_site|public_api|admin_panel) ;;
  *) red "Invalid profile: $PROFILE"; exit 1;;
 esac

STATIC_ROOT=$(ask "Static site root directory" "/var/www/luciuz")

UPSTREAM=""
if [[ "$PROFILE" == "public_api" ]]; then
  UPSTREAM=$(ask "Upstream for /api (ex: http://127.0.0.1:8080)" "http://127.0.0.1:8080")
fi

ylw "4) Confirm"
echo "Service user:     $RUN_USER"
echo "Install dir:      $INSTALL_DIR"
echo "Repo:             $REPO_URL ($REPO_BRANCH)"
echo "Domain:           $DOMAIN"
echo "Include www:      $WANT_WWW"
echo "ACME:             enabled, prod=$ACME_PROD, challenge=$CHALLENGE"
echo "HTTP listen:      ${HTTP_LISTEN:-<disabled>}"
echo "HTTPS listen:     $HTTPS_LISTEN"
echo "Profile:          $PROFILE"
if [[ "$PROFILE" == "public_api" ]]; then
  echo "Proxy /api ->     $UPSTREAM"
fi
if ! confirm "Proceed with installation?" "yes"; then
  ylw "Aborted."
  exit 0
fi

ylw "== Installing OS dependencies =="
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y --no-install-recommends \
  ca-certificates curl git build-essential pkg-config ufw \
  jq unzip

# Create user if needed
if ! id -u "$RUN_USER" >/dev/null 2>&1; then
  ylw "Creating user '$RUN_USER'..."
  useradd -m -s /bin/bash "$RUN_USER"
fi

# Prepare directories
mkdir -p /etc/luciuz
mkdir -p /var/lib/luciuz/acme
mkdir -p "$STATIC_ROOT"
chown -R "$RUN_USER":"$RUN_USER" /var/lib/luciuz
chown -R "$RUN_USER":"$RUN_USER" "$STATIC_ROOT"

# Clone or update repo
if [[ -d "$INSTALL_DIR/.git" ]]; then
  ylw "Updating existing repo in $INSTALL_DIR..."
  su - "$RUN_USER" -c "cd '$INSTALL_DIR' && git fetch --all && git checkout '$REPO_BRANCH' && git pull --ff-only"
else
  ylw "Cloning repo to $INSTALL_DIR..."
  mkdir -p "$(dirname "$INSTALL_DIR")"
  chown -R "$RUN_USER":"$RUN_USER" "$(dirname "$INSTALL_DIR")"
  su - "$RUN_USER" -c "git clone --branch '$REPO_BRANCH' '$REPO_URL' '$INSTALL_DIR'"
fi

# Install rustup (per-user)
ylw "Installing Rust toolchain for $RUN_USER (rustup) if missing..."
su - "$RUN_USER" -c "command -v cargo >/dev/null 2>&1 || (curl -sSf https://sh.rustup.rs | sh -s -- -y)"

# Build
ylw "Building luciuz (release)..."
su - "$RUN_USER" -c "set -e; source ~/.cargo/env; cd '$INSTALL_DIR'; cargo build -p luciuz --release"

# Install binary
ylw "Installing binary to /usr/local/bin/luciuz..."
install -m 0755 "$INSTALL_DIR/target/release/luciuz" /usr/local/bin/luciuz

# Write config
DOMAINS_ARRAY="\"$DOMAIN\""
if [[ "$WANT_WWW" == "yes" ]]; then
  DOMAINS_ARRAY="$DOMAINS_ARRAY, \"www.$DOMAIN\""
fi

cat > /etc/luciuz/luciuz.toml <<EOF
[server]
http_listen = "${HTTP_LISTEN}"
https_listen = "${HTTPS_LISTEN}"
profile = "${PROFILE}"
canonical_host = "${DOMAIN}"
hsts = true
hsts_max_age = 86400
hsts_include_subdomains = false
hsts_preload = false
security_headers = true

[acme]
enabled = true
prod = ${ACME_PROD}
email = "${ACME_EMAIL}"
domains = [${DOMAINS_ARRAY}]
cache_dir = "/var/lib/luciuz/acme"
challenge = "${CHALLENGE}"

[telemetry]
json_logs = true
log_level = "info"

[timeouts]
handler_secs = 30

[static_site]
root = "${STATIC_ROOT}"
index = "index.html"
EOF

if [[ "$PROFILE" == "public_api" ]]; then
cat >> /etc/luciuz/luciuz.toml <<EOF

[proxy]
max_body_bytes = 52428800

[[proxy.routes]]
prefix = "/api"
upstream = "${UPSTREAM}"
EOF
fi

chown "$RUN_USER":"$RUN_USER" /etc/luciuz/luciuz.toml
chmod 0640 /etc/luciuz/luciuz.toml

# Minimal index page
if [[ ! -f "$STATIC_ROOT/index.html" ]]; then
  cat > "$STATIC_ROOT/index.html" <<'HTML'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Luciuz</title>
  <style>
    body { font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif; margin: 3rem; }
    code { background: #f3f3f3; padding: 0.15rem 0.35rem; border-radius: 6px; }
  </style>
</head>
<body>
  <h1>Luciuz is running</h1>
  <p>Health check: <code>/healthz</code></p>
  <p>Docs: <code>/docs</code> (if you enable static serving for docs later)</p>
</body>
</html>
HTML
  chown "$RUN_USER":"$RUN_USER" "$STATIC_ROOT/index.html"
fi

# systemd unit
ylw "Installing systemd service..."
cat > /etc/systemd/system/luciuz.service <<EOF
[Unit]
Description=Luciuz Web Server
After=network-online.target
Wants=network-online.target

[Service]
User=${RUN_USER}
Group=${RUN_USER}
WorkingDirectory=${INSTALL_DIR}
ExecStart=/usr/local/bin/luciuz run -c /etc/luciuz/luciuz.toml

AmbientCapabilities=CAP_NET_BIND_SERVICE
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
NoNewPrivileges=true

Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable luciuz.service
systemctl restart luciuz.service

# Firewall
ylw "Configuring UFW firewall..."
ufw allow OpenSSH >/dev/null || true
ufw allow 443/tcp >/dev/null || true
if [[ "$CHALLENGE" == "http-01" ]]; then
  ufw allow 80/tcp >/dev/null || true
else
  ylw "Note: ACME tls-alpn-01 selected. Port 80 can remain closed."
fi
if ! ufw status | grep -q "Status: active"; then
  if confirm "Enable UFW now?" "yes"; then
    ufw --force enable
  else
    ylw "UFW left disabled."
  fi
fi


grn "Done!"
echo "- Config:   /etc/luciuz/luciuz.toml"
echo "- Service:  systemctl status luciuz.service"
echo "- Logs:     journalctl -u luciuz.service -f"
if [[ "$CHALLENGE" == "http-01" ]]; then
  ylw "IMPORTANT: keep port 80 open until certificate issuance/renewal is confirmed."
fi
