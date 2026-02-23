#!/bin/bash
# GPU-Aware Automation: Check GPU config, label nodes, validate drivers

echo "=== Checking GPU Availability ==="
# Check if GPUs exist on any node
kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.allocatable.nvidia\.com/gpu}{"\n"}{end}'

echo -e "\n=== Labeling GPU Nodes ==="
# Find nodes with GPU and label them (if GPU plugin installed)
GPU_NODES=$(kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | while read node; do
  GPU=$(kubectl get node $node -o jsonpath='{.status.allocatable.nvidia\.com/gpu}' 2>/dev/null)
  if [ ! -z "$GPU" ] && [ "$GPU" != "0" ]; then
    echo $node
  fi
done)

if [ -z "$GPU_NODES" ]; then
  echo "No GPU nodes found - running in CPU mode"
else
  echo "Found GPU nodes: $GPU_NODES"
  # Label GPU nodes for scheduling
  for node in $GPU_NODES; do
    kubectl label nodes $node gpu-node=true --overwrite 2>/dev/null && echo "Labeled: $node"
  done
fi

echo -e "\n=== GPU Resource Quota Status ==="
# Show GPU resource limits
kubectl get resourcequota -A -o wide 2>/dev/null || echo "No resource quotas set"

echo -e "\n=== GPU Driver Validation (if hardware exists) ==="
# Conditional check - only validates if GPUs detected
if [ ! -z "$GPU_NODES" ]; then
  kubectl get pods -n kube-system -l k8s-app=nvidia-device-plugin -o wide
fi
