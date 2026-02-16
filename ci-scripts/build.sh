#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

ARTIFACT_DIR="build"

if [ -d "$ARTIFACT_DIR" ] && [ -f "$ARTIFACT_DIR/artifact.txt" ]; then
  log_info "Build artifact exists; skipping (idempotent)"
  exit 0
fi

log_info "Starting build"
run mkdir -p "$ARTIFACT_DIR"
run bash -c 'echo "artifact: built at $(date -u)" > "build/artifact.txt"'
log_info "Build complete"
exit 0
