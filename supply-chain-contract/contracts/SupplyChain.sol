// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title SupplyChain
 * @dev Enterprise-grade supply chain tracking contract with security, access control, and gas optimizations
 * @notice Tracks medical supplies packages through their lifecycle with comprehensive security measures
 */
contract SupplyChain is Ownable, AccessControl, ReentrancyGuard, Pausable {
    // Role definitions
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant VIEWER_ROLE = keccak256("VIEWER_ROLE");

    enum Status {
        Created,
        InTransit,
        Delivered
    }

    struct Package {
        uint256 id;
        string description;
        address creator;
        address currentOwner;
        Status status;
        uint256 createdAt;
        uint256 lastUpdatedAt;
    }

    // Constants
    uint256 public constant MAX_DESCRIPTION_LENGTH = 500;
    uint256 public constant MIN_DESCRIPTION_LENGTH = 3;
    uint256 public constant MAX_PACKAGES_PER_USER = 1000; // Prevent DoS
    uint256 public constant MAX_BATCH_SIZE = 50; // Gas limit protection

    // State variables
    uint256 private nextPackageId = 1;
    mapping(uint256 => Package) private packages;
    mapping(address => uint256[]) private userPackages; // Packages created by user
    mapping(address => uint256[]) private ownedPackages; // Packages owned by user
    mapping(address => uint256) private packageCount; // Count per user for rate limiting
    uint256 public totalPackages;

    // Events with proper indexing
    event PackageCreated(
        uint256 indexed id,
        string description,
        address indexed creator,
        uint256 timestamp
    );
    event PackageTransferred(
        uint256 indexed id,
        address indexed from,
        address indexed to,
        Status status,
        uint256 timestamp
    );
    event PackageDelivered(
        uint256 indexed id,
        address indexed owner,
        uint256 timestamp
    );
    event PackageStatusUpdated(
        uint256 indexed id,
        Status oldStatus,
        Status newStatus,
        address indexed updater,
        uint256 timestamp
    );

    // Modifiers
    modifier validPackageId(uint256 packageId) {
        require(packageId >= 1 && packageId < nextPackageId, "Package does not exist");
        _;
    }

    modifier validDescription(string calldata description) {
        bytes memory descBytes = bytes(description);
        require(descBytes.length >= MIN_DESCRIPTION_LENGTH, "Description too short");
        require(descBytes.length <= MAX_DESCRIPTION_LENGTH, "Description too long");
        require(bytes(description).length > 0, "Description cannot be empty");
        _;
    }

    modifier notSelfTransfer(address newOwner) {
        require(newOwner != msg.sender, "Cannot transfer to self");
        _;
    }

    modifier rateLimitCheck() {
        require(
            packageCount[msg.sender] < MAX_PACKAGES_PER_USER,
            "Package limit exceeded"
        );
        _;
    }

    constructor() Ownable(msg.sender) Pausable() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(OPERATOR_ROLE, msg.sender);
    }

    /**
     * @dev Create a new package
     * @param description Package description (3-500 characters)
     * @return packageId The ID of the newly created package
     */
    function createPackage(string calldata description)
        external
        whenNotPaused
        nonReentrant
        validDescription(description)
        rateLimitCheck
        returns (uint256)
    {
        uint256 packageId = nextPackageId;
        uint256 timestamp = block.timestamp;

        packages[packageId] = Package({
            id: packageId,
            description: description,
            creator: msg.sender,
            currentOwner: msg.sender,
            status: Status.Created,
            createdAt: timestamp,
            lastUpdatedAt: timestamp
        });

        userPackages[msg.sender].push(packageId);
        ownedPackages[msg.sender].push(packageId);
        packageCount[msg.sender]++;
        totalPackages++;
        nextPackageId++;

        emit PackageCreated(packageId, description, msg.sender, timestamp);
        return packageId;
    }

    /**
     * @dev Transfer package ownership
     * @param packageId The ID of the package to transfer
     * @param newOwner The new owner address
     */
    function transferOwnership(uint256 packageId, address newOwner)
        external
        whenNotPaused
        nonReentrant
        validPackageId(packageId)
        notSelfTransfer(newOwner)
    {
        Package storage pkg = packages[packageId];
        require(msg.sender == pkg.currentOwner, "Only current owner can transfer");
        require(newOwner != address(0), "New owner cannot be zero address");

        address previousOwner = pkg.currentOwner;
        uint256 timestamp = block.timestamp;

        // Remove from previous owner's list
        _removeFromOwnedList(previousOwner, packageId);
        
        // Update package
        pkg.currentOwner = newOwner;
        pkg.status = Status.InTransit;
        pkg.lastUpdatedAt = timestamp;

        // Add to new owner's list
        ownedPackages[newOwner].push(packageId);

        emit PackageTransferred(packageId, previousOwner, newOwner, pkg.status, timestamp);
    }

    /**
     * @dev Mark package as delivered
     * @param packageId The ID of the package to mark as delivered
     */
    function markAsDelivered(uint256 packageId)
        external
        whenNotPaused
        nonReentrant
        validPackageId(packageId)
    {
        Package storage pkg = packages[packageId];
        require(msg.sender == pkg.currentOwner, "Only current owner can mark delivered");
        require(pkg.status != Status.Delivered, "Package already delivered");

        Status oldStatus = pkg.status;
        pkg.status = Status.Delivered;
        pkg.lastUpdatedAt = block.timestamp;

        emit PackageDelivered(packageId, pkg.currentOwner, block.timestamp);
        emit PackageStatusUpdated(packageId, oldStatus, Status.Delivered, msg.sender, block.timestamp);
    }

    /**
     * @dev Mark package as in transit (fixed logic - can be called from Created or Delivered status)
     * @param packageId The ID of the package to mark as in transit
     */
    function markAsInTransit(uint256 packageId)
        external
        whenNotPaused
        nonReentrant
        validPackageId(packageId)
    {
        Package storage pkg = packages[packageId];
        require(msg.sender == pkg.currentOwner, "Only current owner can mark in transit");
        require(
            pkg.status == Status.Created || pkg.status == Status.Delivered,
            "Package must be Created or Delivered to mark as InTransit"
        );
        require(pkg.status != Status.InTransit, "Package already in transit");

        Status oldStatus = pkg.status;
        pkg.status = Status.InTransit;
        pkg.lastUpdatedAt = block.timestamp;

        emit PackageTransferred(packageId, pkg.currentOwner, pkg.currentOwner, pkg.status, block.timestamp);
        emit PackageStatusUpdated(packageId, oldStatus, Status.InTransit, msg.sender, block.timestamp);
    }

    /**
     * @dev Batch create packages (gas optimized)
     * @param descriptions Array of package descriptions
     * @return packageIds Array of created package IDs
     */
    function createBatch(string[] calldata descriptions)
        external
        whenNotPaused
        nonReentrant
        returns (uint256[] memory)
    {
        require(descriptions.length > 0, "Empty batch");
        require(descriptions.length <= MAX_BATCH_SIZE, "Batch size too large");
        require(
            packageCount[msg.sender] + descriptions.length <= MAX_PACKAGES_PER_USER,
            "Package limit exceeded"
        );

        uint256[] memory packageIds = new uint256[](descriptions.length);
        uint256 timestamp = block.timestamp;

        for (uint256 i = 0; i < descriptions.length; i++) {
            bytes memory descBytes = bytes(descriptions[i]);
            require(
                descBytes.length >= MIN_DESCRIPTION_LENGTH &&
                    descBytes.length <= MAX_DESCRIPTION_LENGTH,
                "Invalid description length"
            );

            uint256 packageId = nextPackageId;
            packages[packageId] = Package({
                id: packageId,
                description: descriptions[i],
                creator: msg.sender,
                currentOwner: msg.sender,
                status: Status.Created,
                createdAt: timestamp,
                lastUpdatedAt: timestamp
            });

            userPackages[msg.sender].push(packageId);
            ownedPackages[msg.sender].push(packageId);
            packageIds[i] = packageId;
            nextPackageId++;
            totalPackages++;

            emit PackageCreated(packageId, descriptions[i], msg.sender, timestamp);
        }

        packageCount[msg.sender] += descriptions.length;
        return packageIds;
    }

    /**
     * @dev Batch transfer packages
     * @param packageIds Array of package IDs to transfer
     * @param newOwners Array of new owner addresses (must match packageIds length)
     */
    function transferBatch(uint256[] calldata packageIds, address[] calldata newOwners)
        external
        whenNotPaused
        nonReentrant
    {
        require(packageIds.length > 0, "Empty batch");
        require(packageIds.length == newOwners.length, "Array length mismatch");
        require(packageIds.length <= MAX_BATCH_SIZE, "Batch size too large");

        uint256 timestamp = block.timestamp;

        for (uint256 i = 0; i < packageIds.length; i++) {
            uint256 packageId = packageIds[i];
            address newOwner = newOwners[i];

            require(packageId >= 1 && packageId < nextPackageId, "Package does not exist");
            require(newOwner != address(0), "New owner cannot be zero address");
            require(newOwner != msg.sender, "Cannot transfer to self");

            Package storage pkg = packages[packageId];
            require(msg.sender == pkg.currentOwner, "Only current owner can transfer");

            address previousOwner = pkg.currentOwner;
            _removeFromOwnedList(previousOwner, packageId);

            pkg.currentOwner = newOwner;
            pkg.status = Status.InTransit;
            pkg.lastUpdatedAt = timestamp;

            ownedPackages[newOwner].push(packageId);

            emit PackageTransferred(packageId, previousOwner, newOwner, pkg.status, timestamp);
        }
    }

    /**
     * @dev Get package details
     * @param packageId The ID of the package
     * @return id Package ID
     * @return description Package description
     * @return creator Creator address
     * @return currentOwner Current owner address
     * @return status Current status
     * @return createdAt Creation timestamp
     * @return lastUpdatedAt Last update timestamp
     */
    function getPackageDetails(uint256 packageId)
        external
        view
        validPackageId(packageId)
        returns (
            uint256 id,
            string memory description,
            address creator,
            address currentOwner,
            Status status,
            uint256 createdAt,
            uint256 lastUpdatedAt
        )
    {
        Package storage pkg = packages[packageId];
        return (
            pkg.id,
            pkg.description,
            pkg.creator,
            pkg.currentOwner,
            pkg.status,
            pkg.createdAt,
            pkg.lastUpdatedAt
        );
    }

    /**
     * @dev Get packages created by a user
     * @param user The user address
     * @return packageIds Array of package IDs created by the user
     */
    function getUserPackages(address user)
        external
        view
        returns (uint256[] memory)
    {
        return userPackages[user];
    }

    /**
     * @dev Get packages owned by a user
     * @param user The user address
     * @return packageIds Array of package IDs owned by the user
     */
    function getOwnedPackages(address user)
        external
        view
        returns (uint256[] memory)
    {
        return ownedPackages[user];
    }

    /**
     * @dev Get package count for a user
     * @param user The user address
     * @return count Number of packages created by the user
     */
    function getUserPackageCount(address user) external view returns (uint256) {
        return packageCount[user];
    }

    /**
     * @dev Get total number of packages
     * @return count Total package count
     */
    function getTotalPackages() external view returns (uint256) {
        return totalPackages;
    }

    /**
     * @dev Pause contract (admin only)
     */
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    /**
     * @dev Unpause contract (admin only)
     */
    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    /**
     * @dev Remove package from owned list (internal helper)
     */
    function _removeFromOwnedList(address owner, uint256 packageId) internal {
        uint256[] storage owned = ownedPackages[owner];
        for (uint256 i = 0; i < owned.length; i++) {
            if (owned[i] == packageId) {
                owned[i] = owned[owned.length - 1];
                owned.pop();
                break;
            }
        }
    }

    /**
     * @dev Grant operator role (admin only)
     */
    function grantOperatorRole(address account) external onlyRole(ADMIN_ROLE) {
        _grantRole(OPERATOR_ROLE, account);
    }

    /**
     * @dev Revoke operator role (admin only)
     */
    function revokeOperatorRole(address account) external onlyRole(ADMIN_ROLE) {
        _revokeRole(OPERATOR_ROLE, account);
    }
}


