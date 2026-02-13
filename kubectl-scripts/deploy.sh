#!/usr/bin/env bash
set -euo pipefail

MANIFEST=${1:-"kubectl-scripts/manifests/nginx-deployment.yaml"}
DEPLOYMENT_NAME=${2:-"nginx-deployment"}
NAMESPACE=${3:-"default"}

err() { echo "ERROR: $*" >&2; exit 1; }

command -v kubectl >/dev/null || err "kubectl not found in PATH"

echo "Applying manifest: $MANIFEST"
if ! kubectl apply -f "$MANIFEST"; then
  err "kubectl apply failed"
fi

echo "Waiting for rollout of deployment/$DEPLOYMENT_NAME in namespace $NAMESPACE (120s)"
if ! kubectl rollout status deployment/"$DEPLOYMENT_NAME" -n "$NAMESPACE" --timeout=120s; then
  echo "--- Current pods ---"
  kubectl get pods -n "$NAMESPACE" || true
  err "Rollout failed or timed out"
fi

echo "Deployment '$DEPLOYMENT_NAME' is ready."
