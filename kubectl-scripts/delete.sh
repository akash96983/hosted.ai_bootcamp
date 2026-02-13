#!/usr/bin/env bash
set -euo pipefail

MANIFEST=${1:-"kubectl-scripts/manifests/nginx-deployment.yaml"}
DEPLOYMENT_NAME=${2:-"nginx-deployment"}
NAMESPACE=${3:-"default"}

err() { echo "ERROR: $*" >&2; exit 1; }

command -v kubectl >/dev/null || err "kubectl not found in PATH"

echo "Deleting resources from manifest: $MANIFEST"
kubectl delete -f "$MANIFEST" --ignore-not-found || err "kubectl delete failed"

echo "Waiting up to 30s for deployment/$DEPLOYMENT_NAME to disappear"
for i in {1..30}; do
  if ! kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" >/dev/null 2>&1; then
    echo "Deployment removed."
    exit 0
  fi
  sleep 1
done

err "Deployment still exists after timeout"
