#!/bin/bash
# GPU Troubleshooting: Debug GPU scheduling failures

POD_NAME="${1:-}"

if [ -z "$POD_NAME" ]; then
  echo "Usage: $0 <pod-name> [namespace]"
  exit 1
fi

NAMESPACE="${2:-default}"

echo "=== Investigating Pod: $POD_NAME ==="

# Show pod status
echo -e "\n1. Pod Status:"
kubectl get pod $POD_NAME -n $NAMESPACE -o wide

# Check events for scheduling failures
echo -e "\n2. Pod Events (scheduling issues):"
kubectl describe pod $POD_NAME -n $NAMESPACE | grep -A 5 "Events:"

# Check GPU resource requests
echo -e "\n3. GPU Resource Requests:"
kubectl get pod $POD_NAME -n $NAMESPACE -o jsonpath='{.spec.containers[*].resources.limits}' | jq '.'

# Check node selector/affinity
echo -e "\n4. Node Affinity/Selector:"
kubectl get pod $POD_NAME -n $NAMESPACE -o jsonpath='{.spec.affinity}' | jq '.'

# If GPU requested, check GPU availability
NEEDS_GPU=$(kubectl get pod $POD_NAME -n $NAMESPACE -o jsonpath='{.spec.containers[*].resources.limits.nvidia\.com/gpu}' 2>/dev/null)
if [ ! -z "$NEEDS_GPU" ] && [ "$NEEDS_GPU" != "0" ]; then
  echo -e "\n5. GPU Availability (pod needs $NEEDS_GPU GPU):"
  kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.allocatable.nvidia\.com/gpu}{"\n"}{end}'
fi

# Check if pending - show scheduling blockers
if kubectl get pod $POD_NAME -n $NAMESPACE -o jsonpath='{.status.phase}' | grep -q "Pending"; then
  echo -e "\n⚠️  Pod is PENDING - Common reasons:"
  echo "- Insufficient resources (check node capacity)"
  echo "- GPU unavailable (check device plugin)"
  echo "- Node selector mismatch"
fi
