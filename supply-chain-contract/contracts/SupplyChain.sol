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
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");

    enum Status {
        Manufacturing,      // 0 - Initial creation
        QualityControl,     // 1 - Quality checks
        Warehouse,          // 2 - Stored in warehouse
        InTransit,          // 3 - Being transported
        Distribution,       // 4 - At distribution center
        Delivered           // 5 - Final delivery
    }

    enum AlertLevel {
        None,
        Warning,
        Critical
    }

    struct Package {
        uint256 id;
        string description;
        address creator;
        address currentOwner;
        Status status;
        uint256 createdAt;
        uint256 lastUpdatedAt;
        // Crisis zone monitoring fields
        int8 temperature; // Temperature in Celsius (can be negative)
        string location; // GPS coordinates or location hash
        uint8 humidity; // Humidity percentage (0-100)
        bool shockDetected; // Impact/shock detection flag
        uint256 expiryDate; // Expiry timestamp
        string batchNumber; // Batch/lot number
        string certification; // Certification hash/IPFS link
        AlertLevel alertLevel; // Emergency alert level
        bool verified; // Verification status
        address verifier; // Address of verifier
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
    event TemperatureUpdated(
        uint256 indexed id,
        int8 oldTemperature,
        int8 newTemperature,
        address indexed updater,
        uint256 timestamp
    );
    event LocationUpdated(
        uint256 indexed id,
        string location,
        address indexed updater,
        uint256 timestamp
    );
    event ShockDetected(
        uint256 indexed id,
        address indexed reporter,
        uint256 timestamp
    );
    event CertificationVerified(
        uint256 indexed id,
        string certificationHash,
        address indexed verifier,
        uint256 timestamp
    );
    event PackageVerified(
        uint256 indexed id,
        bool verified,
        address indexed verifier,
        uint256 timestamp
    );
    event AlertRaised(
        uint256 indexed id,
        AlertLevel level,
        string reason,
        address indexed reporter,
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
            status: Status.Manufacturing,
            createdAt: timestamp,
            lastUpdatedAt: timestamp,
            temperature: 0,
            location: "",
            humidity: 0,
            shockDetected: false,
            expiryDate: 0,
            batchNumber: "",
            certification: "",
            alertLevel: AlertLevel.None,
            verified: false,
            verifier: address(0)
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
        
        // Update package (maintain current status)
        pkg.currentOwner = newOwner;
        // Status remains unchanged during transfer
        pkg.lastUpdatedAt = timestamp;

        // Add to new owner's list
        ownedPackages[newOwner].push(packageId);

        emit PackageTransferred(packageId, previousOwner, newOwner, pkg.status, timestamp);
    }

    /**
     * @dev Update package status to Quality Control
     * @param packageId The ID of the package
     */
    function updateToQualityControl(uint256 packageId)
        external
        whenNotPaused
        nonReentrant
        validPackageId(packageId)
    {
        Package storage pkg = packages[packageId];
        require(msg.sender == pkg.currentOwner, "Only current owner can update status");
        require(pkg.status == Status.Manufacturing, "Package must be in Manufacturing status");

        Status oldStatus = pkg.status;
        pkg.status = Status.QualityControl;
        pkg.lastUpdatedAt = block.timestamp;

        emit PackageStatusUpdated(packageId, oldStatus, Status.QualityControl, msg.sender, block.timestamp);
    }

    /**
     * @dev Update package status to Warehouse
     * @param packageId The ID of the package
     */
    function updateToWarehouse(uint256 packageId)
        external
        whenNotPaused
        nonReentrant
        validPackageId(packageId)
    {
        Package storage pkg = packages[packageId];
        require(msg.sender == pkg.currentOwner, "Only current owner can update status");
        require(pkg.status == Status.QualityControl, "Package must be in Quality Control status");

        Status oldStatus = pkg.status;
        pkg.status = Status.Warehouse;
        pkg.lastUpdatedAt = block.timestamp;

        emit PackageStatusUpdated(packageId, oldStatus, Status.Warehouse, msg.sender, block.timestamp);
    }

    /**
     * @dev Update package status to In Transit
     * @param packageId The ID of the package
     */
    function updateToInTransit(uint256 packageId)
        external
        whenNotPaused
        nonReentrant
        validPackageId(packageId)
    {
        Package storage pkg = packages[packageId];
        require(msg.sender == pkg.currentOwner, "Only current owner can update status");
        require(pkg.status == Status.Warehouse, "Package must be in Warehouse status");

        Status oldStatus = pkg.status;
        pkg.status = Status.InTransit;
        pkg.lastUpdatedAt = block.timestamp;

        emit PackageStatusUpdated(packageId, oldStatus, Status.InTransit, msg.sender, block.timestamp);
    }

    /**
     * @dev Update package status to Distribution
     * @param packageId The ID of the package
     */
    function updateToDistribution(uint256 packageId)
        external
        whenNotPaused
        nonReentrant
        validPackageId(packageId)
    {
        Package storage pkg = packages[packageId];
        require(msg.sender == pkg.currentOwner, "Only current owner can update status");
        require(pkg.status == Status.InTransit, "Package must be in In Transit status");

        Status oldStatus = pkg.status;
        pkg.status = Status.Distribution;
        pkg.lastUpdatedAt = block.timestamp;

        emit PackageStatusUpdated(packageId, oldStatus, Status.Distribution, msg.sender, block.timestamp);
    }

    /**
     * @dev Update package status to Delivered
     * @param packageId The ID of the package
     */
    function updateToDelivered(uint256 packageId)
        external
        whenNotPaused
        nonReentrant
        validPackageId(packageId)
    {
        Package storage pkg = packages[packageId];
        require(msg.sender == pkg.currentOwner, "Only current owner can update status");
        require(pkg.status == Status.Distribution, "Package must be in Distribution status");
        require(pkg.status != Status.Delivered, "Package already delivered");

        Status oldStatus = pkg.status;
        pkg.status = Status.Delivered;
        pkg.lastUpdatedAt = block.timestamp;

        emit PackageDelivered(packageId, pkg.currentOwner, block.timestamp);
        emit PackageStatusUpdated(packageId, oldStatus, Status.Delivered, msg.sender, block.timestamp);
    }

    /**
     * @dev Generic status update function with sequential validation
     * @param packageId The ID of the package
     * @param newStatus The new status to set
     */
    function updateStatus(uint256 packageId, Status newStatus)
        external
        whenNotPaused
        nonReentrant
        validPackageId(packageId)
    {
        Package storage pkg = packages[packageId];
        require(msg.sender == pkg.currentOwner, "Only current owner can update status");
        
        Status currentStatus = pkg.status;
        require(uint256(newStatus) > uint256(currentStatus), "Can only advance status forward");
        require(uint256(newStatus) == uint256(currentStatus) + 1, "Can only advance one stage at a time");
        require(newStatus != Status.Delivered || currentStatus == Status.Distribution, "Invalid status transition");

        Status oldStatus = pkg.status;
        pkg.status = newStatus;
        pkg.lastUpdatedAt = block.timestamp;

        if (newStatus == Status.Delivered) {
            emit PackageDelivered(packageId, pkg.currentOwner, block.timestamp);
        }
        emit PackageStatusUpdated(packageId, oldStatus, newStatus, msg.sender, block.timestamp);
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
                status: Status.Manufacturing,
                createdAt: timestamp,
                lastUpdatedAt: timestamp,
                temperature: 0,
                location: "",
                humidity: 0,
                shockDetected: false,
                expiryDate: 0,
                batchNumber: "",
                certification: "",
                alertLevel: AlertLevel.None,
                verified: false,
                verifier: address(0)
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
            // Status remains unchanged during batch transfer
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
     * @return temperature Temperature in Celsius
     * @return location Location string
     * @return humidity Humidity percentage
     * @return shockDetected Shock detection flag
     * @return expiryDate Expiry timestamp
     * @return batchNumber Batch number
     * @return certification Certification hash
     * @return alertLevel Alert level
     * @return verified Verification status
     * @return verifier Verifier address
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
            uint256 lastUpdatedAt,
            int8 temperature,
            string memory location,
            uint8 humidity,
            bool shockDetected,
            uint256 expiryDate,
            string memory batchNumber,
            string memory certification,
            AlertLevel alertLevel,
            bool verified,
            address verifier
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
            pkg.lastUpdatedAt,
            pkg.temperature,
            pkg.location,
            pkg.humidity,
            pkg.shockDetected,
            pkg.expiryDate,
            pkg.batchNumber,
            pkg.certification,
            pkg.alertLevel,
            pkg.verified,
            pkg.verifier
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

    /**
     * @dev Update package temperature
     * @param packageId The ID of the package
     * @param temperature Temperature in Celsius
     */
    function updateTemperature(uint256 packageId, int8 temperature)
        external
        whenNotPaused
        nonReentrant
        validPackageId(packageId)
    {
        Package storage pkg = packages[packageId];
        require(
            msg.sender == pkg.currentOwner || hasRole(OPERATOR_ROLE, msg.sender),
            "Only owner or operator can update temperature"
        );

        int8 oldTemperature = pkg.temperature;
        pkg.temperature = temperature;
        pkg.lastUpdatedAt = block.timestamp;

        emit TemperatureUpdated(packageId, oldTemperature, temperature, msg.sender, block.timestamp);
    }

    /**
     * @dev Update package location
     * @param packageId The ID of the package
     * @param location GPS coordinates or location hash
     */
    function updateLocation(uint256 packageId, string calldata location)
        external
        whenNotPaused
        nonReentrant
        validPackageId(packageId)
    {
        Package storage pkg = packages[packageId];
        require(
            msg.sender == pkg.currentOwner || hasRole(OPERATOR_ROLE, msg.sender),
            "Only owner or operator can update location"
        );
        require(bytes(location).length <= 200, "Location string too long");

        pkg.location = location;
        pkg.lastUpdatedAt = block.timestamp;

        emit LocationUpdated(packageId, location, msg.sender, block.timestamp);
    }

    /**
     * @dev Update package humidity
     * @param packageId The ID of the package
     * @param humidity Humidity percentage (0-100)
     */
    function updateHumidity(uint256 packageId, uint8 humidity)
        external
        whenNotPaused
        nonReentrant
        validPackageId(packageId)
    {
        Package storage pkg = packages[packageId];
        require(
            msg.sender == pkg.currentOwner || hasRole(OPERATOR_ROLE, msg.sender),
            "Only owner or operator can update humidity"
        );
        require(humidity <= 100, "Humidity must be 0-100");

        pkg.humidity = humidity;
        pkg.lastUpdatedAt = block.timestamp;
    }

    /**
     * @dev Record shock detection
     * @param packageId The ID of the package
     */
    function recordShock(uint256 packageId)
        external
        whenNotPaused
        nonReentrant
        validPackageId(packageId)
    {
        Package storage pkg = packages[packageId];
        require(
            msg.sender == pkg.currentOwner || hasRole(OPERATOR_ROLE, msg.sender),
            "Only owner or operator can record shock"
        );

        pkg.shockDetected = true;
        pkg.lastUpdatedAt = block.timestamp;

        emit ShockDetected(packageId, msg.sender, block.timestamp);
    }

    /**
     * @dev Update package expiry date
     * @param packageId The ID of the package
     * @param expiryDate Expiry timestamp
     */
    function updateExpiryDate(uint256 packageId, uint256 expiryDate)
        external
        whenNotPaused
        nonReentrant
        validPackageId(packageId)
    {
        Package storage pkg = packages[packageId];
        require(
            msg.sender == pkg.currentOwner || hasRole(OPERATOR_ROLE, msg.sender),
            "Only owner or operator can update expiry date"
        );

        pkg.expiryDate = expiryDate;
        pkg.lastUpdatedAt = block.timestamp;
    }

    /**
     * @dev Update batch number
     * @param packageId The ID of the package
     * @param batchNumber Batch/lot number
     */
    function updateBatchNumber(uint256 packageId, string calldata batchNumber)
        external
        whenNotPaused
        nonReentrant
        validPackageId(packageId)
    {
        Package storage pkg = packages[packageId];
        require(
            msg.sender == pkg.currentOwner || hasRole(OPERATOR_ROLE, msg.sender),
            "Only owner or operator can update batch number"
        );
        require(bytes(batchNumber).length <= 100, "Batch number too long");

        pkg.batchNumber = batchNumber;
        pkg.lastUpdatedAt = block.timestamp;
    }

    /**
     * @dev Verify certification
     * @param packageId The ID of the package
     * @param certificationHash Certification hash/IPFS link
     */
    function verifyCertification(uint256 packageId, string calldata certificationHash)
        external
        whenNotPaused
        nonReentrant
        validPackageId(packageId)
    {
        Package storage pkg = packages[packageId];
        require(
            msg.sender == pkg.currentOwner || hasRole(VERIFIER_ROLE, msg.sender) || hasRole(OPERATOR_ROLE, msg.sender),
            "Only owner, verifier, or operator can verify certification"
        );
        require(bytes(certificationHash).length <= 200, "Certification hash too long");

        pkg.certification = certificationHash;
        pkg.lastUpdatedAt = block.timestamp;

        emit CertificationVerified(packageId, certificationHash, msg.sender, block.timestamp);
    }

    /**
     * @dev Verify package (verifier only)
     * @param packageId The ID of the package
     * @param verified Verification status
     */
    function verifyPackage(uint256 packageId, bool verified)
        external
        whenNotPaused
        nonReentrant
        validPackageId(packageId)
        onlyRole(VERIFIER_ROLE)
    {
        Package storage pkg = packages[packageId];
        pkg.verified = verified;
        pkg.verifier = msg.sender;
        pkg.lastUpdatedAt = block.timestamp;

        emit PackageVerified(packageId, verified, msg.sender, block.timestamp);
    }

    /**
     * @dev Raise emergency alert
     * @param packageId The ID of the package
     * @param level Alert level
     * @param reason Reason for alert
     */
    function raiseAlert(uint256 packageId, AlertLevel level, string calldata reason)
        external
        whenNotPaused
        nonReentrant
        validPackageId(packageId)
    {
        Package storage pkg = packages[packageId];
        require(
            msg.sender == pkg.currentOwner || hasRole(OPERATOR_ROLE, msg.sender) || hasRole(VERIFIER_ROLE, msg.sender),
            "Only owner, operator, or verifier can raise alerts"
        );
        require(bytes(reason).length <= 500, "Reason too long");
        require(level != AlertLevel.None, "Cannot raise None alert");

        pkg.alertLevel = level;
        pkg.lastUpdatedAt = block.timestamp;

        emit AlertRaised(packageId, level, reason, msg.sender, block.timestamp);
    }

    /**
     * @dev Grant verifier role (admin only)
     */
    function grantVerifierRole(address account) external onlyRole(ADMIN_ROLE) {
        _grantRole(VERIFIER_ROLE, account);
    }

    /**
     * @dev Revoke verifier role (admin only)
     */
    function revokeVerifierRole(address account) external onlyRole(ADMIN_ROLE) {
        _revokeRole(VERIFIER_ROLE, account);
    }
}


