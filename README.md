# Supply Chain Tracking for Medical Supplies in Crisis Zones v3.0

Enterprise-grade blockchain-based supply chain tracking system for medical supplies in crisis zones with modern Web3 stack and crisis-zone monitoring features.

## Features

### Core Features
- ✅ **Modern Web3 Stack**: Built with wagmi v2, viem v2, and React Query for optimal performance
- ✅ **Smart Contract**: Enterprise-grade Solidity contract with comprehensive security measures
  - Role-based access control (RBAC) with Admin, Operator, Viewer, and Verifier roles
  - Reentrancy protection and pausable functionality
  - Gas-optimized storage patterns and batch operations
  - Comprehensive event emission for off-chain tracking
- ✅ **dApp Frontend**: Modern React TypeScript application with Tailwind CSS and Framer Motion
- ✅ **Multi-Wallet Support**: MetaMask, WalletConnect, Coinbase Wallet, and more via wagmi connectors
- ✅ **Multi-Network Support**: Sepolia, Mainnet, Polygon, Arbitrum, Optimism with automatic network switching

### Package Lifecycle Management
- 📦 **Package Creation**: Create medical supply packages with descriptions, batch numbers, and expiry dates
- 🔄 **Status Tracking**: Track packages through 6 lifecycle stages:
  - Manufacturing → Quality Control → Warehouse → In Transit → Distribution → Delivered
- 👤 **Ownership Transfer**: Transfer package ownership between addresses with blockchain verification
- 📋 **Package History**: Complete timeline view of all package events and status changes
- 🔍 **Package Search**: Search and filter packages by ID, status, owner, or description
- 📊 **Package Details**: Comprehensive detail view with all package information and metadata

### Crisis-Zone Monitoring Features
- 🌡️ **Temperature Monitoring**: Real-time temperature tracking with configurable alert thresholds
- 📍 **Location Tracking**: GPS-based location updates stored on-chain
- 💧 **Humidity Monitoring**: Environmental condition tracking (0-100% humidity)
- ⚠️ **Shock Detection**: Impact and shock event recording with timestamp
- 🚨 **Emergency Alerts**: Multi-level alert system (None, Warning, Critical) with event emission
- ✅ **Certification Verification**: Third-party verification system with verifier address tracking
- 📦 **Batch Management**: Enhanced batch operations (createBatch, transferBatch) with metadata support
- ⏰ **Expiry Date Tracking**: Monitor package expiry dates with automatic alert generation

### User Interface Features
- 🎨 **Modern Design**: Responsive, animated UI with Tailwind CSS and dark theme
- 📊 **Dashboard View**: Interactive dashboard with:
  - Real-time statistics (total shipments, in transit, delivered, delayed)
  - Visual charts and graphs using Recharts
  - Recent shipments overview
  - Quick access to key actions
- 📝 **Create Shipment Form**: Intuitive form for creating new medical supply packages
- 📋 **Shipments List**: Comprehensive list view with:
  - Real-time package data from blockchain
  - Filtering and sorting capabilities
  - Refresh functionality
  - Loading states and empty states
- 🔍 **Package Tracker**: Dedicated tracking interface with:
  - Package search functionality
  - QR code generation for packages
  - Transaction queue management
  - Gas estimation display
- 🔔 **Notification System**: Real-time notifications for:
  - Wallet connection status
  - Network status changes
  - Transaction confirmations
  - Error alerts
- 📱 **Mobile Responsive**: Fully optimized for all device sizes with responsive layouts
- ⚡ **Performance Optimizations**: 
  - Code splitting and lazy loading
  - Virtual scrolling for large lists
  - Memoization and caching strategies
  - Bundle optimization

### Enterprise Features
- 🔒 **Security**:
  - XSS prevention with input sanitization
  - CSRF protection
  - Rate limiting per user
  - Content Security Policy headers
  - Input validation at multiple layers
  - Reentrancy protection in smart contract
  - Access control with role-based permissions
- 📈 **Analytics & Monitoring**:
  - User behavior tracking
  - Performance monitoring
  - Error tracking (Sentry integration ready)
  - Application Performance Monitoring (APM)
  - Metrics collection and distributed tracing
- 🔄 **Offline Support**:
  - Service worker for offline functionality
  - IndexedDB for local data caching
  - Transaction queue for offline operations
  - Automatic sync when connection restored
- 🔔 **Real-time Updates**:
  - WebSocket service for live package updates
  - Blockchain event listeners
  - Automatic data refresh
- 🐳 **Deployment**:
  - Docker containerization
  - Docker Compose for local development
  - Kubernetes manifests for production
  - CI/CD pipelines (GitHub Actions)
  - Health check scripts
  - Backup and rollback procedures
- 🧪 **Testing**:
  - Comprehensive unit test suite (15+ test files)
  - E2E tests with Playwright
  - Accessibility testing
  - Contract tests with Hardhat
  - Test coverage reporting
- 📝 **Logging & Error Handling**:
  - Structured logging service
  - Error boundary components
  - Transaction retry mechanisms
  - Comprehensive error tracking

## Key Functionalities

### Package Management
- **Create Packages**: Create new medical supply packages with descriptions, batch numbers, and expiry dates
- **Track Status**: Monitor packages through the complete lifecycle from manufacturing to delivery
- **Transfer Ownership**: Securely transfer package ownership between addresses on the blockchain
- **View History**: Access complete timeline of all package events, status changes, and updates
- **Search & Filter**: Find packages by ID, status, owner, or description with advanced filtering

### Crisis-Zone Monitoring
- **Environmental Tracking**: Monitor temperature, humidity, and location in real-time
- **Shock Detection**: Record and alert on impact events that may damage supplies
- **Alert System**: Multi-level alert system (Warning/Critical) for environmental violations
- **Certification**: Third-party verification system for package authenticity and compliance
- **Batch Operations**: Create and transfer multiple packages efficiently in single transactions

### User Interface
- **Dashboard**: Real-time overview with statistics, charts, and recent shipments
- **Package List**: Comprehensive view of all packages with filtering and sorting
- **Package Details**: Detailed modal view with all package information and actions
- **Create Form**: Intuitive form for creating new shipments with validation
- **QR Codes**: Generate QR codes for easy package identification and tracking
- **Transaction Queue**: View and manage pending blockchain transactions

### Smart Contract Features
- **Role-Based Access Control**: Admin, Operator, Viewer, and Verifier roles
- **Security**: Reentrancy protection, pausable functionality, input validation
- **Gas Optimization**: Batch operations and optimized storage patterns
- **Event Emission**: Comprehensive events for off-chain tracking and indexing
- **Rate Limiting**: Protection against DoS attacks with per-user limits
- **Maximum Limits**: Configurable limits for packages per user and batch sizes

## Quick Start

### Prerequisites

- Node.js 18+
- npm or yarn
- Web3 wallet (MetaMask, WalletConnect, etc.)
- Git

### New in v3.0

- **Modern Web3 Stack**: Migrated from ethers.js to wagmi v2 + viem v2 for better performance and type safety
- **Crisis-Zone Monitoring**: Complete environmental monitoring with temperature, location, humidity, and shock detection
- **Enhanced UI**: Modern design with animations, dark theme, and fully responsive layouts
- **Dashboard**: Comprehensive overview with real-time statistics, charts, and quick actions
- **Multi-Wallet Support**: Connect with any Web3 wallet via wagmi connectors
- **Enterprise Architecture**: Complete service layer with analytics, monitoring, error tracking, and offline support
- **Production Ready**: Comprehensive testing, CI/CD pipelines, Docker deployment, and Kubernetes support
- **Real-time Updates**: WebSocket integration and blockchain event listeners for live data
- **Transaction Management**: Queue system with retry logic and offline transaction support

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd "Idea 3 - Supply Chain Tracking for Medical Supplies in Crisis Zones"
```

2. Install contract dependencies:
```bash
cd supply-chain-contract
npm install
```

3. Install dApp dependencies:
```bash
cd ../supply-chain-dapp
npm install
```

4. Configure environment variables:
```bash
# Copy example files
cp .env.example .env
# Edit .env with your configuration
```

5. Start development server:
```bash
npm start
```

## Project Structure

```
.
├── supply-chain-contract/    # Smart contract (Hardhat)
│   ├── contracts/           # Solidity contracts
│   │   └── SupplyChain.sol  # Main supply chain contract
│   ├── test/                # Contract tests
│   ├── scripts/             # Deployment and verification scripts
│   └── artifacts/           # Compiled contract artifacts
├── supply-chain-dapp/        # React TypeScript frontend
│   ├── src/
│   │   ├── components/      # React components
│   │   │   ├── Navigation.tsx
│   │   │   ├── dashboard-view.tsx
│   │   │   ├── create-shipment-form.tsx
│   │   │   ├── shipments-list.tsx
│   │   │   ├── shipment-detail-modal.tsx
│   │   │   ├── PackageTracker.js
│   │   │   ├── PackageSearch.js
│   │   │   ├── QRCodeGenerator.js
│   │   │   ├── TransactionQueue.js
│   │   │   └── ... (30+ components)
│   │   ├── config/          # Configuration modules
│   │   │   ├── index.js/ts  # Main config
│   │   │   ├── networks.js  # Network configurations
│   │   │   ├── contracts.js # Contract addresses
│   │   │   └── featureFlags.js # Feature flags
│   │   ├── hooks/           # Custom React hooks
│   │   │   ├── useWallet.ts/js
│   │   │   ├── useContract.ts/js
│   │   │   ├── useTransaction.ts/js
│   │   │   └── usePackages.ts
│   │   ├── services/        # Business logic services
│   │   │   ├── analytics.js
│   │   │   ├── errorTracking.js
│   │   │   ├── logging.js
│   │   │   ├── monitoring.js
│   │   │   ├── offlineManager.js
│   │   │   ├── transactionManager.js
│   │   │   └── websocket.js
│   │   ├── utils/           # Utility functions
│   │   │   ├── validation.js
│   │   │   ├── sanitization.js
│   │   │   ├── errorHandler.js
│   │   │   ├── packageParser.ts
│   │   │   └── ... (15+ utilities)
│   │   ├── contexts/        # React contexts
│   │   │   └── NotificationContext.tsx
│   │   └── __tests__/       # Test files
│   ├── e2e/                 # E2E tests (Playwright)
│   └── public/              # Static assets
├── docs/                    # Comprehensive documentation
│   ├── api/                 # API documentation
│   ├── guides/              # User guides
│   ├── development/         # Development docs
│   ├── testing/             # Testing guides
│   ├── audit/               # Security audit reports
│   └── status/              # Implementation status
├── scripts/                 # Deployment and utility scripts
│   ├── deploy.sh
│   ├── health-check.sh
│   ├── backup.sh
│   └── rollback.sh
├── kubernetes/              # Kubernetes manifests
├── Dockerfile               # Docker configuration
├── docker-compose.yml       # Docker Compose for development
├── docker-compose.prod.yml  # Docker Compose for production
└── .github/workflows/       # CI/CD pipelines
    ├── ci.yml               # Continuous Integration
    └── cd.yml               # Continuous Deployment
```

## Configuration

See [Configuration Guide](docs/guides/CONFIGURATION.md) for detailed configuration options.

### Environment Variables

**Frontend (supply-chain-dapp/.env):**

Required:
- `REACT_APP_CONTRACT_ADDRESS`: Deployed contract address

Optional:
- `REACT_APP_NETWORK`: Default network (default: sepolia)
- `REACT_APP_ENABLE_ANALYTICS`: Enable analytics (default: false)
- `REACT_APP_ENABLE_ERROR_TRACKING`: Enable error tracking (default: false)
- `REACT_APP_SENTRY_DSN`: Sentry DSN for error tracking
- `REACT_APP_WEBSOCKET_URL`: WebSocket server URL for real-time updates
- `REACT_APP_ENABLE_OFFLINE_MODE`: Enable offline support (default: true)

**Contract (supply-chain-contract/.env):**

- `PRIVATE_KEY`: Private key for deployment
- `INFURA_API_KEY`: Infura API key for RPC access
- `ETHERSCAN_API_KEY`: Etherscan API key for contract verification
- `NETWORK`: Target network (sepolia, mainnet, etc.)

See `.env.example` files in each directory for complete configuration options.

## Deployment

### Docker

```bash
docker-compose up -d
```

### Manual Build

```bash
cd supply-chain-dapp
npm run build
```

See [Deployment Guide](docs/guides/deployment.md) for detailed deployment instructions.

## Testing

### Quick Start

See [Quick Test Start Guide](docs/testing/QUICK_TEST_START.md) for the fastest way to run tests.

### Contract Tests

```bash
cd supply-chain-contract
npm test                    # Run all contract tests
npm run test:coverage       # Run tests with coverage report
npm run audit:contract     # Security audit of contract
```

**Test Coverage:**
- Package creation and management
- Status transitions
- Ownership transfers
- Batch operations
- Crisis-zone monitoring functions
- Access control
- Security vulnerabilities (reentrancy, overflow, etc.)

### Frontend Tests

```bash
cd supply-chain-dapp
npm test                    # Run unit tests in watch mode
npm run test:coverage       # Run tests with coverage report
npm run test:e2e            # Run E2E tests (Playwright)
npm run test:e2e:ui         # Run E2E tests with UI
```

**Test Coverage:**
- Component unit tests (15+ test files)
- Hook tests (useWallet, useContract, useTransaction)
- Utility function tests (validation, sanitization, error handling)
- Service tests (transaction manager, logging, analytics)
- E2E tests (full user flows, accessibility)

### Test Scripts

**Frontend:**
- `npm test` - Run unit tests
- `npm run test:coverage` - Coverage report
- `npm run test:e2e` - E2E tests
- `npm run test:e2e:ui` - E2E with UI
- `npm run lint` - Linting
- `npm run audit:security` - Security audit

**Contract:**
- `npm test` - Run contract tests
- `npm run test:coverage` - Coverage report
- `npm run audit:contract` - Contract security audit

For comprehensive testing documentation, see:
- [Testing Guide](docs/testing/TESTING_GUIDE.md)
- [Testing Setup](docs/testing/TESTING_SETUP.md)
- [Testing Checklist](docs/testing/TESTING_CHECKLIST.md)
- [Test Execution Guide](docs/testing/TEST_EXECUTION_GUIDE.md)

## Security

- Smart contract audited and tested
- Input validation and sanitization
- XSS prevention
- Rate limiting
- Content Security Policy headers
- Reentrancy protection
- Access control (RBAC)

See [Security Documentation](docs/development/security.md) for details.

## Documentation

### Core Documentation

**User Guides:**
- [Setup Guide](docs/guides/setup.md)
- [Configuration Guide](docs/guides/CONFIGURATION.md)
- [Deployment Guide](docs/guides/deployment.md)
- [Troubleshooting](docs/guides/troubleshooting.md)

**API Documentation:**
- [API Reference](docs/api/API.md)
- [Contract API](docs/api/contract-api.md)
- [Frontend Usage](docs/api/frontend-usage.md)

**Development:**
- [Architecture](docs/development/ARCHITECTURE.md)
- [Security Documentation](docs/development/security.md)
- [Performance](docs/development/PERFORMANCE.md)
- [Accessibility](docs/development/ACCESSIBILITY.md)

### Testing & Status

- [Quick Test Start](docs/testing/QUICK_TEST_START.md) - Start here for testing!
- [Testing Guide](docs/testing/TESTING_GUIDE.md)
- [Implementation Status](docs/status/IMPLEMENTATION_STATUS.md)

See [Documentation Index](docs/README.md) for complete documentation.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

MIT

## Support

For issues and questions, please open an issue on GitHub.
