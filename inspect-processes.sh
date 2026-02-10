#!/usr/bin/env bash
# Minimal script: show snapshot of processes for demo
set -euo pipefail

echo "== ps aux (first 30 lines) =="
ps aux | sed -n '1,30p'

echo "\n== ps -ef (first 30 lines) =="
ps -ef | sed -n '1,30p'

# Non-interactive top snapshot if available
if command -v top >/dev/null 2>&1; then
  echo "\n== top snapshot (5 iterations, 0.5s interval) =="
  # Use batch mode to capture a short snapshot
  top -b -n 5 -d 0.5 | sed -n '1,40p'
else
  echo "\n[top not available]"
fi

# Show PID 1 details if running inside a container
if [[ -r /proc/1/status ]]; then
  echo "\n== PID 1 status =="
  sed -n '1,20p' /proc/1/status || true
fi
