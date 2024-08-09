# Airdrop Smart Contract using Advanced Ethereum Cryptography Techniques with On-Chain Merkle Trees

## This is a demo

## Use of Merkle Trees, EIP712 Signature Standard and ECDSA (Ethereum Ellptic Curve Digital Signature Algorithm)

### The user can sign a message, and another address can take care of the airdrop, thus the gas is spent by the latter

### However, if the user is not listed (proven by merkle tree) or has not signed the message, he can't have airdrop tokens

To deploy the smart contracts, use `make build` | `make deploy`. Find the script in the makefile