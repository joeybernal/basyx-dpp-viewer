#!/bin/bash

# Digital Passport Viewer - Local Docker Run Script
# Usage: ./run-local.sh [port]

set -e

# Configuration
IMAGE_NAME="digital-passport-viewer"
REGISTRY="${DOCKER_REGISTRY:-localhost}"
TAG="${DOCKER_TAG:-latest}"
FULL_IMAGE_TAG="${REGISTRY}/${IMAGE_NAME}:${TAG}"
PORT="${1:-8080}"
CONTAINER_NAME="digital-passport-viewer-local"

echo "🚀 Running Digital Passport Viewer Locally"
echo "=========================================="
echo "Image: ${FULL_IMAGE_TAG}"
echo "Port: ${PORT}"
echo "Container: ${CONTAINER_NAME}"
echo ""

# Stop and remove existing container if it exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "🛑 Stopping existing container..."
    docker stop "${CONTAINER_NAME}" >/dev/null 2>&1 || true
    docker rm "${CONTAINER_NAME}" >/dev/null 2>&1 || true
fi

# Check if image exists
if ! docker images "${FULL_IMAGE_TAG}" --format '{{.Repository}}:{{.Tag}}' | grep -q "${FULL_IMAGE_TAG}"; then
    echo "❌ Image ${FULL_IMAGE_TAG} not found. Please run ./build.sh first."
    exit 1
fi

# Run the container
echo "🐳 Starting container..."
docker run \
    --name "${CONTAINER_NAME}" \
    --publish "${PORT}:80" \
    --detach \
    --restart unless-stopped \
    --health-cmd="wget --no-verbose --tries=1 --spider http://localhost/ || exit 1" \
    --health-interval=30s \
    --health-timeout=3s \
    --health-retries=3 \
    "${FULL_IMAGE_TAG}"

# Wait a moment for container to start
sleep 2

# Check if container is running
if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo ""
    echo "✅ Digital Passport Viewer is running!"
    echo ""
    echo "🌐 Access URLs:"
    echo "  • Main Application: http://localhost:${PORT}"
    echo "  • Debug Mode: http://localhost:${PORT}/index-debug.html"
    echo "  • Demo Mode: http://localhost:${PORT}/test.html"
    echo "  • Health Check: http://localhost:${PORT}/health"
    echo ""
    echo "📊 Container Status:"
    docker ps --filter "name=${CONTAINER_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    echo "📝 Container Logs:"
    echo "  • View logs: docker logs ${CONTAINER_NAME}"
    echo "  • Follow logs: docker logs -f ${CONTAINER_NAME}"
    echo ""
    echo "🛑 Stop container:"
    echo "  • docker stop ${CONTAINER_NAME}"
else
    echo ""
    echo "❌ Container failed to start!"
    echo "📝 Check logs: docker logs ${CONTAINER_NAME}"
    exit 1
fi