#!/usr/bin/env bash
set -euo pipefail

TARGET_VERSION="${1:-}"
RELEASES_DIR="${AI_MONITOR_RELEASES_DIR:-/opt/ai-monitor/releases}"
CURRENT_LINK="${AI_MONITOR_CURRENT_LINK:-/opt/ai-monitor/current}"
SKIP_SYSTEMCTL="${AI_MONITOR_SKIP_SYSTEMCTL:-0}"

if [[ -z "$TARGET_VERSION" ]]; then
  echo "usage: $0 <version>" >&2
  exit 1
fi

TARGET_DIR="$RELEASES_DIR/$TARGET_VERSION"
if [[ ! -d "$TARGET_DIR" ]]; then
  echo "target release not found: $TARGET_DIR" >&2
  exit 1
fi

if [[ "$SKIP_SYSTEMCTL" != "1" ]] && command -v systemctl >/dev/null 2>&1; then
  systemctl stop ai-monitor-backend.service || true
  systemctl stop ai-monitor-python.service || true
  systemctl stop infer-server.service || true
  systemctl stop zlmediakit.service || true
fi

ln -sfn "$TARGET_DIR" "$CURRENT_LINK"

if [[ "$SKIP_SYSTEMCTL" != "1" ]] && command -v systemctl >/dev/null 2>&1; then
  systemctl start zlmediakit.service
  systemctl start infer-server.service
  systemctl start ai-monitor-python.service
  systemctl start ai-monitor-backend.service
fi

echo "[rollback] current -> $TARGET_DIR"
