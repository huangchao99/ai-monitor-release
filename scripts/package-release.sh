#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSION="${1:-$(tr -d '[:space:]' < "$ROOT_DIR/manifest/VERSION")}"
DIST_DIR="${AI_MONITOR_RELEASE_DIST:-$ROOT_DIR/dist}"
PKG_DIR="$DIST_DIR/ai-monitor-release-$VERSION"

MODELS_SRC="${AI_MONITOR_MODELS_SRC:-/home/hzhy/models}"
AUDIO_SRC="${AI_MONITOR_AUDIO_SRC:-/home/hzhy/Audio}"

mkdir -p "$DIST_DIR"
rm -rf "$PKG_DIR"

"$ROOT_DIR/scripts/build-backend.sh"
"$ROOT_DIR/scripts/build-frontend.sh"
"$ROOT_DIR/scripts/build-python.sh"
"$ROOT_DIR/scripts/build-infer.sh"

mkdir -p \
  "$PKG_DIR/bin" \
  "$PKG_DIR/python" \
  "$PKG_DIR/frontend" \
  "$PKG_DIR/models" \
  "$PKG_DIR/audio" \
  "$PKG_DIR/sql" \
  "$PKG_DIR/config" \
  "$PKG_DIR/systemd" \
  "$PKG_DIR/scripts" \
  "$PKG_DIR/manifest" \
  "$PKG_DIR/docs" \
  "$PKG_DIR/nginx"

cp -a "$ROOT_DIR/.build/backend/ai-monitor-backend" "$PKG_DIR/bin/"
cp -a "$ROOT_DIR/.build/infer/infer_server" "$PKG_DIR/bin/"
cp -a "$ROOT_DIR/.build/frontend/dist" "$PKG_DIR/frontend/dist"
cp -a "$ROOT_DIR/.build/python/app" "$PKG_DIR/python/app"

if [[ -d "$ROOT_DIR/.build/python/venv" ]]; then
  cp -a "$ROOT_DIR/.build/python/venv" "$PKG_DIR/python/venv"
fi

if [[ -d "$ROOT_DIR/.build/python/wheels" ]]; then
  cp -a "$ROOT_DIR/.build/python/wheels" "$PKG_DIR/python/wheels"
fi

if [[ -d "$MODELS_SRC" ]]; then
  cp -a "$MODELS_SRC/." "$PKG_DIR/models/"
fi

if [[ -d "$AUDIO_SRC" ]]; then
  cp -a "$AUDIO_SRC/." "$PKG_DIR/audio/"
fi

cp -a "$ROOT_DIR/sql/." "$PKG_DIR/sql/"
cp -a "$ROOT_DIR/config/." "$PKG_DIR/config/"
cp -a "$ROOT_DIR/systemd/." "$PKG_DIR/systemd/"
cp -a "$ROOT_DIR/scripts/." "$PKG_DIR/scripts/"
cp -a "$ROOT_DIR/manifest/." "$PKG_DIR/manifest/"
cp -a "$ROOT_DIR/docs/." "$PKG_DIR/docs/"
cp -a "$ROOT_DIR/nginx/." "$PKG_DIR/nginx/"

printf '%s\n' "$VERSION" > "$PKG_DIR/VERSION"
date -u +"BUILD_TIME_UTC=%Y-%m-%dT%H:%M:%SZ" > "$PKG_DIR/manifest/build-info.env"
(
  cd "$PKG_DIR"
  find . -type f \
    ! -path './manifest/checksums.sha256' \
    -print0 | sort -z | xargs -0 sha256sum > manifest/checksums.sha256
)

echo "[package-release] created $PKG_DIR"
