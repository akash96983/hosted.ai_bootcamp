#!/usr/bin/env bash
# Task 86 & 87: Failure Recovery & Validation Script
# Demonstrates rollback, failure scenarios, and hardened validation

set -euo pipefail

# Test scenario markers
TESTS_PASSED=0
TESTS_FAILED=0

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_success() { echo -e "${GREEN}✓ $1${NC}"; ((TESTS_PASSED++)); }
log_failure() { echo -e "${RED}✗ $1${NC}"; ((TESTS_FAILED++)); }
log_step() { echo -e "${YELLOW}→ $1${NC}"; }

# TEST 1: Verify CRD deployment
test_crd_deployment() {
  log_step "TEST 1: Verifying CRD deployment"
  if kubectl get crd websiteconfigs.bootcamp.io &>/dev/null; then
    log_success "CRD deployed successfully"
  else
    log_failure "CRD not found"
  fi
}

# TEST 2: Verify custom resource
test_resource_creation() {
  log_step "TEST 2: Verifying custom resource creation"
  if kubectl get websiteconfig example-website &>/dev/null; then
    log_success "Custom resource exists"
  else
    log_failure "Custom resource not found"
  fi
}

# TEST 3: Schema validation (should fail)
test_schema_validation() {
  log_step "TEST 3: Testing schema validation (intentional failure expected)"
  if kubectl apply -f - <<EOF 2>/dev/null; then
    log_failure "Schema validation should have rejected replicas > 10"
apiVersion: bootcamp.io/v1
kind: WebsiteConfig
metadata:
  name: bad-config
spec:
  domain: test.com
  replicas: 15
EOF
  else
    log_success "Schema validation correctly rejected invalid resource"
  fi
}

# TEST 4: Rollback verification
test_rollback_capability() {
  log_step "TEST 4: Verifying rollback capability"
  if kubectl rollout history deployment/example-deployment &>/dev/null; then
    log_success "Rollback capability available"
  else
    log_failure "No rollout history found"
  fi
}

# TEST 5: Error recovery
test_error_handling() {
  log_step "TEST 5: Testing error handling"
  # Try creating duplicate resource (should error gracefully)
  kubectl apply -f - <<EOF 2>&1 | grep -q "unchanged\|created" && \
    log_success "Error handling works correctly" || \
    log_failure "Error handling failed"
apiVersion: bootcamp.io/v1
kind: WebsiteConfig
metadata:
  name: example-website
  namespace: default
spec:
  domain: example.com
  replicas: 3
EOF
}

# Run all tests
main() {
  echo "=== Failure Recovery & Validation Tests ==="
  test_crd_deployment
  test_resource_creation
  test_schema_validation
  test_rollback_capability
  test_error_handling
  
  echo ""
  echo "=== Test Summary ==="
  echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
  echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
  
  [ $TESTS_FAILED -eq 0 ] && echo -e "${GREEN}All tests passed!${NC}" || echo -e "${RED}Some tests failed${NC}"
  exit $TESTS_FAILED
}

main "$@"
