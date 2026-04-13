#!/bin/bash
# DESTROY EKS cluster to stop charges
# Run this when you're done testing!

set -e

echo "============================================"
echo "  Destroying EKS cluster to stop charges"
echo "============================================"

cd "$(dirname "$0")/../terraform"

echo "Deleting Kubernetes resources first..."
kubectl delete namespace hybrid-app --ignore-not-found=true 2>/dev/null || true

echo "Destroying Terraform infrastructure..."
terraform destroy -auto-approve

echo ""
echo "EKS cluster destroyed. No more charges!"
