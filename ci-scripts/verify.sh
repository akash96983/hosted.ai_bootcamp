#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

CONFIG_FILE="${1:-$(dirname "${BASH_SOURCE[0]}")/verify.conf}"
failures=0

log_info "Using config: ${CONFIG_FILE}"

check_http() {
  local url="$1"
  if command -v curl >/dev/null 2>&1 && curl -sSf --max-time 5 "$url" -o /dev/null; then
    log_info "HTTP OK: $url"
    return 0
  else
    log_error "HTTP FAILED: $url"
    failures=$((failures+1))
    return 1
  fi
}

check_tcp() {
  local host="$1" port="$2"
  if command -v nc >/dev/null 2>&1; then
    if nc -z -w5 "$host" "$port"; then
      log_info "TCP OK: ${host}:${port}"
      return 0
    else
      log_error "TCP FAILED: ${host}:${port}"
      failures=$((failures+1))
      return 1
    fi
  else
    # fallback: try /dev/tcp (bash)
    if timeout 5 bash -c "</dev/tcp/${host}/${port}" >/dev/null 2>&1; then
      log_info "TCP OK (fallback): ${host}:${port}"
      return 0
    else
      log_error "TCP FAILED (fallback): ${host}:${port}"
      failures=$((failures+1))
      return 1
    fi
  fi
}

check_cmd() {
  local cmd="$*"
  if bash -c "$cmd" >/dev/null 2>&1; then
    log_info "CMD OK: $cmd"
    return 0
  else
    log_error "CMD FAILED: $cmd"
    failures=$((failures+1))
    return 1
  fi
}

if [ ! -f "$CONFIG_FILE" ]; then
  log_error "Config file not found: $CONFIG_FILE"
  exit 3
fi

while IFS= read -r line || [ -n "$line" ]; do
  line="$(echo "$line" | sed 's/^\s*//;s/\s*$//')"
  [ -z "$line" ] && continue
  case "$line" in
    \#*) continue ;;
    HTTP=*)
      url="${line#HTTP=}"; check_http "$url" ;;
    TCP=*)
      hostport="${line#TCP=}"; host="${hostport%%:*}"; port="${hostport##*:}"; check_tcp "$host" "$port" ;;
    CMD=*)
      cmd="${line#CMD=}"; check_cmd "$cmd" ;;
    *)
      log_warn "Unknown config line, skipping: $line" ;;
  esac
done < "$CONFIG_FILE"

if [ "$failures" -ne 0 ]; then
  log_error "Verification completed: ${failures} check(s) failed"
  exit 2
else
  log_info "Verification completed: all checks passed"
  exit 0
fi
