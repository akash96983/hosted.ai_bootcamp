#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

timestamp() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

# Structured logging: key=value format suitable for CI parsing
log() {
  local level="$1"; shift
  printf 'time=%s level=%s msg="%s"\n' "$(timestamp)" "$level" "$*"
}

log_info()  { log INFO "$*"; }
log_warn()  { log WARN "$*"; }
log_error() { log ERROR "$*"; }

on_error() {
  local lineno=${1:-?}
  log_error "Script failed at line=${lineno}";
  exit 1
}
trap 'on_error $LINENO' ERR

# Run a command with logging while keeping script idempotent-friendly
run() {
  log_info "Running: $*"
  if "$@"; then
    log_info "Succeeded: $*"
    return 0
  else
    log_error "Failed: $*"
    return 1
  fi
}
