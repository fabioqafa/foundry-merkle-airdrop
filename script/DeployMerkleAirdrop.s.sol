// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 private s_merkleRoot =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 private s_amountToMint = 4 * 25e18;
    address[] claimers = [
        0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D, //forge default first address (makeAddr)
        0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266, //anvil first address
        0x70997970C51812dc3A010C7d01b50e0d17dc79C8, //anvil second address
        0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC //anvil third address
    ];

    function run() external returns (BagelToken, MerkleAirdrop) {
        vm.startBroadcast();
        BagelToken token = new BagelToken();
        MerkleAirdrop airdrop = new MerkleAirdrop(address(token), claimers);
        token.mint(address(airdrop), s_amountToMint);
        vm.stopBroadcast();

        return (token, airdrop);
    }
}
