#!/bin/bash

# Digital Passport Viewer - Kubernetes Deployment Script
# Usage: ./deploy.sh [environment]

set -e

# Configuration
ENVIRONMENT="${1:-development}"
NAMESPACE="digital-passport"
IMAGE_NAME="digital-passport-viewer"
REGISTRY="${DOCKER_REGISTRY:-localhost}"
TAG="${DOCKER_TAG:-latest}"
K8S_DIR="./k8s"

echo "🚀 Deploying Digital Passport Viewer to Kubernetes"
echo "=================================================="
echo "Environment: ${ENVIRONMENT}"
echo "Namespace: ${NAMESPACE}"
echo "Image: ${REGISTRY}/${IMAGE_NAME}:${TAG}"
echo "Manifests: ${K8S_DIR}"
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

# Check if k8s directory exists
if [ ! -d "${K8S_DIR}" ]; then
    echo "❌ Kubernetes manifests directory not found: ${K8S_DIR}"
    exit 1
fi

# Check cluster connectivity
echo "🔍 Checking Kubernetes cluster connectivity..."
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster. Please check your kubeconfig."
    exit 1
fi

CLUSTER_NAME=$(kubectl config current-context)
echo "📋 Connected to cluster: ${CLUSTER_NAME}"
echo ""

# Apply manifests in order
echo "📦 Applying Kubernetes manifests..."

# 1. Namespace
echo "🏷️  Creating namespace..."
kubectl apply -f "${K8S_DIR}/namespace.yaml"

# 2. ConfigMap
echo "⚙️  Applying configuration..."
kubectl apply -f "${K8S_DIR}/configmap.yaml"

# 3. Deployment (update image tag)
echo "🚢 Deploying application..."
sed "s|image: digital-passport-viewer:latest|image: ${REGISTRY}/${IMAGE_NAME}:${TAG}|g" \
    "${K8S_DIR}/deployment.yaml" | kubectl apply -f -

# 4. Service
echo "🔗 Creating service..."
kubectl apply -f "${K8S_DIR}/service.yaml"

# 5. HPA (if metrics server is available)
echo "📈 Setting up autoscaling..."
if kubectl get apiservice v1beta1.metrics.k8s.io &> /dev/null; then
    kubectl apply -f "${K8S_DIR}/hpa.yaml"
    echo "✅ Horizontal Pod Autoscaler configured"
else
    echo "⚠️  Metrics server not available, skipping HPA"
fi

# 6. Ingress (optional, only for production)
if [ "${ENVIRONMENT}" = "production" ]; then
    echo "🌐 Setting up ingress..."
    echo "⚠️  Please update the hostname in ${K8S_DIR}/ingress.yaml before applying"
    echo "📝 Apply manually: kubectl apply -f ${K8S_DIR}/ingress.yaml"
else
    echo "ℹ️  Skipping ingress for ${ENVIRONMENT} environment"
fi

echo ""
echo "⏳ Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/digital-passport-viewer -n "${NAMESPACE}"

echo ""
echo "✅ Deployment completed successfully!"
echo ""

# Show deployment status
echo "📊 Deployment Status:"
kubectl get pods,svc,deploy -n "${NAMESPACE}" -l app=digital-passport-viewer

echo ""
echo "🌐 Access Information:"
echo "  • Port Forward: kubectl port-forward svc/digital-passport-viewer-service 8080:80 -n ${NAMESPACE}"
echo "  • Then visit: http://localhost:8080"
echo ""

echo "📝 Useful Commands:"
echo "  • Check logs: kubectl logs -l app=digital-passport-viewer -n ${NAMESPACE} -f"
echo "  • Scale up: kubectl scale deployment digital-passport-viewer --replicas=5 -n ${NAMESPACE}"
echo "  • Delete: kubectl delete namespace ${NAMESPACE}"
echo ""

# Test connectivity if port-forward is not already running
if ! pgrep -f "kubectl.*port-forward.*digital-passport-viewer-service" > /dev/null; then
    echo "🔧 Testing connectivity..."
    echo "📝 Run this command in another terminal to test:"
    echo "   kubectl port-forward svc/digital-passport-viewer-service 8080:80 -n ${NAMESPACE}"
fi