#!/usr/bin/env bash
set -Eeuo pipefail

APP_DIR="${APP_DIR:-$HOME/ct-amend-watch}"
PYTHON_BIN="${PYTHON_BIN:-$APP_DIR/.venv/bin/python}"
LOCK_FILE="${LOCK_FILE:-$APP_DIR/watch_amend.lock}"
LOG_DIR="${LOG_DIR:-$APP_DIR/logs}"
LOG_FILE="${LOG_FILE:-$LOG_DIR/watch_amend.log}"

mkdir -p "$LOG_DIR"

if [[ ! -x "$PYTHON_BIN" ]]; then
  echo "[$(date -Is)] ERROR: python not found at $PYTHON_BIN" >> "$LOG_FILE"
  exit 1
fi

cd "$APP_DIR"

if flock -n "$LOCK_FILE" "$PYTHON_BIN" "$APP_DIR/watch_amend.py" >> "$LOG_FILE" 2>&1; then
  exit 0
fi

rc=$?
if [[ $rc -eq 1 ]]; then
  echo "[$(date -Is)] INFO: skipped run because previous execution is still active" >> "$LOG_FILE"
  exit 0
fi

echo "[$(date -Is)] ERROR: watcher exited with code $rc" >> "$LOG_FILE"
exit "$rc"
