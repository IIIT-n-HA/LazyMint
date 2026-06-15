// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {LazyNFT} from "../src/LazyNFT.sol";
import {lazyDeploy} from "../script/lazyDeploy.s.sol";

contract lazy is Test {
    lazyDeploy public deployer;
    LazyNFT public lazyNFT;

    // --- Wallets ---
    // 1. The backend server's wallet (has a private key we know)
    uint256 backendPrivateKey = 0xA11CE;
    address backendSigner = vm.addr(backendPrivateKey);

    // 2. The user trying to mint
    address user = address(0x123);

    // --- EIP-712 Constants ---
    bytes32 constant DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 constant VOUCHER_TYPEHASH = keccak256("MintVoucher(uint256 tokenId,uint256 minPrice,string uri)");

    function setUp() public {
        deployer = new lazyDeploy();
        lazyNFT = deployer.run();
    }

    function test_VerifyOwner() public {
        // Arrange
        // Act
        // Assert
        assertEq(lazyNFT.owner(), address(this)); // why does it passes with address(this) but not with msg.sender
    }

    function test_SetAuthorizedSigner() public {
        // Arrange
        address newSigner = address(0x99999);
        // Act
        lazyNFT.setAuthorizedSigner(newSigner);
        // Assert
        assertEq(lazyNFT.authorizedSigner(), newSigner);
    }

    function _generateSignature(uint256 tokenId, uint256 minPrice, string memory uri, uint256 privateKey)
        internal
        view
        returns (LazyNFT.MintVoucher memory, bytes memory)
    {
        LazyNFT.MintVoucher memory voucher = LazyNFT.MintVoucher(tokenId, minPrice, uri);

        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes("LazyNFT-Domain")),
                keccak256(bytes("1")),
                block.chainid,
                address(lazyNFT)
            )
        );

        bytes32 structHash = keccak256(
            abi.encode(VOUCHER_TYPEHASH, voucher.tokenId, voucher.minPrice, keccak256(abi.encode(voucher.uri)))
        );

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        return (voucher, abi.encodePacked(r, s, v));
    }

    // function test_Redeem() public {
    //     // Arrange
    //     (LazyNFT.MintVoucher memory voucher, bytes memory signature) =
    //         _generateSignature(1, 0, "ipfs://metadata/1.json", backendPrivateKey);

    //     // Act
    //     vm.prank(user);
    //     lazyNFT.redeem(user, voucher, signature);
    //     // Assert
    //     vm.assertEq(lazyNFT.ownerOf(1), user);
    //     vm.assertEq(lazyNFT.tokenURI(1), "ipfs://metadata/1.json");
    //     vm.assertTrue(lazyNFT.usedVouchers(1));
    // }
}
