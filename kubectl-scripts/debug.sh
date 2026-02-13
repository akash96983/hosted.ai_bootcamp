#!/usr/bin/env bash
set -euo pipefail

TARGET=${1:-}
NAMESPACE=${2:-default}

err() { echo "ERROR: $*" >&2; exit 1; }

if [ -z "$TARGET" ]; then
  cat <<EOF
Usage: $0 <pod-name | label_selector> [namespace]
Examples:
  $0 nginx-deployment-abc123 default
  $0 app=nginx default
EOF
  exit 1
fi

command -v kubectl >/dev/null || err "kubectl not found in PATH"

# Resolve pod: if TARGET is an existing pod name use it, otherwise treat as label selector
if kubectl get pod "$TARGET" -n "$NAMESPACE" >/dev/null 2>&1; then
  POD="$TARGET"
else
  POD=$(kubectl get pods -l "$TARGET" -n "$NAMESPACE" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)
  if [ -z "$POD" ]; then
    err "No pod found for '$TARGET' in namespace $NAMESPACE"
  fi
fi

echo "== Pod: $POD (ns: $NAMESPACE) =="

echo "\n-- describe pod --"
kubectl describe pod "$POD" -n "$NAMESPACE" || true

echo "\n-- recent events (sorted) --"
kubectl get events -n "$NAMESPACE" --field-selector involvedObject.name="$POD" --sort-by='.metadata.creationTimestamp' || true

echo "\n-- container statuses --"
kubectl get pod "$POD" -n "$NAMESPACE" -o jsonpath='{range .status.containerStatuses[*]}{.name}: {.state}\\n{end}' || true

echo "\n-- last logs (each container, tail 200) --"
for c in $(kubectl get pod "$POD" -n "$NAMESPACE" -o jsonpath='{.spec.containers[*].name}'); do
  echo "\n--- logs: container=$c ---"
  kubectl logs "$POD" -c "$c" -n "$NAMESPACE" --tail=200 || echo "(no logs or failed to fetch logs for $c)"
  echo "\n--- previous logs (if crashloop) ---"
  kubectl logs "$POD" -c "$c" -n "$NAMESPACE" --previous --tail=200 || true
done

echo "\n-- pod YAML (brief) --"
kubectl get pod "$POD" -n "$NAMESPACE" -o yaml || true

echo "\nNext steps you can run manually:"
echo "  kubectl exec -it $POD -n $NAMESPACE -- sh          # open a shell (if image has sh)"
echo "  kubectl attach -it $POD -c <container> -n $NAMESPACE # attach to container stdin/stdout"
echo "  kubectl port-forward pod/$POD 8080:80 -n $NAMESPACE  # access pod port from localhost"

exit 0
