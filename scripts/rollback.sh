#!/usr/bin/env bash
# Task 86: Rollback & Failure Recovery - Minimal Implementation
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Check deployment exists
if ! kubectl get deployment example-deployment &>/dev/null; then
  echo -e "${RED}ERROR: Deployment not found${NC}"
  exit 1
fi

# Get previous rollout revision
PREV_REVISION=$(kubectl rollout history deployment/example-deployment | tail -2 | head -1 | awk '{print $1}')

# Execute rollback
echo "Rolling back to revision: $PREV_REVISION"
kubectl rollout undo deployment/example-deployment --to-revision=$PREV_REVISION

# Verify rollback success
sleep 5
READY_REPLICAS=$(kubectl get deployment example-deployment -o jsonpath='{.status.readyReplicas}')
DESIRED_REPLICAS=$(kubectl get deployment example-deployment -o jsonpath='{.spec.replicas}')

if [ "$READY_REPLICAS" -eq "$DESIRED_REPLICAS" ]; then
  echo -e "${GREEN}✓ Rollback successful - all replicas ready${NC}"
  exit 0
else
  echo -e "${RED}✗ Rollback failed - pods not ready${NC}"
  exit 1
fi
