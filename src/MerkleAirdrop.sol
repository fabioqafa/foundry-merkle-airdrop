// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {IMerkleAirdrop} from "./interfaces/IMerkleAirdrop.sol";
import {Merkle} from "../lib/murky/src/Merkle.sol";

contract MerkleAirdrop is IMerkleAirdrop, Merkle, EIP712 {
    ////////////
    // Errors //
    ///////////
    //error MerkleAirdrop__InvalidProof();
    //error MerkleAirdrop__InvalidSignature();
    //error MerkleAirdrop__AlreadyClaimed();

    ////////////
    // Types  //
    ///////////
    using SafeERC20 for IERC20;

    ////////////
    // Structs  //
    ///////////
    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    struct MerkleProofData {
        uint256 amount;
        bytes32 leaf;
        bytes32[] proof;
    }

    ////////////
    // Events //
    ///////////
    //event Claim(address indexed account, uint256 indexed amount);

    ///////////////
    // Variables //
    //////////////
    uint256 private constant AIRDROP_AMOUNT_PER_USER = 25 ether;
    bytes32 private immutable i_merkleRoot;
    bytes32[] leafs;
    mapping(address claimer => MerkleProofData merkleTree)
        private s_claimerMerkle;
    mapping(address claimer => bool claimed) private s_hasClaimed;
    bytes32 public constant MESSAGE_TYPEHASH =
        keccak256("AirdropClaim(address account, uint256 amount)");
    IERC20 private immutable i_airdropToken;

    ///////////////
    // Functions //
    //////////////
    constructor(
        address airdropToken,
        address[] memory claimers
    ) EIP712("Airdrop", "1") {
        i_airdropToken = IERC20(airdropToken);

        for (uint i = 0; i < claimers.length; i++) {
            bytes32 leaf = _createLeaf(claimers[i], AIRDROP_AMOUNT_PER_USER);
            leafs.push(leaf);
        }

        for (uint i = 0; i < claimers.length; i++) {
            bytes32[] memory proof = getProof(leafs, i);
            _addClaimer(claimers[i], AIRDROP_AMOUNT_PER_USER, leafs[i], proof);
        }

        i_merkleRoot = getRoot(leafs);
    }

    /**
     * @notice Allows a user to claim airdrop tokens on behalf of `account` if they are eligible.
     * @dev This function uses a Merkle Proof to verify eligibility and ensure tokens cannot be claimed twice by `account`.
     *      Additionally, it requires a valid signature to authorize the claim.
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
    ) external {
        // Check if the account has already claimed the airdrop
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed(); // Revert if the account has already claimed
        }

        // Check if the account we want to claim on behalf of has signed the message
        if (
            !_isValidSignature(
                account,
                getMessageHash(account, amount),
                v,
                r,
                s
            )
        ) {
            revert MerkleAirdrop__InvalidSignature();
        }

        // Compute the leaf node from the account and amount
        bytes32 leaf = s_claimerMerkle[account].leaf;

        // Verify the provided Merkle Proof against the stored Merkle Root
        // Here we verify if the `account` is in the claimers list or not
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof(); // Revert if the proof is invalid
        }

        // Mark the account as having claimed the airdrop
        s_hasClaimed[account] = true;

        // Emit an event for the claim
        emit Claim(account, amount);

        // Transfer the airdrop tokens to the account
        i_airdropToken.safeTransfer(account, amount);
    }

    function _isValidSignature(
        address signer,
        bytes32 digest,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (bool) {
        (address actualSigner, , ) = ECDSA.tryRecover(digest, v, r, s);
        return (actualSigner == signer);
    }

    function _addClaimer(
        address claimer,
        uint256 amount,
        bytes32 leaf,
        bytes32[] memory proof
    ) private {
        // Check if the claimer has already been added
        if (s_claimerMerkle[claimer].amount != 0) {
            revert MerkleAirdrop__ClaimerAlreadyAdded(claimer);
        }

        // If the claimer has not been added, add them
        s_claimerMerkle[claimer] = MerkleProofData({
            amount: amount,
            leaf: leaf,
            proof: proof
        });
    }

    function _createLeaf(
        address claimer,
        uint256 amount
    ) private pure returns (bytes32) {
        return
            keccak256(
                bytes.concat(keccak256(abi.encodePacked(claimer, amount)))
            );
    }

    function getMerkleRoot() public view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() public view returns (IERC20) {
        return i_airdropToken;
    }

    function getUserClaimStatus(address account) public view returns (bool) {
        return s_hasClaimed[account];
    }

    function getMessageHash(
        address account,
        uint256 amount
    ) public view returns (bytes32) {
        return
            _hashTypedDataV4(
                keccak256(
                    abi.encode(
                        MESSAGE_TYPEHASH,
                        AirdropClaim({account: account, amount: amount})
                    )
                )
            );
    }

    function getClaimerMerkleTree(
        address account
    ) public view returns (MerkleProofData memory) {
        return s_claimerMerkle[account];
    }

    function getClaimingAmount() public pure returns (uint256) {
        return AIRDROP_AMOUNT_PER_USER;
    }
}
