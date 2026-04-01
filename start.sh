#!/bin/bash
# Start the DPP viewer with local proxy
# Usage: ./start.sh [port]

PORT=${1:-8099}
ROOT="$(cd "$(dirname "$0")" && pwd)"

echo "Starting DPP Viewer on http://localhost:$PORT/"
echo "Press Ctrl+C to stop"
echo ""

cd "$ROOT"
python3 dpp_proxy.py $PORT
