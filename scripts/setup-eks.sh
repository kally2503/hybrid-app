#!/bin/bash
# Setup EKS cluster using Terraform
# WARNING: EKS costs ~$3/day. Destroy after testing!

set -e

echo "============================================"
echo "  COST WARNING: EKS costs ~\$3/day"
echo "  Run ./destroy-eks.sh when done testing!"
echo "============================================"
echo ""

cd "$(dirname "$0")/../terraform"

echo "Initializing Terraform..."
terraform init

echo "Planning infrastructure..."
terraform plan -out=tfplan

echo ""
read -p "Proceed with EKS creation? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

echo "Creating EKS cluster (this takes ~15 minutes)..."
terraform apply tfplan

echo ""
echo "Configuring kubectl..."
aws eks update-kubeconfig --name hybrid-app-cluster --region us-east-1

echo ""
echo "EKS cluster is ready!"
terraform output
