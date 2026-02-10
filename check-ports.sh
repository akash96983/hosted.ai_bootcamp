#!/usr/bin/env bash
# Minimal script: list listening TCP ports and owning processes
set -euo pipefail

echo "== ss -ltnp (listening TCP ports) =="
if command -v ss >/dev/null 2>&1; then
  ss -ltnp 2>/dev/null || echo "ss ran but returned non-zero"
else
  echo "ss not available"
fi

echo "\n== lsof -i -P -n | grep LISTEN (if available) =="
if command -v lsof >/dev/null 2>&1; then
  lsof -i -P -n | grep LISTEN || true
else
  echo "lsof not available"
fi

# Fallback to netstat if present
echo "\n== netstat -tulpn (if available) =="
if command -v netstat >/dev/null 2>&1; then
  netstat -tulpn 2>/dev/null || echo "netstat ran but returned non-zero"
else
  echo "netstat not available"
fi
