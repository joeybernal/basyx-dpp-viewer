# Digital Passport Viewer - Deployment Guide

This guide covers containerization and Kubernetes deployment of the Digital Passport Viewer.

## 🐳 Docker Deployment

### Prerequisites

- Docker 20.10+
- Docker Compose 2.0+ (optional)

### Quick Start

```bash
# Build the Docker image
./build.sh

# Run locally
./run-local.sh

# Access the application
open http://localhost:8080
```

### Docker Commands

```bash
# Build with custom tag
./build.sh v1.0.0

# Run on custom port
./run-local.sh 3000

# View logs
docker logs digital-passport-viewer-local

# Stop container
docker stop digital-passport-viewer-local
```

### Docker Compose

```bash
# Start with docker-compose
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

## ☸️ Kubernetes Deployment

### Prerequisites

- Kubernetes cluster 1.20+
- kubectl configured
- NGINX Ingress Controller (optional)
- Metrics Server (for HPA)
- cert-manager (for TLS)

### Quick Deploy

```bash
# Deploy to Kubernetes
./deploy.sh

# Access via port-forward
kubectl port-forward svc/digital-passport-viewer-service 8080:80 -n digital-passport

# Open application
open http://localhost:8080
```

### Manual Deployment

```bash
# Create namespace
kubectl apply -f k8s/namespace.yaml

# Apply all manifests
kubectl apply -f k8s/

# Check status
kubectl get pods,svc -n digital-passport

# Wait for ready
kubectl wait --for=condition=available --timeout=300s deployment/digital-passport-viewer -n digital-passport
```

## 📁 File Structure

```
basyx-dpp-viewer/
├── index.html              # Main application
├── index-debug.html        # Debug version
├── test.html              # Demo with mock data
├── Logo_light.svg         # Deloitte logo
├── Logo_dark.svg          # Deloitte dark logo
├── Dockerfile             # Container definition
├── nginx.conf             # Web server configuration
├── docker-compose.yml     # Docker Compose setup
├── .dockerignore          # Docker ignore rules
├── build.sh               # Docker build script
├── run-local.sh           # Local Docker run script
├── deploy.sh              # Kubernetes deployment script
└── k8s/                   # Kubernetes manifests
    ├── namespace.yaml     # Namespace definition
    ├── deployment.yaml    # Application deployment
    ├── service.yaml       # Load balancer service
    ├── ingress.yaml       # Ingress configuration
    ├── configmap.yaml     # Configuration
    └── hpa.yaml           # Horizontal Pod Autoscaler
```

## 🔧 Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `NGINX_WORKER_PROCESSES` | `auto` | Nginx worker processes |
| `NGINX_WORKER_CONNECTIONS` | `1024` | Nginx worker connections |

### Server Configuration

The application is pre-configured to connect to:
- **basyx Server**: `https://aasenv.deloitte.iotdemozone.de`

To change the server, modify the `serverUrl` constant in the HTML files.

### Ingress Configuration

For production deployment, update the hostname in `k8s/ingress.yaml`:

```yaml
spec:
  rules:
  - host: digital-passport.your-domain.com  # Update this
```

## 📊 Resource Requirements

### Minimum Resources

| Component | CPU | Memory | Storage |
|-----------|-----|--------|---------|
| Container | 50m | 64Mi | - |
| Image Size | - | - | ~15MB |

### Recommended Resources

| Component | CPU | Memory | Storage |
|-----------|-----|--------|---------|
| Production | 100m | 128Mi | - |
| High Load | 200m | 256Mi | - |

### Scaling

- **Default Replicas**: 3
- **HPA Range**: 2-10 pods
- **CPU Target**: 70% utilization
- **Memory Target**: 80% utilization

## 🌐 Access Methods

### Local Development

```bash
# Direct file access
open index.html

# Python server
python3 -m http.server 8080
```

### Docker Local

```bash
# Docker run
./run-local.sh
open http://localhost:8080
```

### Kubernetes

```bash
# Port forward
kubectl port-forward svc/digital-passport-viewer-service 8080:80 -n digital-passport
open http://localhost:8080

# Ingress (production)
https://digital-passport.your-domain.com
```

## 🛠️ Troubleshooting

### Container Issues

```bash
# Check container logs
docker logs digital-passport-viewer-local

# Debug inside container
docker exec -it digital-passport-viewer-local sh

# Test nginx config
docker exec digital-passport-viewer-local nginx -t
```

### Kubernetes Issues

```bash
# Check pod status
kubectl get pods -n digital-passport

# View pod logs
kubectl logs -l app=digital-passport-viewer -n digital-passport

# Describe deployment
kubectl describe deployment digital-passport-viewer -n digital-passport

# Check service endpoints
kubectl get endpoints -n digital-passport
```

### Common Problems

| Problem | Solution |
|---------|----------|
| Image not found | Run `./build.sh` first |
| Port already in use | Use different port: `./run-local.sh 3000` |
| CORS errors | Check network connectivity to basyx server |
| 404 on AAS | Verify AAS ID is base64url-encoded correctly |

## 🚀 Production Deployment

### 1. Build and Push Image

```bash
# Build for production
./build.sh v1.0.0

# Tag for registry
docker tag digital-passport-viewer:v1.0.0 your-registry.com/digital-passport-viewer:v1.0.0

# Push to registry
docker push your-registry.com/digital-passport-viewer:v1.0.0
```

### 2. Update Kubernetes Manifests

Update `k8s/deployment.yaml`:
```yaml
image: your-registry.com/digital-passport-viewer:v1.0.0
```

Update `k8s/ingress.yaml`:
```yaml
- host: digital-passport.your-domain.com
```

### 3. Deploy to Production

```bash
# Deploy to production cluster
export DOCKER_REGISTRY=your-registry.com
export DOCKER_TAG=v1.0.0
./deploy.sh production
```

## 🔒 Security Considerations

- **HTTPS**: Always use HTTPS in production (configured in ingress)
- **CORS**: Application handles CORS for basyx server communication
- **Headers**: Security headers configured in nginx
- **Resources**: Resource limits prevent resource exhaustion
- **Health Checks**: Configured for proper monitoring

## 📈 Monitoring

### Health Checks

- **Endpoint**: `/health`
- **Kubernetes**: Liveness and readiness probes configured
- **Docker**: Health check command included

### Metrics

- **HPA**: CPU and memory-based autoscaling
- **Logs**: Standard nginx access and error logs
- **Status**: Kubernetes deployment status monitoring