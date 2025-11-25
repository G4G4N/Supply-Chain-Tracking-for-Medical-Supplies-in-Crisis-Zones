# Complete Testing Guide

## ✅ Everything is Ready!

All test infrastructure is in place. Here's what you need to do:

## 📦 Dependencies Status

✅ **Already Installed:**
- `@playwright/test` ✅
- `identity-obj-proxy` ✅
- `@testing-library/react` ✅
- `@testing-library/jest-dom` ✅
- `@testing-library/user-event` ✅
- `@axe-core/playwright` ✅

## 🚀 How to Run Tests

### Step 1: Install Playwright Browsers (One-Time)

```bash
cd supply-chain-dapp
npx playwright install
```

This downloads Chrome, Firefox, and Safari browsers for E2E testing.

### Step 2: Run Unit Tests

```bash
cd supply-chain-dapp

# Run all tests
npm test

# Run with coverage
npm run test:coverage

# Run specific test file
npm test -- PackageTracker.test.js

# Run in watch mode (for development)
npm test -- --watch
```

### Step 3: Run E2E Tests

**Option A: With Auto-Start Server (Recommended)**
```bash
cd supply-chain-dapp
npm run test:e2e
```
Playwright will automatically start the dev server.

**Option B: Manual Start**
```bash
# Terminal 1: Start the app
npm start

# Terminal 2: Run E2E tests
npm run test:e2e

# Or with UI mode (interactive)
npm run test:e2e:ui
```

### Step 4: Run Contract Tests

```bash
cd supply-chain-contract
npm test

# With coverage
npm run test:coverage
```

## 📊 Test Coverage

### Unit Tests (17 test files)
- ✅ App.test.js
- ✅ PackageTracker.test.js
- ✅ CreatePackage.test.js
- ✅ ErrorBoundary.test.js
- ✅ TransactionQueue.test.js
- ✅ LoadingStates.test.js
- ✅ EmptyStates.test.js
- ✅ useTransaction.test.js
- ✅ useWallet.test.js
- ✅ useContract.test.js
- ✅ validation.test.js
- ✅ retry.test.js
- ✅ debounce.test.js
- ✅ cache.test.js
- ✅ transactionManager.test.js
- ✅ logging.test.js
- ✅ Plus App.test.js in root

### E2E Tests (2 test files)
- ✅ e2e/app.spec.js - Main application flows
- ✅ e2e/accessibility.spec.js - Accessibility testing

### Contract Tests
- ✅ supply-chain-contract/test/SupplyChain.test.js

## 🎯 Expected Results

### Unit Tests
- **Test Suites**: ~17
- **Test Cases**: ~50-70
- **Coverage Target**: >70%

### E2E Tests
- **Test Cases**: ~10-15
- **Browsers**: Chrome, Firefox, Safari

### Contract Tests
- **Test Cases**: 30+
- **Coverage**: Comprehensive

## ⚠️ Common Issues & Solutions

### Issue: "Playwright browsers not installed"
**Solution**:
```bash
npx playwright install
```

### Issue: Tests fail with "Cannot find module"
**Solution**: Check that mocks exist in `src/__mocks__/` directory

### Issue: "window.ethereum is not defined"
**Solution**: Tests should mock this automatically, but if needed:
```javascript
global.window.ethereum = {
  request: jest.fn(),
  on: jest.fn(),
};
```

### Issue: React 19 compatibility warnings
**Solution**: Use `--legacy-peer-deps` if installing new packages

### Issue: Tests timeout
**Solution**: Increase timeout in jest.config.js or individual tests

## 📝 Test File Locations

```
supply-chain-dapp/
├── __mocks__/
│   └── fileMock.js                    # File imports
├── src/
│   ├── __mocks__/                     # Source mocks
│   │   ├── ethers.js
│   │   ├── config/
│   │   ├── hooks/
│   │   ├── services/
│   │   └── utils/
│   └── __tests__/                     # Test files
│       ├── App.test.js
│       ├── components/
│       ├── hooks/
│       ├── services/
│       └── utils/
└── e2e/                                # E2E tests
    ├── app.spec.js
    └── accessibility.spec.js
```

## ✅ Quick Verification

Run this to verify everything works:

```bash
cd supply-chain-dapp

# 1. Check dependencies
npm list @playwright/test identity-obj-proxy

# 2. Install browsers (if not done)
npx playwright install

# 3. Run a quick test
npm test -- --testPathPattern=validation.test.js --no-coverage

# 4. Check E2E setup
npx playwright test --list
```

## 🎉 You're Ready!

Everything is set up. Just run:
```bash
npm test        # Unit tests
npm run test:e2e  # E2E tests
```

All test infrastructure, mocks, and test files are complete!

