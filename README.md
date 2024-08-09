# Airdrop Smart Contract using Advanced Ethereum Cryptography Techniques

## This is a demo

## Use of Merkle Trees, EIP712 Signature Standard and ECDSA (Ethereum Ellptic Curve Digital Signature Algorithm)

### The user can sign a message, and another address can take care of the airdrop, thus the gas is spent by the latter

### However, if the user is not listed (proven by merkle tree) or has not signed the message, he can't have airdrop tokens

To interact with the smart contract using scripts, use the foundry cli.
Step-by-step how bytes SIGNATURE variable was generated:
1. To deploy the smart contracts, use `make build` | `make deploy`. Find the script in the makefile
2. Then, call the MerkleAirdrop smart contract with: `cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "getMessageHash(address, uint256)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 25000000000000000000 --rpc-url http://localhost:8545` where:
    where:
- `0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512` : MerkleAirdrop contract address
- `getMessageHash(address, uint256)` : Function selector
- `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266`, `25000000000000000000` : Address to claim the tokens and the amount respectively (note it is a leaf in the merkle tree. path: `script/target/output.json`)
- `http://localhost:8545` : Local Anvil Blockchain RPC


   getMessageHash will return a MESSAGE_TYPEHASH. In this case it is: `0x73ba59483ace458ddf45c137b57724869a2ce55bf9a5671af28b2c1cb2c8b3de`
3. Then sign the message using `cast wallet sign` CLI. In this example it is: `cast wallet sign --no-hash 0x73ba59483ace458ddf45c137b57724869a2ce55bf9a5671af28b2c1cb2c8b3de --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80` where: 
- `0x73ba59483ace458ddf45c137b57724869a2ce55bf9a5671af28b2c1cb2c8b3de` : MESSAGE_TYPEHASH returned by getMessage method
-   `0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80` : private key of the gas payer (!!!!NOTE: Never use this private key, since this is a local network and this private key is provided by anvil, it is not a big deal to use it. However, if you want to deploy on testnet or mainnet use the keystore. For more information see here: https://book.getfoundry.sh/reference/cast/cast-wallet-import)
4. Get the balance of the tokens using cast call `cast call 0x5fbdb2315678afecb367f032d93f642f64180aa3 "balanceOf(address)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266` | `cast --to-dec <returned hex>`, which will be equal to 25000000000000000000.
- `0x5fbdb2315678afecb367f032d93f642f64180aa3` : address of the Bagel Token contract
-  `0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266` : address of the claimer