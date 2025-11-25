/**
 * @Author: Mukhil Sundararaj
 * @Date:   2025-09-11 14:31:16
 * @Last Modified by:   Mukhil Sundararaj
 * @Last Modified time: 2025-09-11 18:29:35
 */
require("dotenv").config();
require("@nomicfoundation/hardhat-ethers");

const { SEPOLIA_RPC_URL = "", PRIVATE_KEY = "" } = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
const config = {
  solidity: "0.8.24",
  networks: {},
};

if (SEPOLIA_RPC_URL) {
  config.networks.sepolia = {
    url: SEPOLIA_RPC_URL,
    accounts: PRIVATE_KEY ? [PRIVATE_KEY] : undefined,
    chainId: 11155111,
  };
}

module.exports = config;


