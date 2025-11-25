#!/bin/bash

# Deployment Script
# Handles environment detection, pre-deployment checks, and deployment

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect environment
detect_environment() {
    if [ -n "$CI" ]; then
        ENV="ci"
    elif [ -n "$PRODUCTION" ]; then
        ENV="production"
    elif [ -n "$STAGING" ]; then
        ENV="staging"
    else
        ENV="development"
    fi
    
    log_info "Environment detected: $ENV"
    echo "$ENV"
}

# Pre-deployment checks
pre_deployment_checks() {
    log_info "Running pre-deployment checks..."
    
    # Check required environment variables
    if [ -z "$REACT_APP_CONTRACT_ADDRESS" ]; then
        log_error "REACT_APP_CONTRACT_ADDRESS is not set"
        exit 1
    fi
    
    # Check Node.js version
    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_VERSION" -lt 18 ]; then
        log_error "Node.js 18+ required, found: $(node -v)"
        exit 1
    fi
    
    # Check if build directory exists
    if [ ! -d "supply-chain-dapp/build" ]; then
        log_warn "Build directory not found, will build..."
    fi
    
    log_info "Pre-deployment checks passed"
}

# Build application
build_application() {
    log_info "Building application..."
    
    cd supply-chain-dapp
    npm ci
    npm run build
    
    if [ ! -d "build" ]; then
        log_error "Build failed - build directory not created"
        exit 1
    fi
    
    log_info "Build completed successfully"
    cd ..
}

# Deploy to Docker
deploy_docker() {
    log_info "Deploying with Docker..."
    
    docker-compose -f docker-compose.prod.yml up -d --build
    
    log_info "Docker deployment completed"
}

# Health check
health_check() {
    log_info "Running health check..."
    
    sleep 5
    
    if curl -f http://localhost/health > /dev/null 2>&1; then
        log_info "Health check passed"
        return 0
    else
        log_error "Health check failed"
        return 1
    fi
}

# Main deployment
main() {
    ENV=$(detect_environment)
    
    pre_deployment_checks
    
    if [ "$ENV" != "development" ]; then
        build_application
        deploy_docker
        
        if health_check; then
            log_info "Deployment successful!"
        else
            log_error "Deployment completed but health check failed"
            exit 1
        fi
    else
        log_info "Development environment - skipping deployment"
    fi
}

# Run main
main "$@"

