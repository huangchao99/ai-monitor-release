#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
  echo "[install-ai-monitor] please run as root or via sudo" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARCHIVE_PATH="${1:-}"

usage() {
  cat <<'EOF'
Usage:
  sudo ./install-ai-monitor.sh <ai-monitor-release-*.tar.gz>

Behavior:
  1. Extract the release archive to a temporary directory
  2. Run the packaged install.sh
  3. Run the packaged init-db.sh
  4. Install missing /etc/ai-monitor config files only
  5. Install systemd unit files
  6. Install nginx site config to /etc/nginx/sites-available/ai-monitor.conf
  7. Start services when dependencies are available
  8. Run the packaged health-check.sh when the full stack is started
EOF
}

if [[ -z "$ARCHIVE_PATH" ]]; then
  mapfile -t archives < <(find "$SCRIPT_DIR" -maxdepth 1 -type f \( -name 'ai-monitor-release-*.tar.gz' -o -name '*.tgz' \) | sort)
  if [[ "${#archives[@]}" -eq 1 ]]; then
    ARCHIVE_PATH="${archives[0]}"
  else
    usage >&2
    if [[ "${#archives[@]}" -gt 1 ]]; then
      echo "[install-ai-monitor] found multiple archives in $SCRIPT_DIR, please specify one explicitly" >&2
    else
      echo "[install-ai-monitor] no archive found in $SCRIPT_DIR" >&2
    fi
    exit 1
  fi
fi

if [[ "$ARCHIVE_PATH" != /* ]]; then
  ARCHIVE_PATH="$SCRIPT_DIR/$ARCHIVE_PATH"
fi

if [[ ! -f "$ARCHIVE_PATH" ]]; then
  echo "[install-ai-monitor] archive not found: $ARCHIVE_PATH" >&2
  exit 1
fi

for cmd in tar rsync systemctl sqlite3 curl; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "[install-ai-monitor] required command not found: $cmd" >&2
    exit 1
  fi
done

TMP_DIR="$(mktemp -d /tmp/ai-monitor-install.XXXXXX)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

HEALTH_CHECK_RETRIES="${AI_MONITOR_HEALTH_CHECK_RETRIES:-10}"
HEALTH_CHECK_DELAY_SEC="${AI_MONITOR_HEALTH_CHECK_DELAY_SEC:-3}"

echo "[install-ai-monitor] extracting $ARCHIVE_PATH"
tar -xzf "$ARCHIVE_PATH" -C "$TMP_DIR"

PACKAGE_DIR="$(find "$TMP_DIR" -mindepth 1 -maxdepth 3 -type f -path '*/scripts/install.sh' -printf '%h\n' | sed 's#/scripts$##' | head -n 1)"
if [[ -z "$PACKAGE_DIR" ]]; then
  echo "[install-ai-monitor] failed to locate packaged install.sh in archive" >&2
  exit 1
fi

if [[ ! -x "$PACKAGE_DIR/scripts/install.sh" ]]; then
  chmod +x "$PACKAGE_DIR/scripts/install.sh"
fi
if [[ ! -x "$PACKAGE_DIR/scripts/init-db.sh" ]]; then
  chmod +x "$PACKAGE_DIR/scripts/init-db.sh"
fi
if [[ ! -x "$PACKAGE_DIR/scripts/health-check.sh" ]]; then
  chmod +x "$PACKAGE_DIR/scripts/health-check.sh"
fi

echo "[install-ai-monitor] running packaged install.sh"
"$PACKAGE_DIR/scripts/install.sh"

echo "[install-ai-monitor] running packaged init-db.sh"
"$PACKAGE_DIR/scripts/init-db.sh"

if [[ -f "$PACKAGE_DIR/VERSION" ]]; then
  VERSION="$(tr -d '[:space:]' < "$PACKAGE_DIR/VERSION")"
else
  VERSION="$(tr -d '[:space:]' < "$PACKAGE_DIR/manifest/VERSION")"
fi

RELEASES_DIR="${AI_MONITOR_RELEASES_DIR:-/opt/ai-monitor/releases}"
CURRENT_LINK="${AI_MONITOR_CURRENT_LINK:-/opt/ai-monitor/current}"
ETC_DIR="${AI_MONITOR_ETC_DIR:-/etc/ai-monitor}"
NGINX_AVAILABLE_DIR="${AI_MONITOR_NGINX_SITES_AVAILABLE_DIR:-/etc/nginx/sites-available}"
NGINX_ENABLED_DIR="${AI_MONITOR_NGINX_SITES_ENABLED_DIR:-/etc/nginx/sites-enabled}"
SYSTEMD_DIR="${AI_MONITOR_SYSTEMD_DIR:-/etc/systemd/system}"
TARGET_DIR="$RELEASES_DIR/$VERSION"

install_if_missing() {
  local src="$1"
  local dest="$2"
  if [[ ! -e "$dest" ]]; then
    install -d "$(dirname "$dest")"
    cp -a "$src" "$dest"
    echo "[install-ai-monitor] installed missing config $dest"
  else
    echo "[install-ai-monitor] keep existing config $dest"
  fi
}

run_health_check_with_retry() {
  local attempt=1
  while (( attempt <= HEALTH_CHECK_RETRIES )); do
    echo "[install-ai-monitor] health-check attempt ${attempt}/${HEALTH_CHECK_RETRIES}"
    if "$TARGET_DIR/scripts/health-check.sh"; then
      return 0
    fi

    if (( attempt == HEALTH_CHECK_RETRIES )); then
      return 1
    fi

    echo "[install-ai-monitor] health-check not ready, retry after ${HEALTH_CHECK_DELAY_SEC}s"
    sleep "$HEALTH_CHECK_DELAY_SEC"
    ((attempt++))
  done
}

install_if_missing "$TARGET_DIR/config/backend.env.example" "$ETC_DIR/backend.env"
install_if_missing "$TARGET_DIR/config/python.env.example" "$ETC_DIR/python.env"
install_if_missing "$TARGET_DIR/config/infer.env.example" "$ETC_DIR/infer.env"
install_if_missing "$TARGET_DIR/config/zlm.env.example" "$ETC_DIR/zlm.env"
install_if_missing "$TARGET_DIR/config/server.json.example" "$ETC_DIR/infer/server.json"

echo "[install-ai-monitor] installing systemd units"
install -d "$SYSTEMD_DIR"
for unit in ai-monitor-backend.service ai-monitor-python.service infer-server.service zlmediakit.service; do
  install -m 0644 "$TARGET_DIR/systemd/$unit" "$SYSTEMD_DIR/$unit"
done
systemctl daemon-reload

echo "[install-ai-monitor] installing nginx site config"
install -d "$NGINX_AVAILABLE_DIR" "$NGINX_ENABLED_DIR"
if [[ ! -e "$NGINX_AVAILABLE_DIR/ai-monitor.conf" ]]; then
  install -m 0644 "$TARGET_DIR/nginx/ai-monitor.conf.example" "$NGINX_AVAILABLE_DIR/ai-monitor.conf"
  echo "[install-ai-monitor] installed missing nginx site config"
else
  echo "[install-ai-monitor] keep existing nginx site config"
fi
ln -sfn "$NGINX_AVAILABLE_DIR/ai-monitor.conf" "$NGINX_ENABLED_DIR/ai-monitor.conf"

if [[ -L "$NGINX_ENABLED_DIR/default" || -e "$NGINX_ENABLED_DIR/default" ]]; then
  rm -f "$NGINX_ENABLED_DIR/default"
  echo "[install-ai-monitor] disabled default nginx site: $NGINX_ENABLED_DIR/default"
fi

if command -v nginx >/dev/null 2>&1; then
  nginx -t
fi
systemctl enable nginx
systemctl restart nginx

service_started=0
health_check_ready=0
zlm_ready=0

if [[ -f "$ETC_DIR/zlm.env" ]]; then
  set +u
  # shellcheck disable=SC1090
  source "$ETC_DIR/zlm.env"
  set -u
fi

if [[ -n "${AI_MONITOR_ZLM_BIN:-}" && -x "${AI_MONITOR_ZLM_BIN:-}" && -n "${AI_MONITOR_ZLM_CONFIG_PATH:-}" && -f "${AI_MONITOR_ZLM_CONFIG_PATH:-}" ]]; then
  zlm_ready=1
fi

if [[ "$zlm_ready" -eq 1 ]]; then
  echo "[install-ai-monitor] ZLMediaKit detected, enabling application services"
  systemctl enable zlmediakit.service infer-server.service ai-monitor-python.service ai-monitor-backend.service
  systemctl restart zlmediakit.service
  systemctl restart infer-server.service
  systemctl restart ai-monitor-python.service
  systemctl restart ai-monitor-backend.service
  service_started=1
  health_check_ready=1
else
  cat <<EOF
[install-ai-monitor] ZLMediaKit not ready, skipped starting:
  - zlmediakit.service
  - infer-server.service
  - ai-monitor-python.service
  - ai-monitor-backend.service
[install-ai-monitor] expected:
  AI_MONITOR_ZLM_BIN executable
  AI_MONITOR_ZLM_CONFIG_PATH existing file
[install-ai-monitor] current link: $CURRENT_LINK
[install-ai-monitor] current zlm env: $ETC_DIR/zlm.env
EOF
fi

if [[ "$health_check_ready" -eq 1 ]]; then
  echo "[install-ai-monitor] running packaged health-check.sh with retry"
  run_health_check_with_retry
else
  echo "[install-ai-monitor] skipped health-check because the full stack was not started"
fi

cat <<EOF
[install-ai-monitor] version: $VERSION
[install-ai-monitor] release dir: $TARGET_DIR
[install-ai-monitor] current link: $CURRENT_LINK
[install-ai-monitor] nginx site: $NGINX_AVAILABLE_DIR/ai-monitor.conf
[install-ai-monitor] services started: $service_started
EOF
