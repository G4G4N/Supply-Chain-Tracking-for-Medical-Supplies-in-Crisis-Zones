# Deployment Guide

## Docker Deployment

### Build Image

```bash
docker build -t supply-chain-dapp .
```

### Run Container

```bash
docker run -p 3000:80 \
  -e REACT_APP_CONTRACT_ADDRESS=0x... \
  -e REACT_APP_NETWORK=sepolia \
  supply-chain-dapp
```

## Docker Compose

```bash
docker-compose up -d
```

## Kubernetes Deployment

See `kubernetes/` directory for manifests.

## CI/CD

GitHub Actions workflows are configured for:
- Continuous Integration (CI): Runs on every push/PR
- Continuous Deployment (CD): Deploys on main branch

## Environment-Specific Deployment

### Development

```bash
REACT_APP_NETWORK=localhost npm start
```

### Staging

```bash
REACT_APP_NETWORK=sepolia npm run build
```

### Production

```bash
REACT_APP_NETWORK=mainnet npm run build
```

## Health Checks

Health check endpoint: `/health`

Returns `200 OK` if application is healthy.

## Rollback

To rollback a deployment:

1. Identify previous working version
2. Rebuild and deploy previous version
3. Verify health checks pass

## Monitoring

- Application logs: Check container logs
- Error tracking: Sentry dashboard (if enabled)
- Analytics: Google Analytics (if enabled)
