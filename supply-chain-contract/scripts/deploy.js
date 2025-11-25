/**
 * @Author: Mukhil Sundararaj
 * @Date:   2025-09-11 14:31:28
 * @Last Modified by:   Mukhil Sundararaj
 * @Last Modified time: 2025-09-11 18:11:17
 */
const { ethers } = require("hardhat");

async function main() {
  const SupplyChain = await ethers.getContractFactory("SupplyChain");
  const supplyChain = await SupplyChain.deploy();
  await supplyChain.waitForDeployment();

  console.log("SupplyChain deployed to:", await supplyChain.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});


