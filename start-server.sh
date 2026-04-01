#!/bin/bash

# Start a simple HTTP server for the Digital Passport Viewer
echo "Starting Digital Passport Viewer server..."
echo "Open http://localhost:8080/test.html to see the demo with mock data"
echo "Open http://localhost:8080/index.html?id=YOUR_AAS_ID&serverUrl=YOUR_SERVER_URL for real data"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

python3 -m http.server 8080