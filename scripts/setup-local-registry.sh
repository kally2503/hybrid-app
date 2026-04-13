#!/bin/bash
# Setup local Docker registry for on-prem Docker images
echo "Starting local Docker registry on port 5000..."
docker run -d -p 5000:5000 --restart=always --name local-registry registry:2
echo "Local registry running at localhost:5000"
