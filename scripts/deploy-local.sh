#!/bin/bash
# Deploy all apps locally using Docker Compose
echo "Building and starting all services locally..."
cd "$(dirname "$0")/../docker"
docker-compose down 2>/dev/null
docker-compose up -d --build
echo ""
echo "Services running:"
docker-compose ps
echo ""
echo "Access the app at: http://localhost:4200"
echo "Java API: http://localhost:8080/api/health"
echo "Python API: http://localhost:5000/api/health"
