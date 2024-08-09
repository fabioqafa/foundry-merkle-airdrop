// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test {
    MerkleAirdrop public airdrop;
    BagelToken public token;

    address gasPayer;
    address user;
    uint256 userPrivKey;

    // ROOT is taken from output.json file
    bytes32 public ROOT;
    uint256 public AMOUNT_TO_CLAIM;
    uint256 public AMOUNT_TO_MINT;

    function setUp() public {
        DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
        (token, airdrop) = deployer.run();
        (user, userPrivKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
        ROOT = airdrop.getMerkleRoot();
        AMOUNT_TO_CLAIM = airdrop.getClaimingAmount();
        AMOUNT_TO_MINT = AMOUNT_TO_CLAIM * 4;
    }

    function testUserCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);
        vm.startPrank(user);
        bytes32[] memory proof = airdrop.getClaimerMerkleTree(user).proof;

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);
        vm.stopPrank();
        vm.startPrank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, proof, v, r, s);
        vm.stopPrank();

        uint256 endingBalance = token.balanceOf(user);
        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }
}
