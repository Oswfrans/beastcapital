# Multi-stage Dockerfile for Beast Capital Hakyll site

# Stage 1: Build the Hakyll site
FROM haskell:9.4 AS builder

# Set working directory
WORKDIR /app

# Copy Stack configuration files
COPY stack.yaml package.yaml ./

# Install dependencies
RUN stack setup
RUN stack build --dependencies-only

# Copy source files
COPY . .

# Build the site generator
RUN stack build

# Generate the static site
RUN stack exec site build

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy the generated site from the builder stage
COPY --from=builder /app/_site /usr/share/nginx/html

# Copy custom nginx configuration if needed
# COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]