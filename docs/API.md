# API Documentation

## Smart Contract API

### Functions

#### createPackage
```solidity
function createPackage(string calldata description) external returns (uint256)
```
Creates a new package.

**Parameters:**
- `description`: Package description (3-500 characters)

**Returns:**
- `uint256`: Package ID

**Events:**
- `PackageCreated(uint256 indexed id, string description, address indexed creator, uint256 timestamp)`

#### transferOwnership
```solidity
function transferOwnership(uint256 packageId, address newOwner) external
```
Transfers package ownership.

**Parameters:**
- `packageId`: Package ID
- `newOwner`: New owner address

**Events:**
- `PackageTransferred(uint256 indexed id, address indexed from, address indexed to, Status status, uint256 timestamp)`

#### markAsDelivered
```solidity
function markAsDelivered(uint256 packageId) external
```
Marks package as delivered.

**Parameters:**
- `packageId`: Package ID

**Events:**
- `PackageDelivered(uint256 indexed id, address indexed owner, uint256 timestamp)`

#### markAsInTransit
```solidity
function markAsInTransit(uint256 packageId) external
```
Marks package as in transit.

**Parameters:**
- `packageId`: Package ID

**Events:**
- `PackageTransferred(uint256 indexed id, address indexed from, address indexed to, Status status, uint256 timestamp)`

#### getPackageDetails
```solidity
function getPackageDetails(uint256 packageId) external view returns (
    uint256 id,
    string memory description,
    address creator,
    address currentOwner,
    Status status,
    uint256 createdAt,
    uint256 lastUpdatedAt
)
```
Gets package details.

**Parameters:**
- `packageId`: Package ID

**Returns:**
- Package details struct

## Frontend API

### Hooks

#### useWallet
```javascript
const {
  account,
  provider,
  signer,
  network,
  loading,
  error,
  isConnected,
  connectWallet,
  disconnectWallet,
  switchNetwork,
} = useWallet();
```

#### useContract
```javascript
const {
  contract,
  loading,
  error,
  isReady,
  callContract,
  sendTransaction,
} = useContract(provider, signer, networkName);
```

#### useTransaction
```javascript
const {
  pendingTransactions,
  transactionHistory,
  loading,
  submitTransaction,
  getTransaction,
  cancelTransaction,
  estimateGas,
  getGasPrice,
} = useTransaction();
```

## WebSocket API

### Events

#### package_update
```javascript
{
  type: 'package_created' | 'package_transferred' | 'package_delivered',
  data: {
    id: string,
    // ... package data
  }
}
```

## Error Codes

- `NETWORK_ERROR`: Network connectivity issue
- `USER_REJECTED`: User rejected transaction
- `CONTRACT_ERROR`: Contract execution error
- `SYSTEM_ERROR`: Internal system error

