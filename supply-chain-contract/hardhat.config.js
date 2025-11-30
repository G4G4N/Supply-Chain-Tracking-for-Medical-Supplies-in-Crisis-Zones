/**
 * @Author: Mukhil Sundararaj
 * @Date:   2025-09-11 14:31:16
 * @Last Modified by:   Mukhil Sundararaj
 * @Last Modified time: 2025-09-11 18:29:35
 */
require("dotenv").config();
require("@nomicfoundation/hardhat-ethers");
require("@nomicfoundation/hardhat-chai-matchers");
require("@nomicfoundation/hardhat-verify");

const { SEPOLIA_RPC_URL = "", PRIVATE_KEY = "", ETHERSCAN_API_KEY = "" } = process.env;

/**
 * Validates if a private key is valid (64 hex characters, optionally prefixed with 0x)
 * @param {string} key - The private key to validate
 * @returns {boolean} - True if valid, false otherwise
 */
function isValidPrivateKey(key) {
  if (!key || typeof key !== 'string') return false;
  // Remove 0x prefix if present
  const cleanKey = key.startsWith('0x') ? key.slice(2) : key;
  // Must be exactly 64 hex characters (32 bytes)
  return /^[0-9a-fA-F]{64}$/.test(cleanKey);
}

/** @type import('hardhat/config').HardhatUserConfig */
const config = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      viaIR: true, // Enable IR-based code generation to handle stack too deep errors
    },
  },
  networks: {},
  etherscan: {
    apiKey: ETHERSCAN_API_KEY,
  },
};

if (SEPOLIA_RPC_URL) {
  config.networks.sepolia = {
    url: SEPOLIA_RPC_URL,
    accounts: isValidPrivateKey(PRIVATE_KEY) ? [PRIVATE_KEY] : undefined,
    chainId: 11155111,
  };
}

module.exports = config;


