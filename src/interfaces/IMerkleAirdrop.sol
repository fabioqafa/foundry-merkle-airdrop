// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IMerkleAirdrop {
    ////////////
    // Events //
    ////////////
    event Claim(address indexed account, uint256 indexed amount);

    ////////////
    // Errors //
    ////////////
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__InvalidSignature();
    error MerkleAirdrop__AlreadyClaimed();

    ///////////////
    // Functions //
    ///////////////

    /**
     * @notice Allows a user to claim airdrop tokens on behalf of `account` if they are eligible.
     * @param account The address of the account claiming the airdrop.
     * @param amount The amount of tokens to be claimed.
     * @param merkleProof The Merkle Proof used to verify the account's eligibility.
     * @param v The recovery byte of the signature.
     * @param r Half of the ECDSA signature pair.
     * @param s Half of the ECDSA signature pair.
     */
    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @notice Returns the Merkle root associated with the airdrop.
     * @return The Merkle root as a bytes32 value.
     */
    function getMerkleRoot() external view returns (bytes32);

    /**
     * @notice Returns the ERC20 token used for the airdrop.
     * @return The address of the ERC20 token as an IERC20 interface.
     */
    function getAirdropToken() external view returns (IERC20);

    /**
     * @notice Checks whether a given account has already claimed the airdrop.
     * @param account The address of the account to check.
     * @return A boolean value indicating whether the account has claimed.
     */
    function getUserClaimStatus(address account) external view returns (bool);

    /**
     * @notice Generates the message hash for a given account and amount.
     * @param account The address of the account.
     * @param amount The amount of tokens to be claimed.
     * @return The hash of the message as a bytes32 value.
     */
    function getMessageHash(
        address account,
        uint256 amount
    ) external view returns (bytes32);
}
