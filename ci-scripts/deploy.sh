#!/usr/bin/env bash
# Task 86 & 87: Hardened Deployment with Safety & Rollback
set -euo pipefail
IFS=$'\n\t'
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

MARKER_FILE=".deployed"
BACKUP_FILE=".deployed.backup"

# SAFETY CHECK 1: Verify environment
if [ -z "${KUBECONFIG:-}" ] && ! kubectl cluster-info &>/dev/null; then
  log_error "ERROR: Kubernetes cluster not accessible"
  exit 1
fi
log_info "✓ Kubernetes cluster accessible"

# SAFETY CHECK 2: Backup previous deployment state
if [ -f "$MARKER_FILE" ]; then
  log_info "Created backup of previous deployment state"
  cp "$MARKER_FILE" "$BACKUP_FILE"
fi

# SAFETY CHECK 3: Validate deployment manifests exist
if [ ! -d "kubectl-scripts/manifests" ]; then
  log_error "ERROR: Manifest directory not found"
  exit 1
fi
log_info "✓ Manifests directory found"

# MAIN DEPLOYMENT
log_info "Starting hardened deployment..."
{
  # Apply manifests with server-side validation
  kubectl apply -f kubectl-scripts/manifests/ --validate=strict
  
  # Wait for rollout completion
  kubectl rollout status deployment/nginx-deployment -n default --timeout=300s
  
  # Verify deployment
  READY=$(kubectl get deployment nginx-deployment -o jsonpath='{.status.readyReplicas}')
  DESIRED=$(kubectl get deployment nginx-deployment -o jsonpath='{.spec.replicas}')
  
  if [ "$READY" != "$DESIRED" ]; then
    log_error "ERROR: Not all pods ready ($READY/$DESIRED)"
    exit 1
  fi
  
  # Record success
  echo "deployed at $(date -u)" > "$MARKER_FILE"
  log_info "✓ Deployment successful - all pods ready"
} || {
  # ROLLBACK ON FAILURE
  log_error "Deployment failed - initiating rollback..."
  if [ -f "$BACKUP_FILE" ]; then
    kubectl rollout undo deployment/nginx-deployment -n default
    log_info "Rollback completed"
  fi
  exit 1
}

log_info "Hardened deployment complete"
exit 0
