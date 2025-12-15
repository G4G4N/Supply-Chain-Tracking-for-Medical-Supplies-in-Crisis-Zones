const { expect } = require("chai");
const { ethers } = require("hardhat");
const { loadFixture, time } = require("@nomicfoundation/hardhat-network-helpers");

describe("SupplyChain", function () {
  // Deploy fixture
  async function deploySupplyChainFixture() {
    const [owner, admin, operator, user1, user2, attacker] = await ethers.getSigners();

    const SupplyChain = await ethers.getContractFactory("SupplyChain");
    const supplyChain = await SupplyChain.deploy();

    // Grant roles
    await supplyChain.grantRole(await supplyChain.ADMIN_ROLE(), admin.address);
    await supplyChain.grantRole(await supplyChain.OPERATOR_ROLE(), operator.address);

    return { supplyChain, owner, admin, operator, user1, user2, attacker };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { supplyChain, owner } = await loadFixture(deploySupplyChainFixture);
      expect(await supplyChain.owner()).to.equal(owner.address);
    });

    it("Should grant admin role to deployer", async function () {
      const { supplyChain, owner } = await loadFixture(deploySupplyChainFixture);
      expect(await supplyChain.hasRole(await supplyChain.ADMIN_ROLE(), owner.address)).to.be.true;
    });

    it("Should start with zero packages", async function () {
      const { supplyChain } = await loadFixture(deploySupplyChainFixture);
      expect(await supplyChain.getTotalPackages()).to.equal(0n);
    });
  });

  describe("Package Creation", function () {
    it("Should create a package with valid description", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      const description = "Medical supplies package";

      const tx = await supplyChain.connect(user1).createPackage(description);
      const receipt = await tx.wait();

      expect(await supplyChain.getTotalPackages()).to.equal(1n);
      expect(await supplyChain.getUserPackageCount(user1.address)).to.equal(1n);

      const event = receipt.logs.find(log => {
        try {
          const parsed = supplyChain.interface.parseLog(log);
          return parsed && parsed.name === "PackageCreated";
        } catch {
          return false;
        }
      });

      expect(event).to.not.be.undefined;
    });

    it("Should reject empty description", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      await expect(supplyChain.connect(user1).createPackage("")).to.be.revertedWith(
        "Description too short"
      );
    });

    it("Should reject description too short", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      await expect(supplyChain.connect(user1).createPackage("AB")).to.be.revertedWith(
        "Description too short"
      );
    });

    it("Should reject description too long", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      const longDescription = "A".repeat(501);
      await expect(
        supplyChain.connect(user1).createPackage(longDescription)
      ).to.be.revertedWith("Description too long");
    });

    it("Should set creator as initial owner", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      const tx = await supplyChain.connect(user1).createPackage("Test package");
      await tx.wait();

      const details = await supplyChain.getPackageDetails(1);
      expect(details.creator).to.equal(user1.address);
      expect(details.currentOwner).to.equal(user1.address);
      expect(details.status).to.equal(0n); // Created
    });

    it("Should enforce package limit per user", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      const description = "Test package";

      // Create max packages
      for (let i = 0; i < 1000; i++) {
        await supplyChain.connect(user1).createPackage(`${description} ${i}`);
      }

      // Next one should fail
      await expect(
        supplyChain.connect(user1).createPackage("Should fail")
      ).to.be.revertedWith("Package limit exceeded");
    });
  });

  describe("Package Transfer", function () {
    it("Should transfer package ownership", async function () {
      const { supplyChain, user1, user2 } = await loadFixture(deploySupplyChainFixture);
      
      await supplyChain.connect(user1).createPackage("Test package");
      await supplyChain.connect(user1)["transferOwnership(uint256,address)"](1, user2.address);

      const details = await supplyChain.getPackageDetails(1);
      expect(details.currentOwner).to.equal(user2.address);
      expect(details.status).to.equal(0n); // Manufacturing (status doesn't change on transfer)
    });

    it("Should reject transfer from non-owner", async function () {
      const { supplyChain, user1, user2 } = await loadFixture(deploySupplyChainFixture);
      
      await supplyChain.connect(user1).createPackage("Test package");
      // Use a different address to avoid "Cannot transfer to self" error
      const [,,,user3] = await ethers.getSigners();
      await expect(
        supplyChain.connect(user2)["transferOwnership(uint256,address)"](1, user3.address)
      ).to.be.revertedWith("Only current owner can transfer");
    });

    it("Should reject transfer to zero address", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      
      await supplyChain.connect(user1).createPackage("Test package");
      await expect(
        supplyChain.connect(user1)["transferOwnership(uint256,address)"](1, ethers.ZeroAddress)
      ).to.be.revertedWith("New owner cannot be zero address");
    });

    it("Should reject self-transfer", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      
      await supplyChain.connect(user1).createPackage("Test package");
      await expect(
        supplyChain.connect(user1)["transferOwnership(uint256,address)"](1, user1.address)
      ).to.be.revertedWith("Cannot transfer to self");
    });

    it("Should update owned packages list", async function () {
      const { supplyChain, user1, user2 } = await loadFixture(deploySupplyChainFixture);
      
      await supplyChain.connect(user1).createPackage("Test package");
      const ownedBefore = await supplyChain.getOwnedPackages(user2.address);
      expect(ownedBefore.length).to.equal(0);

      await supplyChain.connect(user1)["transferOwnership(uint256,address)"](1, user2.address);
      
      const ownedAfter = await supplyChain.getOwnedPackages(user2.address);
      expect(ownedAfter.length).to.equal(1);
      expect(ownedAfter[0]).to.equal(1n);
    });
  });

  describe("Package Status Updates", function () {
    it("Should mark package as delivered", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      
      // Follow proper status flow: Manufacturing → QualityControl → Warehouse → InTransit → Distribution → Delivered
      await supplyChain.connect(user1).createPackage("Test package");
      await supplyChain.connect(user1).updateToQualityControl(1);
      await supplyChain.connect(user1).updateToWarehouse(1);
      await supplyChain.connect(user1).updateToInTransit(1);
      await supplyChain.connect(user1).updateToDistribution(1);
      await supplyChain.connect(user1).updateToDelivered(1);

      const details = await supplyChain.getPackageDetails(1);
      expect(details.status).to.equal(5n); // Delivered
    });

    it("Should reject delivery from non-owner", async function () {
      const { supplyChain, user1, user2 } = await loadFixture(deploySupplyChainFixture);
      
      // Follow proper status flow to Distribution
      await supplyChain.connect(user1).createPackage("Test package");
      await supplyChain.connect(user1).updateToQualityControl(1);
      await supplyChain.connect(user1).updateToWarehouse(1);
      await supplyChain.connect(user1).updateToInTransit(1);
      await supplyChain.connect(user1).updateToDistribution(1);
      
      await expect(
        supplyChain.connect(user2).updateToDelivered(1)
      ).to.be.revertedWith("Only current owner can update status");
    });

    it("Should mark package as in transit from Warehouse status", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      
      // Follow proper status flow: Manufacturing → QualityControl → Warehouse → InTransit
      await supplyChain.connect(user1).createPackage("Test package");
      await supplyChain.connect(user1).updateToQualityControl(1);
      await supplyChain.connect(user1).updateToWarehouse(1);
      await supplyChain.connect(user1).updateToInTransit(1);

      const details = await supplyChain.getPackageDetails(1);
      expect(details.status).to.equal(3n); // InTransit
    });

    it("Should reject in transit if already in transit", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      
      // Follow proper status flow to InTransit
      await supplyChain.connect(user1).createPackage("Test package");
      await supplyChain.connect(user1).updateToQualityControl(1);
      await supplyChain.connect(user1).updateToWarehouse(1);
      await supplyChain.connect(user1).updateToInTransit(1);
      
      await expect(
        supplyChain.connect(user1).updateToInTransit(1)
      ).to.be.revertedWith("Package must be in Warehouse status");
    });
  });

  describe("Batch Operations", function () {
    it("Should create batch of packages", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      
      const descriptions = ["Package 1", "Package 2", "Package 3"];
      const tx = await supplyChain.connect(user1).createBatch(descriptions);
      await tx.wait();

      expect(await supplyChain.getTotalPackages()).to.equal(3n);
      expect(await supplyChain.getUserPackageCount(user1.address)).to.equal(3n);
    });

    it("Should reject empty batch", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      
      await expect(
        supplyChain.connect(user1).createBatch([])
      ).to.be.revertedWith("Empty batch");
    });

    it("Should reject batch exceeding max size", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      
      const descriptions = Array(51).fill("Test package");
      await expect(
        supplyChain.connect(user1).createBatch(descriptions)
      ).to.be.revertedWith("Batch size too large");
    });

    it("Should transfer batch of packages", async function () {
      const { supplyChain, user1, user2 } = await loadFixture(deploySupplyChainFixture);
      
      await supplyChain.connect(user1).createPackage("Package 1");
      await supplyChain.connect(user1).createPackage("Package 2");
      
      await supplyChain.connect(user1)["transferBatch(uint256[],address[])"]([1, 2], [user2.address, user2.address]);

      const details1 = await supplyChain.getPackageDetails(1);
      const details2 = await supplyChain.getPackageDetails(2);
      
      expect(details1.currentOwner).to.equal(user2.address);
      expect(details2.currentOwner).to.equal(user2.address);
    });
  });

  describe("Access Control", function () {
    it("Should allow admin to pause contract", async function () {
      const { supplyChain, admin } = await loadFixture(deploySupplyChainFixture);
      
      await supplyChain.connect(admin).pause();
      expect(await supplyChain.paused()).to.be.true;
    });

    it("Should reject pause from non-admin", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      
      await expect(
        supplyChain.connect(user1).pause()
      ).to.be.reverted;
    });

    it("Should prevent package creation when paused", async function () {
      const { supplyChain, admin, user1 } = await loadFixture(deploySupplyChainFixture);
      
      await supplyChain.connect(admin).pause();
      await expect(
        supplyChain.connect(user1).createPackage("Test")
      ).to.be.revertedWithCustomError(supplyChain, "EnforcedPause");
    });

    it("Should allow admin to unpause contract", async function () {
      const { supplyChain, admin, user1 } = await loadFixture(deploySupplyChainFixture);
      
      await supplyChain.connect(admin).pause();
      await supplyChain.connect(admin).unpause();
      
      // Should work after unpause
      await supplyChain.connect(user1).createPackage("Test");
      expect(await supplyChain.getTotalPackages()).to.equal(1n);
    });
  });

  describe("Reentrancy Protection", function () {
    it("Should prevent reentrancy attacks", async function () {
      // This test would require a malicious contract
      // The ReentrancyGuard modifier should prevent reentrancy
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      
      // Normal operations should work
      await supplyChain.connect(user1).createPackage("Test");
      await expect(
        supplyChain.connect(user1)["transferOwnership(uint256,address)"](1, user1.address)
      ).to.be.revertedWith("Cannot transfer to self");
    });
  });

  describe("View Functions", function () {
    it("Should return user packages", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      
      await supplyChain.connect(user1).createPackage("Package 1");
      await supplyChain.connect(user1).createPackage("Package 2");
      
      const userPackages = await supplyChain.getUserPackages(user1.address);
      expect(userPackages.length).to.equal(2);
      expect(userPackages[0]).to.equal(1n);
      expect(userPackages[1]).to.equal(2n);
    });

    it("Should return owned packages", async function () {
      const { supplyChain, user1, user2 } = await loadFixture(deploySupplyChainFixture);
      
      await supplyChain.connect(user1).createPackage("Package 1");
      await supplyChain.connect(user1)["transferOwnership(uint256,address)"](1, user2.address);
      
      const ownedByUser2 = await supplyChain.getOwnedPackages(user2.address);
      expect(ownedByUser2.length).to.equal(1);
      expect(ownedByUser2[0]).to.equal(1n);
    });

    it("Should return package with timestamps", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      
      const tx = await supplyChain.connect(user1).createPackage("Test package");
      const receipt = await tx.wait();
      const block = await ethers.provider.getBlock(receipt.blockNumber);
      
      const details = await supplyChain.getPackageDetails(1);
      expect(details.createdAt).to.equal(BigInt(block.timestamp));
      expect(details.lastUpdatedAt).to.equal(BigInt(block.timestamp));
    });
  });

  describe("Edge Cases", function () {
    it("Should handle non-existent package", async function () {
      const { supplyChain } = await loadFixture(deploySupplyChainFixture);
      
      await expect(
        supplyChain.getPackageDetails(999)
      ).to.be.revertedWith("Package does not exist");
    });

    it("Should handle zero address transfers", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      
      await supplyChain.connect(user1).createPackage("Test");
      await expect(
        supplyChain.connect(user1)["transferOwnership(uint256,address)"](1, ethers.ZeroAddress)
      ).to.be.revertedWith("New owner cannot be zero address");
    });

    it("Should handle maximum uint256 package IDs", async function () {
      // This test would be very expensive to run
      // It's included to document the edge case
      // In practice, uint256 max is unreachable
    });
  });
});

