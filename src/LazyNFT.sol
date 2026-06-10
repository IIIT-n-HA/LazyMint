// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions


// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.24;

import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract LazyNFT is ERC721URIStorage, EIP712, Ownable{

    using ECDSA for bytes32;

    // authorized wallet address that creates off-chain signatures
    address public authorizedSigner;

    // struct matching the exact format of off chain signed data
    struct MintVoucher {
        uint256 tokenID;
        uint256 minPrice;
        string uri;
    }

    // EIP712 TypeHash for MintVoucher struct
    // keccak256("MintVoucher(uint256 tokenID, uint256 minPrice, string uri)")
    bytes32 public constant VOUCHER_TYPEHASH = 0xbfbc9c3b0ebfde7b278bf1335b719cb49edb51820dd822c9c22ebf8fc0e2a392;

    // Replay attack prevention: keep a track of already minted token id 
    mapping(uint256 => bool) public usedVouchers;

    constructor(address initialOwner, address _authorizedSigner) ERC721("LazyNFT", "LNFT") EIP712("LazyNFT-Domain", "1") Ownable(initialOwner) {
        authorizedSigner = _authorizedSigner;
    }

    /// @notice Updates the authorized signer address
    function setAuthorizedSigner(address signer) external onlyOwner {
        authorizedSigner = signer;
    }
}
