#!/bin/bash
# Deploy apps to EKS cluster
set -e

AWS_REGION="us-east-1"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo "Updating kubeconfig..."
aws eks update-kubeconfig --name hybrid-app-cluster --region $AWS_REGION

echo "Creating namespace..."
kubectl apply -f "$(dirname "$0")/../k8s/namespace.yml"

echo "Updating image references..."
cd "$(dirname "$0")/../k8s"
for file in java/deployment.yml python/deployment.yml angular/deployment.yml; do
    sed "s|DOCKER_REGISTRY|${ECR_REGISTRY}|g" "$file" | kubectl apply -f -
done

echo "Waiting for rollout..."
kubectl rollout status deployment/java-app -n hybrid-app --timeout=120s
kubectl rollout status deployment/python-app -n hybrid-app --timeout=120s
kubectl rollout status deployment/angular-app -n hybrid-app --timeout=120s

echo ""
echo "Deployment complete!"
kubectl get pods -n hybrid-app
kubectl get svc -n hybrid-app
