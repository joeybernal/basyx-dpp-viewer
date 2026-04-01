#!/bin/bash

# Test script to validate Docker and Kubernetes files
echo "🧪 Testing Digital Passport Viewer Containerization"
echo "=================================================="

echo ""
echo "📁 Checking required files..."

# Check for required files
REQUIRED_FILES=(
    "index.html"
    "index-debug.html" 
    "test.html"
    "Logo_light.svg"
    "Logo_dark.svg"
    "Dockerfile"
    "nginx.conf"
    "docker-compose.yml"
)

missing_files=0
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file (MISSING)"
        missing_files=$((missing_files + 1))
    fi
done

echo ""
echo "📁 Checking Kubernetes manifests..."

K8S_FILES=(
    "k8s/namespace.yaml"
    "k8s/deployment.yaml"
    "k8s/service.yaml" 
    "k8s/ingress.yaml"
    "k8s/configmap.yaml"
    "k8s/hpa.yaml"
)

missing_k8s=0
for file in "${K8S_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file (MISSING)"
        missing_k8s=$((missing_k8s + 1))
    fi
done

echo ""
echo "📋 Checking script permissions..."
SCRIPTS=(
    "build.sh"
    "deploy.sh"
    "run-local.sh"
    "start-server.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            echo "✅ $script (executable)"
        else
            echo "⚠️  $script (not executable)"
        fi
    else
        echo "❌ $script (MISSING)"
    fi
done

echo ""
echo "🔍 Dockerfile Validation..."
if [ -f "Dockerfile" ]; then
    echo "✅ Dockerfile exists"
    echo "📦 Base image: $(grep "^FROM" Dockerfile)"
    echo "🔌 Exposed port: $(grep "EXPOSE" Dockerfile)"
    echo "📁 Working directory: $(grep "WORKDIR" Dockerfile)"
else
    echo "❌ Dockerfile missing"
fi

echo ""
echo "⚙️  Nginx Configuration..."
if [ -f "nginx.conf" ]; then
    echo "✅ nginx.conf exists"
    echo "🔌 Listen port: $(grep "listen" nginx.conf | head -1 | awk '{print $2}' | tr -d ';')"
    echo "🏠 Server name: $(grep "server_name" nginx.conf | awk '{print $2}' | tr -d ';')"
else
    echo "❌ nginx.conf missing"
fi

echo ""
echo "☸️  Kubernetes Manifest Validation..."
if [ -f "k8s/deployment.yaml" ]; then
    echo "✅ Deployment manifest exists"
    echo "🔢 Replicas: $(grep "replicas:" k8s/deployment.yaml | awk '{print $2}')"
    echo "🖼️  Image: $(grep "image:" k8s/deployment.yaml | awk '{print $2}')"
    echo "🔌 Container port: $(grep "containerPort:" k8s/deployment.yaml | awk '{print $2}')"
else
    echo "❌ deployment.yaml missing"
fi

echo ""
echo "📊 Summary:"
echo "=========="
total_files=$((${#REQUIRED_FILES[@]} + ${#K8S_FILES[@]}))
total_missing=$((missing_files + missing_k8s))
echo "✅ Files present: $((total_files - total_missing))/$total_files"

if [ $total_missing -eq 0 ]; then
    echo ""
    echo "🎉 All files present! Ready for containerization."
    echo ""
    echo "📝 Next steps:"
    echo "  1. Build: ./build.sh"
    echo "  2. Test locally: ./run-local.sh"
    echo "  3. Deploy to K8s: ./deploy.sh"
else
    echo ""
    echo "⚠️  Missing $total_missing files. Please create missing files before deploying."
fi