#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="${AI_MONITOR_PYTHON_SRC:-/home/hzhy/ai-monitor-service}"
OUT_DIR="${1:-$ROOT_DIR/.build/python}"
PYTHON_BIN="${PYTHON_BIN:-python3}"

mkdir -p "$OUT_DIR"

echo "[build-python] src=$SRC_DIR"
echo "[build-python] out=$OUT_DIR"

rm -rf "$OUT_DIR/app"
mkdir -p "$OUT_DIR/app"
rsync -a \
  --exclude '__pycache__' \
  --exclude '.git' \
  --exclude 'venv' \
  --exclude 'snapshots' \
  "$SRC_DIR/" "$OUT_DIR/app/"

if [[ -d "$SRC_DIR/venv" ]]; then
  echo "[build-python] copy existing venv"
  rm -rf "$OUT_DIR/venv"
  cp -a "$SRC_DIR/venv" "$OUT_DIR/venv"
else
  echo "[build-python] build wheels from requirements.txt"
  mkdir -p "$OUT_DIR/wheels"
  "$PYTHON_BIN" -m pip wheel -r "$SRC_DIR/requirements.txt" -w "$OUT_DIR/wheels"
fi
