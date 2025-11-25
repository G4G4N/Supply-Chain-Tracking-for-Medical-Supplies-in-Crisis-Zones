#!/bin/bash

# Security Audit Script
# Runs comprehensive security audits

set -e

echo "Running security audit..."

# Contract audit
echo "Auditing smart contract..."
cd supply-chain-contract
npm run audit || true
cd ..

# Frontend audit
echo "Auditing frontend dependencies..."
cd supply-chain-dapp
npm audit --audit-level=moderate || true
cd ..

# Code audit
echo "Running code quality checks..."
cd supply-chain-dapp
npm run lint || true
cd ..

echo "Audit completed. Review results above."

