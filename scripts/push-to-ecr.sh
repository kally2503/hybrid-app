#!/bin/bash
# Build Docker images and push to AWS ECR
set -e

AWS_REGION="us-east-1"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
TAG="${1:-latest}"

echo "Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

echo "Building and pushing Java app..."
cd "$(dirname "$0")/../apps/java-app"
docker build -t ${ECR_REGISTRY}/hybrid-java-app:${TAG} .
docker push ${ECR_REGISTRY}/hybrid-java-app:${TAG}

echo "Building and pushing Python app..."
cd ../python-app
docker build -t ${ECR_REGISTRY}/hybrid-python-app:${TAG} .
docker push ${ECR_REGISTRY}/hybrid-python-app:${TAG}

echo "Building and pushing Angular app..."
cd ../angular-app
docker build -t ${ECR_REGISTRY}/hybrid-angular-app:${TAG} .
docker push ${ECR_REGISTRY}/hybrid-angular-app:${TAG}

echo ""
echo "All images pushed to ECR with tag: ${TAG}"
