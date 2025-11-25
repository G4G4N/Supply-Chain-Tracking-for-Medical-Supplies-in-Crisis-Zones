# Testing Setup Guide

## What's Needed to Run Tests

### ✅ Already Installed

1. **Jest & React Testing Library**
   - `@testing-library/react` ✅
   - `@testing-library/jest-dom` ✅
   - `@testing-library/user-event` ✅
   - Jest comes with `react-scripts` ✅

2. **E2E Testing**
   - `@playwright/test` - Need to install
   - `@axe-core/playwright` ✅

3. **Test Configuration**
   - `jest.config.js` ✅
   - `playwright.config.js` ✅
   - `setupTests.js` ✅

4. **Test Files**
   - 15+ unit test files ✅
   - 2 E2E test files ✅

### ⚠️ Missing Dependencies

1. **Playwright** - E2E testing framework
   ```bash
   npm install --save-dev @playwright/test
   ```

2. **identity-obj-proxy** - For CSS module mocking in Jest
   ```bash
   npm install --save-dev identity-obj-proxy
   ```

### ✅ Created Mock Files

- `__mocks__/fileMock.js` - File imports mock
- `src/__mocks__/ethers.js` - Ethers.js mock
- `src/__mocks__/services/*.js` - Service mocks
- `src/__mocks__/hooks/*.js` - Hook mocks
- `src/__mocks__/config/index.js` - Config mock

## Running Tests

### Unit Tests

```bash
cd supply-chain-dapp

# Run all tests
npm test

# Run tests with coverage
npm run test:coverage

# Run tests in watch mode
npm test -- --watch

# Run specific test file
npm test -- PackageTracker.test.js
```

### E2E Tests

```bash
cd supply-chain-dapp

# Install Playwright browsers (first time only)
npx playwright install

# Run E2E tests
npm run test:e2e

# Run E2E tests with UI
npm run test:e2e:ui

# Run specific E2E test
npx playwright test e2e/app.spec.js
```

### Contract Tests

```bash
cd supply-chain-contract

# Run contract tests
npm test

# Run with coverage
npm run test:coverage
```

## Test Coverage Goals

- **Unit Tests**: >70% coverage
- **Integration Tests**: All critical paths
- **E2E Tests**: Main user flows
- **Accessibility Tests**: WCAG 2.1 AA compliance

## Common Issues & Solutions

### Issue: "Cannot find module 'identity-obj-proxy'"
**Solution**: 
```bash
npm install --save-dev identity-obj-proxy
```

### Issue: "Playwright not found"
**Solution**:
```bash
npm install --save-dev @playwright/test
npx playwright install
```

### Issue: "Module not found" errors in tests
**Solution**: Check that mocks are in correct location:
- `__mocks__/` at root for file mocks
- `src/__mocks__/` for source mocks

### Issue: "ethers is not defined"
**Solution**: Mock ethers in test file:
```javascript
jest.mock('ethers');
```

### Issue: Tests fail due to missing window.ethereum
**Solution**: Mock window.ethereum in test setup:
```javascript
global.window.ethereum = {
  request: jest.fn(),
  on: jest.fn(),
  removeListener: jest.fn(),
};
```

## Test File Structure

```
supply-chain-dapp/
├── __mocks__/
│   └── fileMock.js          # File imports mock
├── src/
│   ├── __mocks__/
│   │   ├── ethers.js        # Ethers.js mock
│   │   ├── config/
│   │   ├── hooks/
│   │   └── services/
│   └── __tests__/
│       ├── App.test.js
│       ├── components/
│       ├── hooks/
│       ├── services/
│       └── utils/
└── e2e/
    ├── app.spec.js
    └── accessibility.spec.js
```

## Quick Start

1. **Install dependencies**:
   ```bash
   cd supply-chain-dapp
   npm install --legacy-peer-deps
   npm install --save-dev identity-obj-proxy @playwright/test --legacy-peer-deps
   npx playwright install
   ```

2. **Run unit tests**:
   ```bash
   npm test
   ```

3. **Run E2E tests** (requires app running):
   ```bash
   # Terminal 1: Start app
   npm start
   
   # Terminal 2: Run E2E tests
   npm run test:e2e
   ```

4. **Check coverage**:
   ```bash
   npm run test:coverage
   ```

## Next Steps

1. ✅ Install missing dependencies
2. ✅ Run tests to verify they work
3. ⚠️ Fix any failing tests
4. ⚠️ Add more test cases as needed
5. ⚠️ Set up CI/CD to run tests automatically

## Notes

- React 19 may have compatibility issues with some testing libraries
- Use `--legacy-peer-deps` if needed
- Some tests may need adjustments based on actual implementation
- Mock files help isolate components for testing

