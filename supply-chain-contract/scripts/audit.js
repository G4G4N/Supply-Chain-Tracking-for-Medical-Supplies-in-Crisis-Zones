#!/usr/bin/env node

/**
 * Security Audit Script for SupplyChain Contract
 * 
 * This script performs automated security checks including:
 * - Dependency vulnerability scanning
 * - Contract compilation verification
 * - Gas optimization analysis
 * - Basic security pattern checks
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
};

function log(message, color = colors.reset) {
  console.log(`${color}${message}${colors.reset}`);
}

function logSection(title) {
  console.log('\n' + '='.repeat(60));
  log(title, colors.blue);
  console.log('='.repeat(60));
}

function checkCommand(command, errorMessage) {
  try {
    execSync(command, { stdio: 'pipe' });
    return true;
  } catch (error) {
    log(`❌ ${errorMessage}`, colors.red);
    return false;
  }
}

async function runAudit() {
  logSection('SupplyChain Contract Security Audit');
  
  const results = {
    passed: [],
    failed: [],
    warnings: [],
  };

  // 1. Check if Hardhat is installed
  logSection('1. Environment Check');
  if (checkCommand('npx hardhat --version', 'Hardhat not found')) {
    log('✅ Hardhat is installed', colors.green);
    results.passed.push('Hardhat installation');
  } else {
    results.failed.push('Hardhat installation');
    return;
  }

  // 2. Compile contracts
  logSection('2. Contract Compilation');
  if (checkCommand('npx hardhat compile', 'Contract compilation failed')) {
    log('✅ Contracts compiled successfully', colors.green);
    results.passed.push('Contract compilation');
  } else {
    results.failed.push('Contract compilation');
    return;
  }

  // 3. Run tests
  logSection('3. Test Execution');
  if (checkCommand('npx hardhat test', 'Tests failed')) {
    log('✅ All tests passed', colors.green);
    results.passed.push('Test execution');
  } else {
    results.failed.push('Test execution');
  }

  // 4. Check for common security patterns
  logSection('4. Security Pattern Checks');
  const contractPath = path.join(__dirname, '../contracts/SupplyChain.sol');
  const contractContent = fs.readFileSync(contractPath, 'utf8');

  const securityChecks = [
    {
      name: 'ReentrancyGuard',
      pattern: /ReentrancyGuard/,
      required: true,
    },
    {
      name: 'Pausable',
      pattern: /Pausable/,
      required: true,
    },
    {
      name: 'AccessControl',
      pattern: /AccessControl/,
      required: true,
    },
    {
      name: 'Input validation',
      pattern: /require\(.*description/,
      required: true,
    },
    {
      name: 'Zero address check',
      pattern: /address\(0\)/,
      required: true,
    },
    {
      name: 'Events emitted',
      pattern: /emit\s+\w+\(/,
      required: true,
    },
    {
      name: 'No unsafe external calls',
      pattern: /\.call\(|\.delegatecall\(|\.send\(/,
      required: false,
      warning: true,
    },
  ];

  securityChecks.forEach(check => {
    const found = check.pattern.test(contractContent);
    if (check.required) {
      if (found) {
        log(`✅ ${check.name} found`, colors.green);
        results.passed.push(check.name);
      } else {
        log(`❌ ${check.name} not found`, colors.red);
        results.failed.push(check.name);
      }
    } else if (check.warning && found) {
      log(`⚠️  ${check.name} detected - review manually`, colors.yellow);
      results.warnings.push(check.name);
    }
  });

  // 5. Dependency audit
  logSection('5. Dependency Audit');
  try {
    const auditOutput = execSync('npm audit --json', { encoding: 'utf8' });
    const audit = JSON.parse(auditOutput);
    if (audit.metadata.vulnerabilities.total === 0) {
      log('✅ No known vulnerabilities in dependencies', colors.green);
      results.passed.push('Dependency audit');
    } else {
      log(`⚠️  Found ${audit.metadata.vulnerabilities.total} vulnerabilities`, colors.yellow);
      results.warnings.push('Dependency vulnerabilities');
    }
  } catch (error) {
    log('⚠️  Could not run npm audit', colors.yellow);
    results.warnings.push('Dependency audit');
  }

  // 6. Gas optimization check
  logSection('6. Gas Optimization');
  log('ℹ️  Run "npx hardhat test --gas-reporter" for detailed gas analysis', colors.yellow);
  results.warnings.push('Gas optimization analysis');

  // Summary
  logSection('Audit Summary');
  log(`✅ Passed: ${results.passed.length}`, colors.green);
  log(`❌ Failed: ${results.failed.length}`, colors.red);
  log(`⚠️  Warnings: ${results.warnings.length}`, colors.yellow);

  if (results.failed.length > 0) {
    log('\nFailed checks:', colors.red);
    results.failed.forEach(check => log(`  - ${check}`, colors.red));
  }

  if (results.warnings.length > 0) {
    log('\nWarnings:', colors.yellow);
    results.warnings.forEach(warning => log(`  - ${warning}`, colors.yellow));
  }

  // Recommendations
  logSection('Recommendations');
  log('1. Run Slither: npm install -g slither-analyzer && slither .', colors.yellow);
  log('2. Run Mythril: mythril analyze contracts/SupplyChain.sol', colors.yellow);
  log('3. Consider formal verification for critical functions', colors.yellow);
  log('4. Perform manual code review', colors.yellow);
  log('5. Consider professional security audit before mainnet deployment', colors.yellow);

  process.exit(results.failed.length > 0 ? 1 : 0);
}

runAudit().catch(error => {
  log(`\n❌ Audit failed with error: ${error.message}`, colors.red);
  process.exit(1);
});

