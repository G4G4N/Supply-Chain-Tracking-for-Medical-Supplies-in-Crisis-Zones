#!/bin/bash

# Rollback Script
# Handles safe rollback to previous version

set -e

BACKUP_DIR="./backups"

if [ -z "$1" ]; then
    echo "Usage: $0 <backup_timestamp>"
    echo "Available backups:"
    ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null | sed 's/.*_\([0-9_]*\)\.tar\.gz/\1/' || echo "No backups found"
    exit 1
fi

TIMESTAMP=$1

echo "Rolling back to: $TIMESTAMP"

# Stop current deployment
docker-compose -f docker-compose.prod.yml down || true

# Restore configuration
if [ -f "$BACKUP_DIR/config_$TIMESTAMP.tar.gz" ]; then
    echo "Restoring configuration..."
    tar -xzf "$BACKUP_DIR/config_$TIMESTAMP.tar.gz"
fi

# Restore artifacts
if [ -f "$BACKUP_DIR/artifacts_$TIMESTAMP.tar.gz" ]; then
    echo "Restoring artifacts..."
    tar -xzf "$BACKUP_DIR/artifacts_$TIMESTAMP.tar.gz"
fi

# Rebuild and deploy
echo "Rebuilding and deploying..."
./scripts/deploy.sh

echo "Rollback completed"

