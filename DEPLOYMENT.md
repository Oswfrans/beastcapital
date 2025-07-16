# Beast Capital - Deployment Guide

## 🦁 Overview

This document outlines the deployment configuration for the Beast Capital website, a static site built with Hakyll and deployed using Docker and GitLab CI/CD.

## 📁 Project Structure

```
beastCapital/
├── site.hs                 # Hakyll site generator
├── package.yaml            # Haskell package configuration
├── beast-capital.cabal     # Generated cabal file
├── stack.yaml              # Stack configuration (alternative)
├── index.md                # Homepage content
├── about.md                # About page content
├── contact.md              # Contact page content
├── templates/
│   └── default.html        # HTML template
├── css/
│   └── style.css          # Dark theme stylesheet
├── Dockerfile             # Multi-stage Docker build
├── nginx.conf             # Nginx configuration
├── .gitlab-ci.yml         # GitLab CI/CD pipeline
├── .dockerignore          # Docker ignore file
├── deploy.sh              # Local deployment script
└── _site/                 # Generated static files (local)
```

## 🐳 Docker Configuration

### Dockerfile Features

- **Multi-stage build**: Haskell build stage + Nginx serving stage
- **Cabal-based build**: Uses cabal instead of stack for better compatibility
- **Optimized Nginx**: Custom configuration with compression, caching, and security headers
- **Health checks**: Built-in health endpoint for monitoring
- **Minimal final image**: Only includes necessary files for serving

### Build Process

1. **Stage 1 (Builder)**:
   - Uses `haskell:8.10` base image
   - Updates cabal package list
   - Copies source files and dependencies
   - Builds the Hakyll site generator
   - Generates static site files

2. **Stage 2 (Server)**:
   - Uses `nginx:alpine` for minimal footprint
   - Copies generated static files
   - Applies custom nginx configuration
   - Sets up health checks and error pages

### Local Testing

```bash
# Build the Docker image
docker build -t beast-capital .

# Run the container
docker run -d --name beast-capital -p 8080:80 beast-capital

# Test the deployment
curl http://localhost:8080
curl http://localhost:8080/health

# Or use the deployment script
./deploy.sh
```

## 🚀 GitLab CI/CD Pipeline

### Pipeline Stages

1. **Test Stage**:
   - Validates Hakyll build process
   - Runs on `haskell:8.10` image
   - Generates artifacts for next stage
   - Runs on main, develop, and merge requests

2. **Build Stage**:
   - Builds Docker image using BuildKit
   - Tags with commit SHA and latest
   - Pushes to GitLab Container Registry
   - Depends on successful test stage

3. **Deploy Stage**:
   - Deploys to Google Cloud Run
   - Manual trigger for production safety
   - Includes service validation
   - Sets environment variables and labels

### Required Environment Variables

Set these in your GitLab project settings:

- `GCP_SERVICE_ACCOUNT_KEY`: Base64-encoded service account JSON
- `GCP_PROJECT_ID`: Your Google Cloud project ID

### Pipeline Features

- **Docker BuildKit**: Faster builds with caching
- **Artifact management**: Passes build artifacts between stages
- **Service validation**: Tests deployed service automatically
- **Environment labeling**: Tracks deployments with metadata
- **Health monitoring**: Includes health check endpoints

## 🌐 Google Cloud Run Deployment

### Service Configuration

- **Platform**: Managed Cloud Run
- **Region**: us-central1
- **Memory**: 512Mi
- **CPU**: 1 vCPU
- **Concurrency**: 80 requests per instance
- **Scaling**: 0-10 instances (auto-scaling)
- **Timeout**: 300 seconds

### Environment Variables

- `ENV=production`
- `BUILD_SHA`: Git commit SHA
- `BUILD_TIME`: Build timestamp

### Labels

- `app=beast-capital`
- `environment=production`
- `version=<commit-short-sha>`

## 🔧 Nginx Configuration

### Features

- **Security headers**: X-Frame-Options, X-Content-Type-Options, etc.
- **Gzip compression**: Reduces bandwidth usage
- **Static asset caching**: 1-year cache for CSS/JS/images
- **HTML caching**: 1-hour cache with revalidation
- **Health endpoint**: `/health` for monitoring
- **Error pages**: Custom 404 page with Beast Capital branding

### Cache Strategy

- **Static assets** (CSS, JS, images): 1 year with immutable cache
- **HTML files**: 1 hour with must-revalidate
- **Health endpoint**: No caching

## 🛠️ Development Workflow

### Local Development

```bash
# Build the site generator
cabal build

# Generate static files
cabal exec site build

# Start development server
python3 -m http.server 8000 --directory _site

# Or use Hakyll's built-in server
cabal exec site watch
```

### Docker Development

```bash
# Build and test locally
./deploy.sh

# View logs
docker logs beast-capital-container

# Stop container
docker stop beast-capital-container
```

### CI/CD Workflow

1. **Development**: Work on feature branches
2. **Testing**: Create merge request (triggers test pipeline)
3. **Integration**: Merge to develop (triggers build pipeline)
4. **Production**: Merge to main + manual deploy trigger

## 🔍 Monitoring and Troubleshooting

### Health Checks

- **Docker**: Built-in health check every 30 seconds
- **Cloud Run**: Automatic health monitoring
- **Nginx**: `/health` endpoint returns "healthy"

### Common Issues

1. **Build failures**: Check cabal dependencies and GHC version
2. **Docker issues**: Ensure Docker daemon is running
3. **Deployment failures**: Verify GCP credentials and project ID
4. **Service errors**: Check Cloud Run logs and health endpoints

### Debugging Commands

```bash
# Check Docker build logs
docker build --no-cache -t beast-capital .

# Test nginx configuration
docker run --rm -it beast-capital nginx -t

# View Cloud Run logs
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=beast-capital-website"
```

## 🔐 Security Considerations

- **Nginx security headers**: Prevents common web vulnerabilities
- **Minimal Docker image**: Reduces attack surface
- **No sensitive data**: All content is public static files
- **HTTPS enforcement**: Cloud Run provides automatic HTTPS
- **Service account**: Limited permissions for deployment

## 📊 Performance Optimizations

- **Multi-stage Docker build**: Smaller final image
- **Gzip compression**: Reduces bandwidth usage
- **Static asset caching**: Improves load times
- **CDN-ready**: Compatible with Cloud CDN
- **Auto-scaling**: Handles traffic spikes automatically

## 🚀 Future Enhancements

- **CDN integration**: Add Cloud CDN for global performance
- **Custom domain**: Configure custom domain with SSL
- **Monitoring**: Add application performance monitoring
- **Backup strategy**: Implement automated backups
- **Blue-green deployment**: Zero-downtime deployments