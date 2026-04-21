#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="${AI_MONITOR_PYTHON_SRC:-/home/hzhy/ai-monitor-service}"
OUT_DIR="${1:-$ROOT_DIR/.build/python}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
COPY_VENV="${AI_MONITOR_COPY_VENV:-0}"
PIP_TIMEOUT="${AI_MONITOR_PIP_TIMEOUT:-120}"
FALLBACK_INDEX_URL="${AI_MONITOR_PIP_FALLBACK_INDEX_URL:-https://pypi.org/simple}"

mkdir -p "$OUT_DIR"

echo "[build-python] src=$SRC_DIR"
echo "[build-python] out=$OUT_DIR"

PIP_ARGS=(
  wheel
  --default-timeout "$PIP_TIMEOUT"
  -r "$SRC_DIR/requirements.txt"
  -w "$OUT_DIR/wheels"
)

build_wheels() {
  "$PYTHON_BIN" -m pip "$@"
}

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

set +e
BUILD_OUTPUT="$(build_wheels "${PIP_ARGS[@]}" 2>&1)"
BUILD_STATUS=$?
set -e
printf '%s\n' "$BUILD_OUTPUT"

if [[ "$BUILD_STATUS" -ne 0 ]]; then
  if [[ -n "${AI_MONITOR_PIP_INDEX_URL:-}" && "$BUILD_OUTPUT" == *"No matching distribution found for pyzmq"* ]]; then
    echo "[build-python] pyzmq not available from mirror, retry with fallback index: $FALLBACK_INDEX_URL"

    TMP_REQ_DIR="$(mktemp -d)"
    cleanup_tmp_req_dir() {
      rm -rf "$TMP_REQ_DIR"
    }
    trap cleanup_tmp_req_dir EXIT

    NON_PYZMQ_REQ="$TMP_REQ_DIR/requirements-no-pyzmq.txt"
    rg -v '^\s*pyzmq(\s|$)' "$SRC_DIR/requirements.txt" > "$NON_PYZMQ_REQ"

    rm -rf "$OUT_DIR/wheels"
    mkdir -p "$OUT_DIR/wheels"

    NON_PYZMQ_ARGS=(
      wheel
      --default-timeout "$PIP_TIMEOUT"
      -r "$NON_PYZMQ_REQ"
      -w "$OUT_DIR/wheels"
      --index-url "$AI_MONITOR_PIP_INDEX_URL"
    )

    if [[ -n "${AI_MONITOR_PIP_EXTRA_INDEX_URL:-}" ]]; then
      NON_PYZMQ_ARGS+=(--extra-index-url "$AI_MONITOR_PIP_EXTRA_INDEX_URL")
    fi

    if [[ -n "${AI_MONITOR_PIP_TRUSTED_HOST:-}" ]]; then
      NON_PYZMQ_ARGS+=(--trusted-host "$AI_MONITOR_PIP_TRUSTED_HOST")
    fi

    build_wheels "${NON_PYZMQ_ARGS[@]}"

    PYZMQ_ARGS=(
      wheel
      --default-timeout "$PIP_TIMEOUT"
      pyzmq
      -w "$OUT_DIR/wheels"
      --index-url "$FALLBACK_INDEX_URL"
    )

    echo "[build-python] download pyzmq from fallback index"
    build_wheels "${PYZMQ_ARGS[@]}"
  else
    exit "$BUILD_STATUS"
  fi
fi

if [[ "$COPY_VENV" == "1" && -d "$SRC_DIR/venv" ]]; then
  echo "[build-python] copy existing venv because AI_MONITOR_COPY_VENV=1"
  rm -rf "$OUT_DIR/venv"
  cp -a "$SRC_DIR/venv" "$OUT_DIR/venv"
else
  rm -rf "$OUT_DIR/venv"
fi
