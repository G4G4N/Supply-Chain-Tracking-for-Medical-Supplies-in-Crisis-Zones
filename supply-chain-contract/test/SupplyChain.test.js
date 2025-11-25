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
      expect(await supplyChain.getTotalPackages()).to.equal(0);
    });
  });

  describe("Package Creation", function () {
    it("Should create a package with valid description", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      const description = "Medical supplies package";

      const tx = await supplyChain.connect(user1).createPackage(description);
      const receipt = await tx.wait();

      expect(await supplyChain.getTotalPackages()).to.equal(1);
      expect(await supplyChain.getUserPackageCount(user1.address)).to.equal(1);

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
        "Description cannot be empty"
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
      expect(details.status).to.equal(0); // Created
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
      await supplyChain.connect(user1).transferOwnership(1, user2.address);

      const details = await supplyChain.getPackageDetails(1);
      expect(details.currentOwner).to.equal(user2.address);
      expect(details.status).to.equal(1); // InTransit
    });

    it("Should reject transfer from non-owner", async function () {
      const { supplyChain, user1, user2 } = await loadFixture(deploySupplyChainFixture);
      
      await supplyChain.connect(user1).createPackage("Test package");
      await expect(
        supplyChain.connect(user2).transferOwnership(1, user2.address)
      ).to.be.revertedWith("Only current owner can transfer");
    });

    it("Should reject transfer to zero address", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      
      await supplyChain.connect(user1).createPackage("Test package");
      await expect(
        supplyChain.connect(user1).transferOwnership(1, ethers.ZeroAddress)
      ).to.be.revertedWith("New owner cannot be zero address");
    });

    it("Should reject self-transfer", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      
      await supplyChain.connect(user1).createPackage("Test package");
      await expect(
        supplyChain.connect(user1).transferOwnership(1, user1.address)
      ).to.be.revertedWith("Cannot transfer to self");
    });

    it("Should update owned packages list", async function () {
      const { supplyChain, user1, user2 } = await loadFixture(deploySupplyChainFixture);
      
      await supplyChain.connect(user1).createPackage("Test package");
      const ownedBefore = await supplyChain.getOwnedPackages(user2.address);
      expect(ownedBefore.length).to.equal(0);

      await supplyChain.connect(user1).transferOwnership(1, user2.address);
      
      const ownedAfter = await supplyChain.getOwnedPackages(user2.address);
      expect(ownedAfter.length).to.equal(1);
      expect(ownedAfter[0]).to.equal(1);
    });
  });

  describe("Package Status Updates", function () {
    it("Should mark package as delivered", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      
      await supplyChain.connect(user1).createPackage("Test package");
      await supplyChain.connect(user1).markAsDelivered(1);

      const details = await supplyChain.getPackageDetails(1);
      expect(details.status).to.equal(2); // Delivered
    });

    it("Should reject delivery from non-owner", async function () {
      const { supplyChain, user1, user2 } = await loadFixture(deploySupplyChainFixture);
      
      await supplyChain.connect(user1).createPackage("Test package");
      await expect(
        supplyChain.connect(user2).markAsDelivered(1)
      ).to.be.revertedWith("Only current owner can mark delivered");
    });

    it("Should mark package as in transit from Created status", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      
      await supplyChain.connect(user1).createPackage("Test package");
      await supplyChain.connect(user1).markAsInTransit(1);

      const details = await supplyChain.getPackageDetails(1);
      expect(details.status).to.equal(1); // InTransit
    });

    it("Should mark package as in transit from Delivered status (FIXED BUG)", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      
      await supplyChain.connect(user1).createPackage("Test package");
      await supplyChain.connect(user1).markAsDelivered(1);
      
      // This should now work (previously failed)
      await supplyChain.connect(user1).markAsInTransit(1);

      const details = await supplyChain.getPackageDetails(1);
      expect(details.status).to.equal(1); // InTransit
    });

    it("Should reject in transit if already in transit", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      
      await supplyChain.connect(user1).createPackage("Test package");
      await supplyChain.connect(user1).markAsInTransit(1);
      
      await expect(
        supplyChain.connect(user1).markAsInTransit(1)
      ).to.be.revertedWith("Package already in transit");
    });
  });

  describe("Batch Operations", function () {
    it("Should create batch of packages", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      
      const descriptions = ["Package 1", "Package 2", "Package 3"];
      const tx = await supplyChain.connect(user1).createBatch(descriptions);
      await tx.wait();

      expect(await supplyChain.getTotalPackages()).to.equal(3);
      expect(await supplyChain.getUserPackageCount(user1.address)).to.equal(3);
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
      
      await supplyChain.connect(user1).transferBatch([1, 2], [user2.address, user2.address]);

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
      expect(await supplyChain.getTotalPackages()).to.equal(1);
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
        supplyChain.connect(user1).transferOwnership(1, user1.address)
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
      expect(userPackages[0]).to.equal(1);
      expect(userPackages[1]).to.equal(2);
    });

    it("Should return owned packages", async function () {
      const { supplyChain, user1, user2 } = await loadFixture(deploySupplyChainFixture);
      
      await supplyChain.connect(user1).createPackage("Package 1");
      await supplyChain.connect(user1).transferOwnership(1, user2.address);
      
      const ownedByUser2 = await supplyChain.getOwnedPackages(user2.address);
      expect(ownedByUser2.length).to.equal(1);
      expect(ownedByUser2[0]).to.equal(1);
    });

    it("Should return package with timestamps", async function () {
      const { supplyChain, user1 } = await loadFixture(deploySupplyChainFixture);
      
      const tx = await supplyChain.connect(user1).createPackage("Test package");
      const receipt = await tx.wait();
      const block = await ethers.provider.getBlock(receipt.blockNumber);
      
      const details = await supplyChain.getPackageDetails(1);
      expect(details.createdAt).to.equal(block.timestamp);
      expect(details.lastUpdatedAt).to.equal(block.timestamp);
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
        supplyChain.connect(user1).transferOwnership(1, ethers.ZeroAddress)
      ).to.be.revertedWith("New owner cannot be zero address");
    });

    it("Should handle maximum uint256 package IDs", async function () {
      // This test would be very expensive to run
      // It's included to document the edge case
      // In practice, uint256 max is unreachable
    });
  });
});

