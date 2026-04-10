#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DB_PATH="${AI_MONITOR_DB_PATH:-/var/lib/ai-monitor/aimonitor.db}"
SCHEMA_SQL="${AI_MONITOR_SCHEMA_SQL:-$ROOT_DIR/sql/schema.sql}"
SEED_SQL="${AI_MONITOR_SEED_SQL:-$ROOT_DIR/sql/seed_base.sql}"
MIGRATE_ONLY="${1:-}"

install -d "$(dirname "$DB_PATH")"

if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "sqlite3 command not found" >&2
  exit 1
fi

sqlite3 "$DB_PATH" < "$SCHEMA_SQL"

if [[ "$MIGRATE_ONLY" != "--migrate-only" ]]; then
  sqlite3 "$DB_PATH" < "$SEED_SQL"
fi

echo "[init-db] db ready at $DB_PATH"
