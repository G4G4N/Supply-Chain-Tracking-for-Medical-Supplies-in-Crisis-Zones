#!/bin/bash

# Backup Script
# Creates backups of configuration and deployment data

set -e

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

# Backup configuration
echo "Backing up configuration..."
tar -czf "$BACKUP_DIR/config_$TIMESTAMP.tar.gz" \
    supply-chain-dapp/.env.example \
    supply-chain-contract/.env.example \
    supply-chain-dapp/src/config/ \
    supply-chain-contract/hardhat.config.js \
    2>/dev/null || true

# Backup contract artifacts
echo "Backing up contract artifacts..."
tar -czf "$BACKUP_DIR/artifacts_$TIMESTAMP.tar.gz" \
    supply-chain-contract/artifacts/ \
    supply-chain-contract/contract-abi.json \
    2>/dev/null || true

# Backup deployment info
echo "Backing up deployment info..."
cat > "$BACKUP_DIR/deployment_$TIMESTAMP.txt" << EOF
Deployment Backup - $TIMESTAMP
==============================

Contract Address: ${REACT_APP_CONTRACT_ADDRESS:-N/A}
Network: ${REACT_APP_NETWORK:-N/A}
Environment: ${NODE_ENV:-development}

Git Commit: $(git rev-parse HEAD 2>/dev/null || echo "N/A")
Git Branch: $(git branch --show-current 2>/dev/null || echo "N/A")
EOF

echo "Backup completed: $BACKUP_DIR"

