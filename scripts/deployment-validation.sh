#!/bin/bash
# Deployment Validation: Check pod placement and resource allocation

echo "=== Resource Allocation ==="
# Show pods with CPU/memory requests
kubectl get pods -A -o wide --sort-by=.spec.nodeName | head -10

echo -e "\n=== Pod Resource Requests ==="
# Check actual resource requests
kubectl get pods -A -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].resources}{"\n"}{end}' | head -5

echo -e "\n=== Node Resource Usage ==="
# Show node capacity vs allocation
kubectl top nodes 2>/dev/null || echo "Metrics not available"

echo -e "\n=== Pod Placement by Node ==="
# Verify pods distributed across nodes
kubectl get pods -A -o wide | awk '{print $8}' | sort | uniq -c

echo -e "\n=== Pending Pods (if any) ==="
# Identify scheduling issues
kubectl get pods -A --field-selector=status.phase=Pending -o wide
