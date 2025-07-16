#!/bin/bash

# Beast Capital Deployment Script
set -e

echo "🦁 Beast Capital Deployment Script"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed or not in PATH"
    exit 1
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    print_error "Docker daemon is not running. Please start Docker first."
    exit 1
fi

# Build the Docker image
echo "Building Beast Capital Docker image..."
if docker build -t beast-capital:latest .; then
    print_status "Docker image built successfully"
else
    print_error "Docker build failed"
    exit 1
fi

# Stop any existing container
if docker ps -q -f name=beast-capital-container | grep -q .; then
    echo "Stopping existing container..."
    docker stop beast-capital-container
    docker rm beast-capital-container
fi

# Run the container
echo "Starting Beast Capital container..."
if docker run -d --name beast-capital-container -p 8080:80 beast-capital:latest; then
    print_status "Container started successfully"
    echo ""
    echo "🌐 Beast Capital website is now running at:"
    echo "   http://localhost:8080"
    echo ""
    echo "📊 Container status:"
    docker ps -f name=beast-capital-container
    echo ""
    echo "🔍 To view logs: docker logs beast-capital-container"
    echo "🛑 To stop: docker stop beast-capital-container"
else
    print_error "Failed to start container"
    exit 1
fi

# Test the deployment
echo "Testing deployment..."
sleep 3
if curl -f -s http://localhost:8080/health > /dev/null; then
    print_status "Health check passed"
else
    print_warning "Health check failed, but container might still be starting"
fi

if curl -f -s http://localhost:8080 | grep -q "Beast Capital"; then
    print_status "Website is responding correctly"
else
    print_warning "Website test failed"
fi

echo ""
print_status "Deployment completed!"
echo "Visit http://localhost:8080 to see your Beast Capital website"