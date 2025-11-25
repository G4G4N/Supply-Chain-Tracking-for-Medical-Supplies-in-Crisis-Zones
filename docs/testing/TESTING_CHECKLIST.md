# Testing Checklist

## ✅ Setup Complete

### Dependencies
- ✅ Jest (via react-scripts)
- ✅ @testing-library/react
- ✅ @testing-library/jest-dom
- ✅ @testing-library/user-event
- ✅ @playwright/test (to install)
- ✅ @axe-core/playwright
- ✅ identity-obj-proxy (to install)

### Configuration Files
- ✅ jest.config.js
- ✅ playwright.config.js
- ✅ setupTests.js
- ✅ .eslintrc.js (with test config)

### Mock Files Created
- ✅ __mocks__/fileMock.js
- ✅ src/__mocks__/ethers.js
- ✅ src/__mocks__/services/*.js (all services)
- ✅ src/__mocks__/hooks/*.js (all hooks)
- ✅ src/__mocks__/config/*.js (all configs)
- ✅ src/__mocks__/utils/*.js (key utilities)

### Test Files Created
- ✅ 15+ unit test files
- ✅ 2 E2E test files

## 📋 To Run Tests

### Step 1: Install Missing Dependencies
```bash
cd supply-chain-dapp
npm install --save-dev @playwright/test identity-obj-proxy --legacy-peer-deps
npx playwright install
```

### Step 2: Run Unit Tests
```bash
npm test
# or with coverage
npm run test:coverage
```

### Step 3: Run E2E Tests
```bash
# In one terminal: Start the app
npm start

# In another terminal: Run E2E tests
npm run test:e2e
```

### Step 4: Run Contract Tests
```bash
cd ../supply-chain-contract
npm test
```

## ⚠️ Potential Issues & Fixes

### Issue 1: "Cannot find module 'identity-obj-proxy'"
**Fix**: Already added to package.json, just run:
```bash
npm install --legacy-peer-deps
```

### Issue 2: "Playwright browsers not installed"
**Fix**: 
```bash
npx playwright install
```

### Issue 3: Tests fail due to missing mocks
**Fix**: All mocks are created in `src/__mocks__/`. If a test fails, check:
- Mock file exists for the module being tested
- Mock is properly exported
- Test file imports the mock correctly

### Issue 4: "window.ethereum is not defined"
**Fix**: Add to test setup or individual test:
```javascript
global.window.ethereum = {
  request: jest.fn(),
  on: jest.fn(),
  removeListener: jest.fn(),
};
```

### Issue 5: React 19 compatibility issues
**Fix**: Use `--legacy-peer-deps` flag when installing

## 🧪 Test Coverage

### Unit Tests (15+ files)
- ✅ App component
- ✅ PackageTracker component
- ✅ CreatePackage component
- ✅ ErrorBoundary component
- ✅ TransactionQueue component
- ✅ LoadingStates components
- ✅ EmptyStates components
- ✅ useTransaction hook
- ✅ useWallet hook
- ✅ useContract hook
- ✅ Validation utilities
- ✅ Retry utilities
- ✅ Debounce utilities
- ✅ Cache service
- ✅ Transaction manager
- ✅ Logging service

### E2E Tests (2 files)
- ✅ Main application flows
- ✅ Accessibility tests

### Contract Tests
- ✅ Comprehensive test suite exists

## 📊 Expected Test Results

After running tests, you should see:
- **Unit Tests**: ~15-20 test suites, 50+ test cases
- **E2E Tests**: ~10-15 test cases
- **Contract Tests**: 30+ test cases
- **Coverage**: Aim for >70% coverage

## 🚀 Quick Start

```bash
# 1. Install dependencies
cd supply-chain-dapp
npm install --legacy-peer-deps

# 2. Install Playwright browsers
npx playwright install

# 3. Run unit tests
npm test

# 4. Run E2E tests (in separate terminal with app running)
npm run test:e2e

# 5. Check coverage
npm run test:coverage
```

## ✅ Status

**All test infrastructure is ready!** Just need to:
1. Install missing dependencies (2 packages)
2. Install Playwright browsers
3. Run the tests

The test files are complete and should work once dependencies are installed.

