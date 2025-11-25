## Contract API — SupplyChain.sol

Address and ABI

- Address: your deployed address (see `deployment.md`)
- ABI: `supply-chain-contract/contract-abi.json`

Enums

- `enum Status { Created (0), InTransit (1), Delivered (2) }`

Structs

- `Package { id, description, creator, currentOwner, status }`

State

- `nextPackageId` (starts at 1)
- `packages` mapping `uint256 => Package`

Events

- `event PackageCreated(uint256 id, string description, address creator)`
- `event PackageTransferred(uint256 id, address from, address to, Status status)`
- `event PackageDelivered(uint256 id, address owner)`

Constructor

- `constructor() Ownable(msg.sender)` — sets deployer as owner (OpenZeppelin Ownable 5.x style).

Functions

- `createPackage(string description) returns (uint256 packageId)`
  - Caller becomes `creator` and `currentOwner`
  - Emits `PackageCreated`

- `transferOwnership(uint256 packageId, address newOwner)`
  - Requires: package exists; `msg.sender == currentOwner`; `newOwner != 0x0`
  - Sets `currentOwner = newOwner` and `status = InTransit`
  - Emits `PackageTransferred`

- `markAsDelivered(uint256 packageId)`
  - Requires: package exists; `msg.sender == currentOwner`
  - Sets `status = Delivered`
  - Emits `PackageDelivered`

- `getPackageDetails(uint256 packageId) view returns (uint256 id, string description, address creator, address currentOwner, Status status)`
  - Requires: package exists

Notes

- Package IDs start at 1 and increment by 1 on creation.
- The contract uses OpenZeppelin `Ownable` but owner-only functions are not exposed in this version; ownership pertains to contract admin if needed later.


