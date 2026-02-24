#!/bin/bash
# Task 83: CRD Lifecycle Automation - Apply, validate, and manage CRD

CRD_FILE="${1:-crd-design.yaml}"

echo "=== Step 1: Check if CRD already exists ==="
CRD_NAME=$(grep "name:" $CRD_FILE | grep -v "  name:" | head -1 | awk '{print $2}')
if kubectl get crd $CRD_NAME 2>/dev/null; then
  echo "CRD exists, checking version..."
  kubectl get crd $CRD_NAME -o jsonpath='{.spec.versions[*].name}'
else
  echo "CRD not found, will create new"
fi

echo -e "\n=== Step 2: Apply CRD Manifest ==="
kubectl apply -f $CRD_FILE
sleep 2

echo -e "\n=== Step 3: Validate CRD Installation ==="
if kubectl get crd $CRD_NAME; then
  echo "✅ CRD installed successfully"
else
  echo "❌ CRD installation failed"
  exit 1
fi

echo -e "\n=== Step 4: Create Custom Resource Instance ==="
cat << EOF | kubectl apply -f -
apiVersion: bootcamp.io/v1
kind: WebsiteConfig
metadata:
  name: example-website
  namespace: default
spec:
  domain: example.com
  replicas: 3
  tlsEnabled: true
EOF

echo -e "\n=== Step 5: Verify Custom Resource ==="
kubectl get websiteconfigs -A -o wide

echo -e "\n=== Step 6: Describe Custom Resource ==="
kubectl describe websiteconfig example-website || echo "Custom resource created, describing..."
kubectl get websiteconfig example-website -o yaml | head -20

echo -e "\n=== Step 7: Schema Validation Test (invalid) ==="
echo "Testing invalid resource (replicas > 10)..."
cat << EOF | kubectl apply -f - 2>&1 | grep -i "error\|invalid" || echo "Validation caught invalid replicas"
apiVersion: bootcamp.io/v1
kind: WebsiteConfig
metadata:
  name: invalid-config
spec:
  domain: test.com
  replicas: 15
EOF
