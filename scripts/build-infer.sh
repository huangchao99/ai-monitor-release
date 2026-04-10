#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="${AI_MONITOR_INFER_SRC:-/home/hzhy/infer-server/infer-server}"
OUT_DIR="${1:-$ROOT_DIR/.build/infer}"
CMAKE_BIN="${CMAKE_BIN:-cmake}"

mkdir -p "$OUT_DIR"

if [[ ! -x "$SRC_DIR/build/infer_server" ]]; then
  echo "[build-infer] infer_server not found, running cmake build"
  "$CMAKE_BIN" -S "$SRC_DIR" -B "$SRC_DIR/build"
  "$CMAKE_BIN" --build "$SRC_DIR/build" --target infer_server -j"$(nproc)"
fi

cp -a "$SRC_DIR/build/infer_server" "$OUT_DIR/infer_server"
