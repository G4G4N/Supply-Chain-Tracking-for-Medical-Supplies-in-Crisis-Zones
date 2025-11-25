# Configuration Guide

This guide covers all configuration options for the Supply Chain Tracking dApp.

## Environment Variables

### Required Variables

- `REACT_APP_CONTRACT_ADDRESS`: Deployed contract address (required in production)

### Optional Variables

See `.env.example` in `supply-chain-dapp/` for complete list of environment variables.

## Network Configuration

The application supports multiple networks:
- Sepolia (testnet)
- Mainnet
- Polygon
- Arbitrum
- Optimism
- Localhost (development)

Network configuration is managed in `src/config/networks.js`.

## Feature Flags

Feature flags allow enabling/disabling features without code changes:
- Analytics tracking
- Error tracking (Sentry)
- WebSocket real-time updates
- Offline mode
- Dark mode

See `src/config/featureFlags.js` for all available flags.

## Contract Configuration

Contract addresses are configured per network in `src/config/contracts.js`.

For production, set network-specific addresses via environment variables:
- `REACT_APP_CONTRACT_ADDRESS_SEPOLIA`
- `REACT_APP_CONTRACT_ADDRESS_MAINNET`
- etc.

## Security Configuration

- Rate limiting: Enabled by default (100 requests/minute)
- Content Security Policy: Configured in nginx.conf
- Input sanitization: Enabled for all user inputs

## Performance Configuration

- Cache TTL: 5 minutes (configurable)
- Transaction timeout: 5 minutes (configurable)
- Max retry attempts: 3 (configurable)

## Development vs Production

Configuration differs between environments:
- Development: More verbose logging, relaxed security
- Production: Optimized logging, strict security, error tracking enabled

