## Setup

Prerequisites

- Node.js 18+ and npm
- Git
- A browser wallet (e.g., MetaMask)

Repository layout

- `supply-chain-contract/`: Hardhat project with `SupplyChain.sol`
- `supply-chain-dapp/`: React app (Create React App)

Install dependencies

1) Contracts

```bash
cd "supply-chain-contract"
npm install
```

2) Dapp

```bash
cd "../supply-chain-dapp"
npm install
```

Environment variables (optional for testnet)

- Create `supply-chain-contract/.env` with:

```bash
SEPOLIA_RPC_URL="https://sepolia.infura.io/v3/<your-key>"
PRIVATE_KEY="0x<your-private-key>"
```

Local development networks

- Use Hardhat's in-memory network for quick local testing:

```bash
cd "supply-chain-contract"
npx hardhat node | cat
```

Run the dapp locally

```bash
cd "supply-chain-dapp"
npm start
```

You can connect MetaMask to the same network your contract is deployed to (local, or Sepolia) before using the app.


