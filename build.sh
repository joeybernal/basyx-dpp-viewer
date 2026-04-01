#!/bin/bash

# Digital Passport Viewer - Docker Build Script
# Usage: ./build.sh [tag]

set -e

# Configuration
IMAGE_NAME="digital-passport-viewer"
REGISTRY="${DOCKER_REGISTRY:-localhost}"
DEFAULT_TAG="latest"
TAG="${1:-$DEFAULT_TAG}"
FULL_IMAGE_TAG="${REGISTRY}/${IMAGE_NAME}:${TAG}"

echo "🏗️  Building Digital Passport Viewer Docker Image"
echo "=================================================="
echo "Image: ${FULL_IMAGE_TAG}"
echo "Build Context: $(pwd)"
echo ""

# Check if Dockerfile exists
if [ ! -f "Dockerfile" ]; then
    echo "❌ Error: Dockerfile not found in current directory"
    exit 1
fi

# Build the Docker image
echo "🔨 Building Docker image..."
docker build \
    --tag "${FULL_IMAGE_TAG}" \
    --label "org.opencontainers.image.title=Digital Passport Viewer" \
    --label "org.opencontainers.image.description=Deloitte Digital Passport Viewer for basyx AAS" \
    --label "org.opencontainers.image.version=${TAG}" \
    --label "org.opencontainers.image.created=$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
    --label "org.opencontainers.image.source=https://github.com/deloitte/digital-passport-viewer" \
    .

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Docker image built successfully!"
    echo "Image: ${FULL_IMAGE_TAG}"
    echo ""
    echo "📊 Image Information:"
    docker images "${FULL_IMAGE_TAG}" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
    echo ""
    echo "🚀 Next steps:"
    echo "  • Test locally: ./run-local.sh"
    echo "  • Deploy to K8s: ./deploy.sh"
    echo "  • Push to registry: docker push ${FULL_IMAGE_TAG}"
else
    echo "❌ Docker build failed!"
    exit 1
fi