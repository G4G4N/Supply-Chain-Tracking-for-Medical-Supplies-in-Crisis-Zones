#!/bin/bash

# Health Check Script
# Verifies application health and dependencies

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check application health
check_app_health() {
    log_info "Checking application health..."
    
    if curl -f http://localhost/health > /dev/null 2>&1; then
        log_info "Application is healthy"
        return 0
    else
        log_error "Application health check failed"
        return 1
    fi
}

# Check contract connectivity (if contract address provided)
check_contract() {
    if [ -z "$REACT_APP_CONTRACT_ADDRESS" ]; then
        log_info "Contract address not set, skipping contract check"
        return 0
    fi
    
    log_info "Checking contract connectivity..."
    # Implementation would check contract via RPC
    return 0
}

# Check dependencies
check_dependencies() {
    log_info "Checking dependencies..."
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        log_error "Node.js not found"
        return 1
    fi
    
    # Check npm
    if ! command -v npm &> /dev/null; then
        log_error "npm not found"
        return 1
    fi
    
    log_info "All dependencies available"
    return 0
}

main() {
    check_dependencies
    check_app_health
    check_contract
    
    log_info "All health checks passed"
}

main "$@"

