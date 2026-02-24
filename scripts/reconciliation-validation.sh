#!/bin/bash
# Task 81: Reconciliation Validation - Watch Kubernetes self-healing

echo "=== Initial Pod Count ==="
POD_COUNT=$(kubectl get pods -n default --no-headers 2>/dev/null | wc -l)
echo "Pods deployed: $POD_COUNT"

echo -e "\n=== Watch Deployment Reconciliation (20 sec) ==="
kubectl get deployment -n default -w --max-log-requests=1 2>/dev/null | head -20 &
WATCH_PID=$!
sleep 20
kill $WATCH_PID 2>/dev/null

echo -e "\n=== Controller Events (reconciliation actions) ==="
kubectl get events -n default --sort-by='.lastTimestamp' | tail -10

echo -e "\n=== Desired vs Actual State ==="
# Shows if pods match deployment spec
kubectl get deployment -n default -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}Desired:{.spec.replicas}{"\t"}Ready:{.status.readyReplicas}{"\n"}{end}'

echo -e "\n=== Manual Deletion Test (delete pod, watch auto-recreate) ==="
read -p "Delete a pod to watch self-healing? (y/n): " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  POD=$(kubectl get pods -n default -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
  if [ ! -z "$POD" ]; then
    echo "Deleting $POD..."
    kubectl delete pod $POD -n default
    sleep 5
    echo "Pods after deletion (auto-recreated):"
    kubectl get pods -n default -o wide | tail -5
  fi
fi
