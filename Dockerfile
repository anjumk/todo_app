# Multi-stage build for optimized production image
FROM nginx:alpine AS production

# Set working directory
WORKDIR /usr/share/nginx/html

# Remove default nginx static assets
RUN rm -rf ./*

# Copy application files
COPY index.html .
COPY css/ ./css/
COPY js/ ./js/

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:80/ || exit 1

# Expose port 80
EXPOSE 80

# Set labels for better container management
LABEL maintainer="your-email@example.com"
LABEL version="1.0"
LABEL description="Todo App - Modern Task Management Application"

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
