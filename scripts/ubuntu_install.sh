#!/usr/bin/env bash
set -euo pipefail

# Luciuz Community - Ubuntu 24.04 installer (GitHub clone)
# Repo: https://github.com/LuciuzHQ/Luciuz

REPO_URL_DEFAULT="https://github.com/LuciuzHQ/Luciuz"
SERVICE_NAME_DEFAULT="luciuz"
DEFAULT_USER="luciuz"
DEFAULT_REPO_DIR="/home/luciuz/Luciuz"
DEFAULT_CONFIG_PATH="/etc/luciuz/luciuz.toml"
DEFAULT_ACME_CACHE_DIR="/var/lib/luciuz/acme"
DEFAULT_STATIC_ROOT="/var/www/luciuz"
DEFAULT_HTTP_LISTEN="0.0.0.0:80"
DEFAULT_HTTPS_LISTEN="0.0.0.0:443"
DEFAULT_PROXY_PREFIX="/api"
DEFAULT_PROXY_UPSTREAM="http://127.0.0.1:8080"
DEFAULT_PROXY_MAX_BODY="52428800" # 50MB
DEFAULT_HSTS_MAX_AGE="86400"      # 1 day

say() { printf "\n\033[1m%s\033[0m\n" "$*"; }
info() { printf "%s\n" "$*"; }
warn() { printf "\033[33mWARN:\033[0m %s\n" "$*"; }
err() { printf "\033[31mERROR:\033[0m %s\n" "$*"; }
die() { err "$*"; exit 1; }

prompt() {
  local var="$1"; shift
  local msg="$1"; shift
  local def="${1:-}"
  local val=""
  if [[ -n "$def" ]]; then
    read -r -p "$msg [$def]: " val || true
    val="${val:-$def}"
  else
    read -r -p "$msg: " val || true
  fi
  printf -v "$var" "%s" "$val"
}

prompt_yesno() {
  local var="$1"; shift
  local msg="$1"; shift
  local def="${1:-y}"
  local val=""
  local hint="y/n"
  if [[ "$def" == "y" ]]; then hint="Y/n"; else hint="y/N"; fi
  while true; do
    read -r -p "$msg [$hint]: " val || true
    val="${val:-$def}"
    case "$val" in
      y|Y|yes|YES) printf -v "$var" "y"; return 0 ;;
      n|N|no|NO)   printf -v "$var" "n"; return 0 ;;
      *) info "Please answer y or n." ;;
    esac
  done
}

ensure_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    die "Please run as root (e.g. sudo ./ubuntu_install.sh)."
  fi
}

apt_install() {
  say "Installing OS dependencies (apt)"
  export DEBIAN_FRONTEND=noninteractive
  apt-get update -y
  apt-get install -y --no-install-recommends \
    ca-certificates curl git build-essential pkg-config \
    libssl-dev clang lld \
    unzip jq \
    ufw \
    libcap2-bin
}

ensure_user() {
  local user="$1"
  if id "$user" >/dev/null 2>&1; then
    info "User '$user' already exists."
  else
    say "Creating dedicated system user: $user"
    adduser --disabled-password --gecos "" "$user"
  fi
}

ensure_dirs() {
  local user="$1"
  local repo_dir="$2"
  say "Creating directories"
  mkdir -p "$(dirname "$DEFAULT_CONFIG_PATH")"
  mkdir -p "$DEFAULT_ACME_CACHE_DIR"
  mkdir -p "$DEFAULT_STATIC_ROOT"
  chown -R "$user:$user" "$DEFAULT_ACME_CACHE_DIR" "$DEFAULT_STATIC_ROOT"
  mkdir -p "$(dirname "$repo_dir")"
  chown -R "$user:$user" "$(dirname "$repo_dir")"
}

clone_or_update_repo() {
  local user="$1"
  local repo_url="$2"
  local repo_dir="$3"
  say "Cloning/updating the repository"
  if [[ -d "$repo_dir/.git" ]]; then
    info "Repo already exists at $repo_dir. Pulling latest main..."
    sudo -u "$user" -H bash -lc "cd '$repo_dir' && git fetch --all --prune && git checkout main && git pull --ff-only"
  else
    sudo -u "$user" -H bash -lc "git clone '$repo_url' '$repo_dir'"
  fi
}

ensure_rustup() {
  local user="$1"
  say "Ensuring Rust toolchain for user '$user'"
  local cargo_path="/home/$user/.cargo/bin/cargo"
  if [[ -x "$cargo_path" ]]; then
    info "Cargo already installed for $user."
    return 0
  fi
  warn "Rust not found for $user. Installing rustup (stable)..."
  sudo -u "$user" -H bash -lc "curl https://sh.rustup.rs -sSf | sh -s -- -y"
  sudo -u "$user" -H bash -lc "source ~/.cargo/env && rustup default stable && rustup update"
}

build_release() {
  local user="$1"
  local repo_dir="$2"
  say "Building Luciuz (release)"
  sudo -u "$user" -H bash -lc "cd '$repo_dir' && source ~/.cargo/env && cargo build -p luciuz --release"
}

install_binary_cap() {
  local user="$1"
  local repo_dir="$2"
  local bin_path="$repo_dir/target/release/luciuz"
  [[ -x "$bin_path" ]] || die "Binary not found at: $bin_path (build failed?)"
  say "Setting CAP_NET_BIND_SERVICE on binary"
  setcap 'cap_net_bind_service=+ep' "$bin_path" || die "setcap failed"
  chown "$user:$user" "$bin_path"
  chmod 0755 "$bin_path"
}

write_default_index() {
  local root="$1"
  local index="$root/index.html"
  if [[ ! -f "$index" ]]; then
    cat >"$index" <<'HTML'
<!doctype html>
<html lang="en">
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Luciuz</title></head>
<body><h1>Luciuz is running</h1><p>Health: <code>/healthz</code></p></body>
</html>
HTML
  fi
}

write_config() {
  local config_path="$1"
  local server_profile="$2"
  local http_listen="$3"
  local https_listen="$4"
  local canonical_host="$5"
  local hsts="$6"
  local hsts_max_age="$7"
  local hsts_include_subdomains="$8"
  local hsts_preload="$9"
  local security_headers="${10}"
  local acme_enabled="${11}"
  local acme_prod="${12}"
  local acme_email="${13}"
  local acme_domains="${14}"
  local acme_cache_dir="${15}"
  local acme_challenge="${16}"
  local static_root="${17}"
  local static_index="${18}"
  local proxy_max_body="${19}"
  local proxy_prefix="${20}"
  local proxy_upstream="${21}"

  say "Writing Luciuz config: $config_path"
  install -m 0755 -d "$(dirname "$config_path")"
  {
    echo "[server]"
    echo "http_listen = \"${http_listen}\""
    echo "https_listen = \"${https_listen}\""
    echo "profile = \"${server_profile}\""
    echo "canonical_host = \"${canonical_host}\""
    echo "hsts = ${hsts}"
    echo "hsts_max_age = ${hsts_max_age}"
    echo "hsts_include_subdomains = ${hsts_include_subdomains}"
    echo "hsts_preload = ${hsts_preload}"
    echo "security_headers = ${security_headers}"
    echo ""
    echo "[acme]"
    echo "enabled = ${acme_enabled}"
    echo "prod = ${acme_prod}"
    echo "email = \"${acme_email}\""
    echo "domains = [${acme_domains}]"
    echo "cache_dir = \"${acme_cache_dir}\""
    echo "challenge = \"${acme_challenge}\""
    echo ""
    echo "[telemetry]"
    echo "json_logs = true"
    echo "log_level = \"info\""
    echo ""
    echo "[timeouts]"
    echo "handler_secs = 30"
    echo ""
    echo "[static_site]"
    echo "root = \"${static_root}\""
    echo "index = \"${static_index}\""
    echo ""
    echo "[proxy]"
    echo "max_body_bytes = ${proxy_max_body}"
    echo ""
    echo "[[proxy.routes]]"
    echo "prefix = \"${proxy_prefix}\""
    echo "upstream = \"${proxy_upstream}\""
  } >"$config_path"
  chmod 0644 "$config_path"
}

write_systemd() {
  local service_name="$1"
  local user="$2"
  local repo_dir="$3"
  local config_path="$4"
  local unit_path="/etc/systemd/system/${service_name}.service"
  local bin_path="${repo_dir}/target/release/luciuz"

  say "Writing systemd unit: $unit_path"
  cat >"$unit_path" <<UNIT
[Unit]
Description=Luciuz Web Server
After=network-online.target
Wants=network-online.target

[Service]
User=${user}
Group=${user}
WorkingDirectory=${repo_dir}
ExecStart=${bin_path} run -c ${config_path}

AmbientCapabilities=CAP_NET_BIND_SERVICE
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
NoNewPrivileges=true

Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target
UNIT

  systemctl daemon-reload
  systemctl enable "$service_name" >/dev/null
}

configure_ufw() {
  local allow_80="$1"
  say "Configuring UFW"
  ufw --force reset
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow OpenSSH
  ufw allow 443/tcp
  if [[ "$allow_80" == "y" ]]; then ufw allow 80/tcp; fi
  ufw --force enable
}

main() {
  ensure_root
  say "Luciuz Community - Ubuntu 24.04 installer (GitHub clone)"

  prompt REPO_URL "Git repository URL" "${REPO_URL_DEFAULT}"
  prompt SERVICE_NAME "Systemd service name" "${SERVICE_NAME_DEFAULT}"
  prompt SERVICE_USER "Dedicated system user" "${DEFAULT_USER}"
  prompt REPO_DIR "Installation directory (repo clone path)" "${DEFAULT_REPO_DIR}"
  prompt CONFIG_PATH "Config path" "${DEFAULT_CONFIG_PATH}"

  prompt DOMAIN_APEX "Apex domain (canonical host)" "luciuz.com"
  prompt_yesno USE_WWW "Also serve www.${DOMAIN_APEX} (recommended)" "y"
  prompt ACME_EMAIL "ACME email for Let's Encrypt" "admin@${DOMAIN_APEX}"

  prompt_yesno ACME_ENABLED "Enable integrated ACME (Let's Encrypt)" "y"
  if [[ "$ACME_ENABLED" == "y" ]]; then
    prompt_yesno ACME_PROD "Use Let's Encrypt PRODUCTION (not staging)" "y"
    prompt ACME_CHALLENGE "ACME challenge type: http-01 or tls-alpn-01" "tls-alpn-01"
  else
    ACME_PROD="n"
    ACME_CHALLENGE="http-01"
  fi

  prompt HTTPS_LISTEN "HTTPS listen address" "${DEFAULT_HTTPS_LISTEN}"
  HTTP_LISTEN="${DEFAULT_HTTP_LISTEN}"
  ALLOW_80="n"
  if [[ "$ACME_ENABLED" == "y" && "$ACME_CHALLENGE" == "http-01" ]]; then
    prompt HTTP_LISTEN "HTTP listen address (required for http-01)" "${DEFAULT_HTTP_LISTEN}"
    ALLOW_80="y"
  else
    prompt HTTP_LISTEN "HTTP listen address (empty to disable port 80)" ""
    if [[ -n "$HTTP_LISTEN" ]]; then ALLOW_80="y"; fi
  fi

  prompt SERVER_PROFILE "Server profile: static_site or public_api" "public_api"
  prompt_yesno SECURITY_HEADERS "Enable baseline security headers" "y"
  prompt_yesno HSTS "Enable HSTS on HTTPS" "y"
  if [[ "$HSTS" == "y" ]]; then
    prompt HSTS_MAX_AGE "HSTS max-age (seconds)" "${DEFAULT_HSTS_MAX_AGE}"
    prompt_yesno HSTS_INCLUDE_SUBDOMAINS "HSTS includeSubDomains" "n"
    prompt_yesno HSTS_PRELOAD "HSTS preload" "n"
  else
    HSTS_MAX_AGE="0"; HSTS_INCLUDE_SUBDOMAINS="n"; HSTS_PRELOAD="n"
  fi

  prompt STATIC_ROOT "Static site root directory" "${DEFAULT_STATIC_ROOT}"
  prompt STATIC_INDEX "Static site index filename" "index.html"

  prompt PROXY_MAX_BODY "Proxy max body bytes (uploads)" "${DEFAULT_PROXY_MAX_BODY}"
  prompt PROXY_PREFIX "Proxy route prefix" "${DEFAULT_PROXY_PREFIX}"
  prompt PROXY_UPSTREAM "Upstream base URL" "${DEFAULT_PROXY_UPSTREAM}"

  bool() { [[ "$1" == "y" ]] && echo "true" || echo "false"; }

  ACME_DOMAINS="\"${DOMAIN_APEX}\""
  if [[ "$USE_WWW" == "y" ]]; then ACME_DOMAINS="${ACME_DOMAINS}, \"www.${DOMAIN_APEX}\""; fi

  ensure_user "$SERVICE_USER"
  apt_install
  ensure_dirs "$SERVICE_USER" "$REPO_DIR"
  clone_or_update_repo "$SERVICE_USER" "$REPO_URL" "$REPO_DIR"
  ensure_rustup "$SERVICE_USER"
  build_release "$SERVICE_USER" "$REPO_DIR"
  install_binary_cap "$SERVICE_USER" "$REPO_DIR"

  mkdir -p "$DEFAULT_ACME_CACHE_DIR"
  chown -R "$SERVICE_USER:$SERVICE_USER" "$DEFAULT_ACME_CACHE_DIR"

  mkdir -p "$STATIC_ROOT"
  chown -R "$SERVICE_USER:$SERVICE_USER" "$STATIC_ROOT"
  write_default_index "$STATIC_ROOT"

  write_config \
    "$CONFIG_PATH" \
    "$SERVER_PROFILE" \
    "$HTTP_LISTEN" \
    "$HTTPS_LISTEN" \
    "$DOMAIN_APEX" \
    "$(bool "$HSTS")" \
    "$HSTS_MAX_AGE" \
    "$(bool "$HSTS_INCLUDE_SUBDOMAINS")" \
    "$(bool "$HSTS_PRELOAD")" \
    "$(bool "$SECURITY_HEADERS")" \
    "$(bool "$ACME_ENABLED")" \
    "$(bool "$ACME_PROD")" \
    "$ACME_EMAIL" \
    "$ACME_DOMAINS" \
    "$DEFAULT_ACME_CACHE_DIR" \
    "$ACME_CHALLENGE" \
    "$STATIC_ROOT" \
    "$STATIC_INDEX" \
    "$PROXY_MAX_BODY" \
    "$PROXY_PREFIX" \
    "$PROXY_UPSTREAM"

  chown "$SERVICE_USER:$SERVICE_USER" "$CONFIG_PATH"

  write_systemd "$SERVICE_NAME" "$SERVICE_USER" "$REPO_DIR" "$CONFIG_PATH"
  configure_ufw "$ALLOW_80"

  say "Starting service"
  systemctl restart "$SERVICE_NAME"

  say "Done!"
  info "Service: systemctl status ${SERVICE_NAME}"
  info "Logs:    journalctl -u ${SERVICE_NAME} -f --no-pager"
  info "Health:  curl -I https://${DOMAIN_APEX}/healthz"
}

main "$@"
