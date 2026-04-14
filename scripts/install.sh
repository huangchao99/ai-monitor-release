#!/usr/bin/env bash
set -euo pipefail

PACKAGE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -f "$PACKAGE_DIR/VERSION" ]]; then
  VERSION="$(tr -d '[:space:]' < "$PACKAGE_DIR/VERSION")"
else
  VERSION="$(tr -d '[:space:]' < "$PACKAGE_DIR/manifest/VERSION")"
fi

RELEASES_DIR="${AI_MONITOR_RELEASES_DIR:-/opt/ai-monitor/releases}"
CURRENT_LINK="${AI_MONITOR_CURRENT_LINK:-/opt/ai-monitor/current}"
ETC_DIR="${AI_MONITOR_ETC_DIR:-/etc/ai-monitor}"
DATA_DIR="${AI_MONITOR_DATA_DIR:-/var/lib/ai-monitor}"
TARGET_DIR="$RELEASES_DIR/$VERSION"
PYTHON_BIN="${AI_MONITOR_TARGET_PYTHON_BIN:-python3}"
PYTHON_APP_DIR="$TARGET_DIR/python/app"
PYTHON_VENV_DIR="$TARGET_DIR/python/venv"
PYTHON_WHEELS_DIR="$TARGET_DIR/python/wheels"
PYTHON_REQUIREMENTS="$PYTHON_APP_DIR/requirements.txt"

install -d "$TARGET_DIR" "$ETC_DIR/infer" "$DATA_DIR/snapshots" "$DATA_DIR/infer"
rsync -a --delete "$PACKAGE_DIR/" "$TARGET_DIR/"

install_if_missing() {
  local src="$1"
  local dest="$2"
  if [[ ! -e "$dest" ]]; then
    install -d "$(dirname "$dest")"
    cp -a "$src" "$dest"
  fi
}

install_if_missing "$TARGET_DIR/config/backend.env.example" "$ETC_DIR/backend.env"
install_if_missing "$TARGET_DIR/config/python.env.example" "$ETC_DIR/python.env"
install_if_missing "$TARGET_DIR/config/infer.env.example" "$ETC_DIR/infer.env"
install_if_missing "$TARGET_DIR/config/zlm.env.example" "$ETC_DIR/zlm.env"
install_if_missing "$TARGET_DIR/config/server.json.example" "$ETC_DIR/infer/server.json"

if [[ -d "$PYTHON_WHEELS_DIR" && -f "$PYTHON_REQUIREMENTS" ]]; then
  echo "[install] create python venv in $PYTHON_VENV_DIR"
  rm -rf "$PYTHON_VENV_DIR"
  "$PYTHON_BIN" -m venv "$PYTHON_VENV_DIR"
  "$PYTHON_VENV_DIR/bin/pip" install \
    --no-index \
    --find-links "$PYTHON_WHEELS_DIR" \
    -r "$PYTHON_REQUIREMENTS"
fi

ln -sfn "$TARGET_DIR" "$CURRENT_LINK"

cat <<EOF
[install] version: $VERSION
[install] release dir: $TARGET_DIR
[install] current link: $CURRENT_LINK
[install] etc dir: $ETC_DIR
[install] data dir: $DATA_DIR
EOF
