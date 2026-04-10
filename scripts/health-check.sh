#!/usr/bin/env bash
set -euo pipefail

BACKEND_URL="${AI_MONITOR_BACKEND_HEALTH_URL:-http://127.0.0.1:8090/api/health}"
PYTHON_URL="${AI_MONITOR_PYTHON_HEALTH_URL:-http://127.0.0.1:9500/api/health}"
INFER_URL="${AI_MONITOR_INFER_HEALTH_URL:-http://127.0.0.1:8080/api/status}"
ZLM_URL="${AI_MONITOR_ZLM_HEALTH_URL:-http://127.0.0.1:80/}"
PUBLIC_URL="${AI_MONITOR_PUBLIC_URL:-http://127.0.0.1/}"

check() {
  local name="$1"
  local url="$2"
  echo "[health-check] $name -> $url"
  curl --fail --silent --show-error "$url" >/dev/null
}

check "backend" "$BACKEND_URL"
check "python" "$PYTHON_URL"
check "infer" "$INFER_URL"
check "zlm" "$ZLM_URL"
check "public" "$PUBLIC_URL"

echo "[health-check] all checks passed"
