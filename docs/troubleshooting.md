## Troubleshooting

Wallet not connecting

- Ensure MetaMask is installed and unlocked
- Refresh the page after switching networks

Wrong network / no contract data

- Switch MetaMask to the network where you deployed (localhost or Sepolia)
- Confirm the dapp uses the correct contract address in its config

Package not found or invalid ID

- IDs start at 1 and are sequential
- Ensure the package exists on the selected network

Transfer fails: Only current owner can transfer

- Connect with the wallet that is the `currentOwner`
- Verify the recipient address is a valid EVM address and not zero address

Mark as delivered fails

- Only the current owner can mark delivered
- Confirm the package exists and is currently owned by your account

Nonce or insufficient funds errors on Sepolia

- Fund your account with test ETH
- Reset the account nonce if needed by clearing activity (advanced)

Hardhat local node issues

- Restart the Hardhat node and redeploy
- If ABI mismatches, rebuild artifacts and restart the dapp


