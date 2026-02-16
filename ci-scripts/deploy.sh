#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

MARKER_FILE=".deployed"

if [ -f "$MARKER_FILE" ]; then
  log_info "Already deployed (idempotent)."
  exit 0
fi

log_info "Starting deployment"
run bash -c 'echo "deployed at $(date -u)" > .deployed'
log_info "Deployment complete"
exit 0
