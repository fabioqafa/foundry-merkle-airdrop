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
    bytes32 public ROOT =
        0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public AMOUNT_TO_CLAIM = 25e18;
    uint256 public AMOUNT_TO_MINT = AMOUNT_TO_CLAIM * 4;
    bytes32[] public PROOF = [
        bytes32(
            0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a
        ),
        bytes32(
            0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576
        )
    ];

    function setUp() public {
        DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
        (token, airdrop) = deployer.run();
        (user, userPrivKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testUserCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);
        vm.startPrank(user);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);
        vm.stopPrank();

        vm.startPrank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);
        vm.stopPrank();

        uint256 endingBalance = token.balanceOf(user);
        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }
}
