/**
 * @Author: Mukhil Sundararaj
 * @Date: 2025-11-29
 * @Description: Script to verify contract on Etherscan
 * 
 * Usage (via hardhat run):
 *   CONTRACT_ADDRESS=0x... hardhat run scripts/verify.js --network sepolia
 * 
 * Usage (direct node):
 *   CONTRACT_ADDRESS=0x... node scripts/verify.js
 * 
 * Example:
 *   CONTRACT_ADDRESS=0x1234567890123456789012345678901234567890 hardhat run scripts/verify.js --network sepolia
 */

const { run } = require("hardhat");

async function main() {
  // Get contract address from environment variable or command line argument
  const contractAddress = process.env.CONTRACT_ADDRESS || process.argv[2];
  
  if (!contractAddress) {
    console.error("Error: Contract address is required");
    console.log("\nUsage options:");
    console.log("  1. CONTRACT_ADDRESS=0x... hardhat run scripts/verify.js --network sepolia");
    console.log("  2. CONTRACT_ADDRESS=0x... node scripts/verify.js");
    console.log("  3. node scripts/verify.js 0x...");
    console.log("\nOr use the direct hardhat verify command:");
    console.log("  npx hardhat verify --network sepolia <CONTRACT_ADDRESS>");
    process.exit(1);
  }

  console.log(`Verifying contract at address: ${contractAddress}`);

  try {
    // Verify the contract
    // The constructor arguments are empty since SupplyChain constructor takes no parameters
    await run("verify:verify", {
      address: contractAddress,
      constructorArguments: [], // SupplyChain constructor has no parameters
    });

    console.log("✅ Contract verified successfully on Etherscan!");
    console.log(`View on Etherscan: https://sepolia.etherscan.io/address/${contractAddress}`);
  } catch (error) {
    if (error.message.toLowerCase().includes("already verified")) {
      console.log("✅ Contract is already verified on Etherscan!");
      console.log(`View on Etherscan: https://sepolia.etherscan.io/address/${contractAddress}`);
    } else {
      console.error("❌ Verification failed:", error.message);
      process.exit(1);
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

