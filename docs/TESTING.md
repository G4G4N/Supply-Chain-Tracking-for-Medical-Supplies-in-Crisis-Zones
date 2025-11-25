# Testing Guide

## Testing Strategy

### Unit Tests
- Test individual functions and components
- Mock external dependencies
- Target: >80% coverage

### Integration Tests
- Test component interactions
- Test service integrations
- Test contract interactions

### E2E Tests
- Test complete user flows
- Test across browsers
- Test on different networks

## Running Tests

### Contract Tests
```bash
cd supply-chain-contract
npm test
```

### Frontend Tests
```bash
cd supply-chain-dapp
npm test
```

### E2E Tests
```bash
cd supply-chain-dapp
npx playwright test
```

## Test Coverage

Target coverage:
- Statements: >80%
- Branches: >70%
- Functions: >70%
- Lines: >80%

## Performance Testing

### Lighthouse
```bash
npm run lighthouse
```

### Load Testing
- Use tools like k6 or Artillery
- Test transaction throughput
- Test concurrent users

## Security Testing

### Contract Security
- Run Slither
- Run Mythril
- Manual review

### Frontend Security
- XSS testing
- CSRF testing
- Dependency scanning

## Accessibility Testing

### Automated
- axe-core
- Lighthouse a11y
- Playwright a11y

### Manual
- Screen reader testing
- Keyboard navigation
- Color contrast

