#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="${AI_MONITOR_FRONTEND_SRC:-/home/hzhy/ai-monitor-frontend}"
OUT_DIR="${1:-$ROOT_DIR/.build/frontend}"
NPM_BIN="${NPM_BIN:-npm}"

mkdir -p "$OUT_DIR"

echo "[build-frontend] src=$SRC_DIR"
echo "[build-frontend] out=$OUT_DIR"

(
  cd "$SRC_DIR"
  "$NPM_BIN" run build
)

rm -rf "$OUT_DIR/dist"
cp -a "$SRC_DIR/dist" "$OUT_DIR/dist"
