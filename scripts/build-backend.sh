#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_DIR="${AI_MONITOR_BACKEND_SRC:-/home/hzhy/ai-monitor-backend}"
OUT_DIR="${1:-$ROOT_DIR/.build/backend}"
GO_BIN="${GO_BIN:-$(command -v go || printf '%s' /home/hzhy/go/bin/go)}"

mkdir -p "$OUT_DIR"

export GOPATH="${GOPATH:-/home/hzhy/gopath}"
export GOPROXY="${GOPROXY:-https://goproxy.cn,direct}"

echo "[build-backend] src=$SRC_DIR"
echo "[build-backend] out=$OUT_DIR"

(
  cd "$SRC_DIR"
  "$GO_BIN" build -o "$OUT_DIR/ai-monitor-backend" .
)
