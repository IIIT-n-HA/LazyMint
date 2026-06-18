// as name suggests -> alpha: so here will test all three contracts in together

// SPDX-License-Identifier:MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {LazyNFT} from "../../src/LazyNFT.sol";
import {NFTStaker} from "../../src/NFTStaker.sol";
import {RewardToken} from "../../src/RewardToken.sol";

contract alpha is Test {
    LazyNFT public lazy;
    NFTStaker public staker;
    RewardToken public rtk;

    // Wallets
    address public OWNER = address(this);
    address public USER = makeAddr("user");
    uint256 public backendPrvKey = 0xA11CE;
    address public SIGNER = vm.addr(backendPrvKey);

    // EIP-712 Schema
    bytes32 constant DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 constant VOUCHER_TYPEHASH = keccak256("MintVoucher(uint256 tokenId,uint256 minPrice,string uri)");

    function setUp() public {
        lazy = new LazyNFT(OWNER, SIGNER);
        rtk = new RewardToken(OWNER);
        staker = new NFTStaker(address(lazy), address(rtk));

        rtk.setStakingContract(address(staker));

        vm.deal(USER, 100 ether);
    }

    // Backend Signature Generator
    function _generateSignature(uint256 tokenId, uint256 minPrice, string memory uri, uint256 privateKey)
        internal
        view
        returns (LazyNFT.MintVoucher memory, bytes memory)
    {
        LazyNFT.MintVoucher memory voucher = LazyNFT.MintVoucher({tokenId: tokenId, minPrice: minPrice, uri: uri});
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH, keccak256(bytes("LazyNFT-Domain")), keccak256(bytes("1")), block.chainid, address(lazy)
            )
        );
        bytes32 structHash =
            keccak256(abi.encode(VOUCHER_TYPEHASH, voucher.tokenId, voucher.minPrice, keccak256(bytes(voucher.uri))));
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(backendPrvKey, digest);
        return (voucher, abi.encodePacked(r, s, v));
    }

    function test_AL_DENTE() public {
        // Arrange
        // Act
        // Assert
        console.log("--- PHASE:1 LAZY MINTING ----");

        // Backend generates signature for a free NFT (ID #1)
        (LazyNFT.MintVoucher memory voucher, bytes memory signature) =
            _generateSignature(1, 0, "ipfs://alpha.json", backendPrvKey);

        vm.startPrank(USER);
        lazy.redeem(USER, voucher, signature);

        vm.assertEq(lazy.ownerOf(1), USER);
        vm.assertEq(lazy.tokenURI(1), "ipfs://alpha.json");
        vm.assertTrue(lazy.usedVouchers(1));
        console.log("Success: User lazy-minted NFT #1");

        // Arrange
        // Act
        // Assert
        console.log("--- PHASE 2: STAKING ---");

        lazy.approve(address(staker), 1);
        staker.stake(1);

        assertEq(staker.totalStaked(), 1);
        assertEq(staker.balanceOf(USER), 1);
        assertEq(staker.nftOwners(1), USER);
        console.log("Success: User vaulted NFT #1");

        // Arrange
        // Act
        // Assert
        console.log("--- PHASE 3: TIME TRAVEL & YIELD ---");
        // moving ahead to like 30 days
        uint256 extraTime = 30 * 24 * 60 * 60;
        vm.warp(block.timestamp + extraTime);
        console.log("Success: Fast-forwarded EVM clock by 30 days");

        // Arrange
        // Act
        // Assert
        console.log("--- PHASE 4: UNSTAKING & CLAIMING ---");
        staker.unstake(1);
        staker.claimReward();
        vm.stopPrank();

        uint256 expectedReward = staker.rewardRatePerSecond() * extraTime;

        assertEq(staker.totalStaked(), 0);
        assertEq(rtk.balanceOf(USER), expectedReward);
        assertEq(staker.balanceOf(USER), 0);

        console.log("Success: User retrieved NFT #1 from the vault");
        console.log("Success: User claimed perfect mathematical yield");
        console.log("Total tokens minted (in wei):", rtk.balanceOf(USER));
    }
}
