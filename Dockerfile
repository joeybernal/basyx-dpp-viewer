# Use nginx alpine for a lightweight production image
FROM nginx:alpine

# Set working directory
WORKDIR /usr/share/nginx/html

# Copy application files
COPY index.html .
COPY index-debug.html .
COPY test.html .
COPY Logo_light.svg .
COPY Logo_dark.svg .
COPY README.md .

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost/ || exit 1

# Run nginx
CMD ["nginx", "-g", "daemon off;"]