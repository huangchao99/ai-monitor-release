#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="${AI_MONITOR_PYTHON_SRC:-/home/hzhy/ai-monitor-service}"
OUT_DIR="${1:-$ROOT_DIR/.build/python}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
COPY_VENV="${AI_MONITOR_COPY_VENV:-0}"
PIP_TIMEOUT="${AI_MONITOR_PIP_TIMEOUT:-120}"

mkdir -p "$OUT_DIR"

echo "[build-python] src=$SRC_DIR"
echo "[build-python] out=$OUT_DIR"

PIP_ARGS=(
  wheel
  --default-timeout "$PIP_TIMEOUT"
  -r "$SRC_DIR/requirements.txt"
  -w "$OUT_DIR/wheels"
)

if [[ -n "${AI_MONITOR_PIP_INDEX_URL:-}" ]]; then
  PIP_ARGS+=(--index-url "$AI_MONITOR_PIP_INDEX_URL")
fi

if [[ -n "${AI_MONITOR_PIP_EXTRA_INDEX_URL:-}" ]]; then
  PIP_ARGS+=(--extra-index-url "$AI_MONITOR_PIP_EXTRA_INDEX_URL")
fi

if [[ -n "${AI_MONITOR_PIP_TRUSTED_HOST:-}" ]]; then
  PIP_ARGS+=(--trusted-host "$AI_MONITOR_PIP_TRUSTED_HOST")
fi

rm -rf "$OUT_DIR/app"
mkdir -p "$OUT_DIR/app"
rsync -a \
  --exclude '__pycache__' \
  --exclude '.git' \
  --exclude 'venv' \
  --exclude 'snapshots' \
  "$SRC_DIR/" "$OUT_DIR/app/"

echo "[build-python] build wheels from requirements.txt"
rm -rf "$OUT_DIR/wheels"
mkdir -p "$OUT_DIR/wheels"
"$PYTHON_BIN" -m pip "${PIP_ARGS[@]}"

if [[ "$COPY_VENV" == "1" && -d "$SRC_DIR/venv" ]]; then
  echo "[build-python] copy existing venv because AI_MONITOR_COPY_VENV=1"
  rm -rf "$OUT_DIR/venv"
  cp -a "$SRC_DIR/venv" "$OUT_DIR/venv"
else
  rm -rf "$OUT_DIR/venv"
fi
