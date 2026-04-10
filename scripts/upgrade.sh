#!/usr/bin/env bash
set -euo pipefail

PACKAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ETC_DIR="${AI_MONITOR_ETC_DIR:-/etc/ai-monitor}"
DATA_DIR="${AI_MONITOR_DATA_DIR:-/var/lib/ai-monitor}"
BACKUP_DIR="${AI_MONITOR_BACKUP_DIR:-$DATA_DIR/backups}"
DB_PATH="${AI_MONITOR_DB_PATH:-$DATA_DIR/aimonitor.db}"
SKIP_SYSTEMCTL="${AI_MONITOR_SKIP_SYSTEMCTL:-0}"

install -d "$BACKUP_DIR"

if [[ -f "$DB_PATH" ]]; then
  ts="$(date +%Y%m%d-%H%M%S)"
  cp -a "$DB_PATH" "$BACKUP_DIR/aimonitor-$ts.db"
  echo "[upgrade] backup created: $BACKUP_DIR/aimonitor-$ts.db"
fi

if [[ "$SKIP_SYSTEMCTL" != "1" ]] && command -v systemctl >/dev/null 2>&1; then
  systemctl stop ai-monitor-backend.service || true
  systemctl stop ai-monitor-python.service || true
  systemctl stop infer-server.service || true
  systemctl stop zlmediakit.service || true
fi

"$PACKAGE_DIR/scripts/install.sh"

if [[ -x "$PACKAGE_DIR/scripts/init-db.sh" ]]; then
  "$PACKAGE_DIR/scripts/init-db.sh" --migrate-only
fi

if [[ "$SKIP_SYSTEMCTL" != "1" ]] && command -v systemctl >/dev/null 2>&1; then
  systemctl daemon-reload
  systemctl start zlmediakit.service
  systemctl start infer-server.service
  systemctl start ai-monitor-python.service
  systemctl start ai-monitor-backend.service
fi

"$PACKAGE_DIR/scripts/health-check.sh"
