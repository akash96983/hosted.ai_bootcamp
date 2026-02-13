#!/usr/bin/env bash
set -euo pipefail

DEPLOYMENT_NAME=${1:-""}
NAMESPACE=${2:-"default"}

command -v kubectl >/dev/null || { echo "ERROR: kubectl not found in PATH" >&2; exit 1; }

echo "Cluster info (best-effort):"
kubectl cluster-info || true

echo "\nPods in namespace $NAMESPACE:"
kubectl get pods -n "$NAMESPACE" || true

if [ -n "$DEPLOYMENT_NAME" ]; then
  echo "\nRollout status for deployment/$DEPLOYMENT_NAME:"
  kubectl rollout status deployment/"$DEPLOYMENT_NAME" -n "$NAMESPACE" --timeout=30s || true
  echo "\nDescribe deployment/$DEPLOYMENT_NAME:"
  kubectl describe deployment/"$DEPLOYMENT_NAME" -n "$NAMESPACE" || true
fi
