#!/usr/bin/env bash

# Simple Docker automation - bare minimum to meet the task
# Provides: build, tag, run, stop commands
# Safety: set -euo pipefail, quoted variables, basic validation
# Exit codes: 0 ok, 1 general, 2 docker not found, 3 docker daemon not running, 4 invalid args, 5 build failed, 6 run failed

set -euo pipefail

# Helpers
log() { printf "[INFO] %s\n" "$*" >&2; }
err() { printf "[ERROR] %s\n" "$*" >&2; }

# Validate docker present and daemon running
validate_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    err "docker command not found"
    exit 2
  fi
  if ! docker info >/dev/null 2>&1; then
    err "docker daemon not running or not accessible"
    exit 3
  fi
}

usage() {
  cat <<EOF
Usage: $0 <command> [args]

Commands:
  build IMAGE[:TAG] [DOCKERFILE]   Build image (default Dockerfile)
  tag SOURCE_IMAGE TARGET_IMAGE    Tag source as target
  run IMAGE CONTAINER_NAME [PORT]  Run container (optional PORT like 8080:80)
  stop CONTAINER_NAME              Stop and remove a container
  help                             Show this message

Examples:
  $0 build myapp:1.0 Dockerfile
  $0 tag myapp:1.0 myapp:latest
  $0 run myapp:1.0 myapp-runner 8080:3000
  $0 stop myapp-runner
EOF
}

# Minimal validations
require_arg() {
  local val="$1" msg="$2"
  if [[ -z "${val:-}" ]]; then
    err "${msg}"
    usage
    exit 4
  fi
}

# Build function
cmd_build() {
  local image="$1"
  local dockerfile="${2:-Dockerfile}"
  require_arg "${image}" "build requires IMAGE[:TAG]"
  if [[ ! -f "${dockerfile}" ]]; then
    err "Dockerfile not found: ${dockerfile}"
    exit 4
  fi
  log "Building ${image} using ${dockerfile}"
  if docker build -t "${image}" -f "${dockerfile}" .; then
    log "Built ${image}"
  else
    err "Build failed for ${image}"
    exit 5
  fi
}

# Tag function
cmd_tag() {
  local src="$1" dst="$2"
  require_arg "${src}" "tag requires SOURCE_IMAGE"
  require_arg "${dst}" "tag requires TARGET_IMAGE"
  log "Tagging: ${src} -> ${dst}"
  if docker tag "${src}" "${dst}"; then
    log "Tagged ${dst}"
  else
    err "Tag failed"
    exit 1
  fi
}

# Run function
cmd_run() {
  local image="$1" name="$2" port="${3:-}"
  require_arg "${image}" "run requires IMAGE"
  require_arg "${name}" "run requires CONTAINER_NAME"
  local cmd=(docker run -d --rm --name "${name}")
  if [[ -n "${port}" ]]; then
    cmd+=( -p "${port}" )
  fi
  cmd+=( "${image}" )
  log "Running container ${name} from ${image}"
  if container_id="$("${cmd[@]}")"; then
    log "Started ${container_id}"
    printf "%s\n" "${container_id}"
  else
    err "Failed to start container ${name}"
    exit 6
  fi
}

# Stop function
cmd_stop() {
  local name="$1"
  require_arg "${name}" "stop requires CONTAINER_NAME"
  if docker ps -a --format '{{.Names}}' | grep -q "^${name}$"; then
    log "Stopping ${name}"
    docker stop "${name}" >/dev/null || true
    docker rm "${name}" >/dev/null || true
    log "Stopped and removed ${name}"
  else
    log "No container named ${name} exists"
  fi
}

# Main
main() {
  validate_docker
  local cmd="${1:-help}"
  shift || true
  case "${cmd}" in
    build) cmd_build "$@" ;;
    tag)   cmd_tag "$@" ;;
    run)   cmd_run "$@" ;;
    stop)  cmd_stop "$@" ;;
    help|-h|--help) usage ;;
    *) err "Unknown command: ${cmd}"; usage; exit 4 ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
