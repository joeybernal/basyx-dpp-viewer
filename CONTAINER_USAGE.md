# Digital Passport Viewer - Container Usage

## 🚀 Quick Start

### Local Development
```bash
# Start with Python (no container)
./start-server.sh
# Visit: http://localhost:8080

# Use with AAS ID only (simplified)
http://localhost:8080?id=aHR0cHM6Ly9leGFtcGxlLmNvbS9hYXMvZGlnaXRhbHBhc3Nwb3J0L2JhdHRlcnkwMDE
```

### Docker Deployment
```bash
# Build and run with Docker
./build.sh
./run-local.sh
# Visit: http://localhost:8080
```

### Kubernetes Deployment
```bash
# Deploy to Kubernetes cluster
./deploy.sh
kubectl port-forward svc/digital-passport-viewer-service 8080:80 -n digital-passport
# Visit: http://localhost:8080
```

## 🔧 Configuration Changes

### Server URL (Hardcoded)
- **Current**: `https://aasenv.deloitte.iotdemozone.de`
- **To Change**: Edit the `serverUrl` constant in index.html and index-debug.html

### URL Format (Simplified)
- **Before**: `?id=<id>&serverUrl=<url>`
- **Now**: `?id=<id>` (server is pre-configured)

## 📦 Available Versions

1. **`index.html`** - Production version with clean UI
2. **`index-debug.html`** - Debug version with detailed logging  
3. **`test.html`** - Demo version with mock data

## 🏷️ Example URLs

```bash
# Real battery AAS data
?id=aHR0cHM6Ly9leGFtcGxlLmNvbS9hYXMvZGlnaXRhbHBhc3Nwb3J0L2JhdHRlcnkwMDE

# Demo with mock data (no parameters needed)
/test.html
```

## 🏗️ Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   User Browser  │───▶│  Digital Passport │───▶│  basyx Server   │
│                 │    │     Viewer        │    │   (Deloitte)    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌──────────────────┐
                       │  nginx (Docker)  │
                       │  Kubernetes Pod  │
                       └──────────────────┘
```

## 🎯 Deployment Options

| Method | Use Case | Command |
|--------|----------|---------|
| **Local Files** | Development | `./start-server.sh` |
| **Docker** | Local testing | `./run-local.sh` |
| **Docker Compose** | Multi-service | `docker-compose up` |
| **Kubernetes** | Production | `./deploy.sh` |

All methods serve the same Digital Passport Viewer with identical functionality!