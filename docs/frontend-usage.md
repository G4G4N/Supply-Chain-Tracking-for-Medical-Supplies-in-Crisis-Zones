## Frontend Usage and Workflows

This dapp lets users track and manage package lifecycle on-chain.

Connect wallet

- Open the app (`npm start` in `supply-chain-dapp`)
- Connect your wallet via the connect button
- Ensure network matches the deployed contract (localhost or Sepolia)

Track a package

- Use the search input in `Track Package`
- Enter a package ID (>= 1)
- The app calls `getPackageDetails(id)` and shows: ID, Description, Creator, Current Owner, Status

Owner actions

- When your connected account matches `currentOwner`, Owner Actions appear:
  - Transfer Package: calls `transferOwnership(id, newOwner)`
  - Mark as Delivered: calls `markAsDelivered(id)`
- The UI displays transaction status messages and refreshes details after confirmations

Components

- `PackageTracker`: orchestrates search, details, and owner actions
- `PackageSearch`: assists with selecting known packages
- `PackageHistory`: displays timeline/history (reads events)
- `QRCodeGenerator`: shows a QR for the selected package

Validation

- Package ID validated client-side (`validatePackageId`)
- Ethereum addresses validated (`validateAddress`)

Contract integration

- Uses `ethers.js` contract instance with `contract-abi.json`
- Methods used: `getPackageDetails`, `transferOwnership`, `markAsDelivered`


