# Multi-stage Dockerfile for Beast Capital Hakyll site

# Stage 1: Build the Hakyll site
FROM haskell:9.4-slim AS builder

# Install required system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy cabal configuration files first for better caching
COPY beast-capital.cabal package.yaml ./

# Update cabal and install dependencies (cached layer)
RUN cabal update && cabal build --dependencies-only

# Copy source files
COPY site.hs ./
COPY index.md about.md contact.md ./
COPY templates/ ./templates/
COPY css/ ./css/

# Build the site
RUN cabal build
RUN cabal exec site build

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Install curl for health checks
RUN apk add --no-cache curl

# Remove default nginx website and config
RUN rm -rf /usr/share/nginx/html/* /etc/nginx/conf.d/default.conf

# Copy the generated site from the builder stage
COPY --from=builder /app/_site /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Create a simple 404 page
RUN echo '<!DOCTYPE html><html><head><title>404 - Page Not Found</title><style>body{font-family:Arial,sans-serif;text-align:center;padding:50px;background:#1a1a1a;color:#e0e0e0;}h1{color:#ffd700;}</style></head><body><h1>404 - Page Not Found</h1><p>The page you are looking for does not exist.</p><a href="/" style="color:#ffd700;">Return to Beast Capital</a></body></html>' > /usr/share/nginx/html/404.html

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
