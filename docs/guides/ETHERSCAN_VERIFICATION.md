# Etherscan Contract Verification Guide

This guide explains how to verify your SupplyChain smart contract on Etherscan (or Sepolia Etherscan for testnets).

## Prerequisites

1. **Etherscan API Key**: You need an API key from Etherscan
   - Go to [Etherscan.io](https://etherscan.io) and create an account
   - Navigate to [API Keys](https://etherscan.io/apis)
   - Create a new API key
   - Copy the API key

2. **Deployed Contract**: Your contract must be deployed to a network (Sepolia testnet or Mainnet)

3. **Contract Address**: The address where your contract was deployed

## Setup

### 1. Add Etherscan API Key to Environment

Add your Etherscan API key to your `.env` file in the `supply-chain-contract` directory:

```bash
ETHERSCAN_API_KEY=your_api_key_here
```

**Note**: For different networks, you can use the same API key or create separate keys:
- Sepolia: Use Sepolia Etherscan API key
- Mainnet: Use Etherscan API key

### 2. Verify Installation

The verification plugin should already be installed. If not, run:

```bash
cd supply-chain-contract
npm install --save-dev @nomicfoundation/hardhat-verify@^2.0.0
```

## Verification Methods

### Method 1: Using Hardhat Verify Command (Recommended)

The easiest way to verify your contract is using Hardhat's verify command:

```bash
cd supply-chain-contract
npx hardhat verify --network sepolia <CONTRACT_ADDRESS>
```

**Example:**
```bash
npx hardhat verify --network sepolia 0x1234567890123456789012345678901234567890
```

Or using the npm script:
```bash
npm run verify:sepolia <CONTRACT_ADDRESS>
```

### Method 2: Using the Verification Script

You can also use the provided verification script with an environment variable:

```bash
cd supply-chain-contract
CONTRACT_ADDRESS=0x... hardhat run scripts/verify.js --network sepolia
```

**Example:**
```bash
CONTRACT_ADDRESS=0x1234567890123456789012345678901234567890 hardhat run scripts/verify.js --network sepolia
```

### Method 3: Manual Verification via Etherscan UI

If automated verification fails, you can verify manually:

1. Go to [Sepolia Etherscan](https://sepolia.etherscan.io) (or Etherscan for mainnet)
2. Navigate to your contract address
3. Click on the "Contract" tab
4. Click "Verify and Publish"
5. Fill in the verification form:
   - **Compiler Type**: Solidity (Single file) or Solidity (Standard JSON Input)
   - **Compiler Version**: 0.8.24
   - **License**: MIT
   - **Optimization**: Yes (200 runs)
   - **Source Code**: Copy and paste the contents of `contracts/SupplyChain.sol`
   - **Constructor Arguments**: Leave empty (SupplyChain constructor has no parameters)

## Important Notes

### Constructor Arguments

The SupplyChain contract constructor takes **no parameters**, so constructor arguments should be empty:

```javascript
constructorArguments: []
```

### Compiler Settings

Make sure your verification matches your deployment settings:
- **Solidity Version**: 0.8.24
- **Optimizer**: Enabled
- **Optimizer Runs**: 200

These settings are configured in `hardhat.config.js`.

### OpenZeppelin Dependencies

Since your contract imports OpenZeppelin contracts, Etherscan will automatically fetch and verify those dependencies. You don't need to provide them manually.

## Troubleshooting

### Error: "Contract already verified"

This means your contract is already verified. You can view it on Etherscan.

### Error: "Fail - Unable to verify" or "Compiled contract deployment bytecode does NOT match"

This is the most common verification error. It means the compiler settings used for verification don't match the settings used during deployment.

**Common causes:**
1. **Optimizer mismatch**: The optimizer was enabled/disabled differently during deployment
   - Check your `hardhat.config.js` optimizer settings
   - Check the cache file `cache/solidity-files-cache.json` to see what settings were used during deployment
   - Match the `optimizer.enabled` setting (true/false) to what was used during deployment
   
2. **Wrong network**: Make sure you're verifying on the same network where you deployed

3. **Wrong compiler version**: Ensure the compiler version matches (0.8.24)

4. **Wrong optimizer runs**: If optimizer was enabled, ensure the runs count matches (200)

5. **Contract not deployed**: Verify the contract address is correct

6. **API key issues**: Check that your ETHERSCAN_API_KEY is set correctly

**How to fix optimizer mismatch:**
1. Check `cache/solidity-files-cache.json` to see what settings were used:
   ```json
   "optimizer": {
     "enabled": false,  // or true
     "runs": 200
   }
   ```
2. Update `hardhat.config.js` to match these exact settings
3. Recompile: `npx hardhat compile`
4. Try verification again

### Error: "Invalid API Key"

1. Check that `ETHERSCAN_API_KEY` is set in your `.env` file
2. Verify the API key is correct on Etherscan
3. Make sure you're using the correct API key for the network (Sepolia vs Mainnet)

### Contract Source Code Not Found

If Etherscan can't find the source code:
1. Make sure you're using the correct contract address
2. Verify the contract was deployed from the same codebase
3. Try manual verification with the full source code

## Verification for Different Networks

### Sepolia Testnet

```bash
npm run verify:sepolia <CONTRACT_ADDRESS>
```

Or:
```bash
npx hardhat verify --network sepolia <CONTRACT_ADDRESS>
```

### Mainnet

```bash
npx hardhat verify --network mainnet <CONTRACT_ADDRESS>
```

**Note**: Make sure your `hardhat.config.js` has mainnet network configuration and you have the correct Etherscan API key.

## After Verification

Once verified, you can:
- View the verified source code on Etherscan
- Interact with the contract directly from Etherscan
- See all contract functions and events
- View contract creation transaction and constructor arguments

## Additional Resources

- [Hardhat Verification Documentation](https://hardhat.org/hardhat-runner/plugins/nomicfoundation-hardhat-verify)
- [Etherscan API Documentation](https://docs.etherscan.io/)
- [Sepolia Etherscan](https://sepolia.etherscan.io)

## Quick Reference

```bash
# Set environment variable
export ETHERSCAN_API_KEY=your_key_here

# Verify on Sepolia
npm run verify:sepolia 0xYourContractAddress

# Verify on Mainnet (if configured)
npx hardhat verify --network mainnet 0xYourContractAddress
```

