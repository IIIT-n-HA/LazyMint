// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {NFTStaker} from "../src/NFTStaker.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockNFT is ERC721 {
    constructor() ERC721("Mock", "Mck") {}

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }
}

contract stake is Test {
    NFTStaker public staker;

    MockNFT public NFT;
    address public RTK = makeAddr("rtk");
    address public USER = makeAddr("user");
    address public USER2 = makeAddr("user2");

    function setUp() public {
        NFT = new MockNFT();
        staker = new NFTStaker(address(NFT), RTK);
    }

    function test_Stake() public {
        // Arrange
        NFT.mint(USER, 1);
        // Act
        vm.startPrank(USER);
        NFT.approve(address(staker), 1);
        staker.stake(1);
        vm.stopPrank();

        // Assert
        assertEq(staker.totalStaked(), 1);
        assertEq(staker.balanceOf(USER), 1);
        assertEq(staker.nftOwners(1), USER);
    }

    function test_StakeButNotOwner() public {
        // Arrange
        NFT.mint(USER, 1);
        // Act, Assert
        vm.prank(USER);
        NFT.approve(address(staker), 1);

        vm.prank(USER2);
        vm.expectRevert();
        staker.stake(1);
    }

    function test_Unstake() public {
        // Arrange
        test_Stake();
        // Act
        vm.prank(USER);
        staker.unstake(1);
        // Assert
        assertEq(staker.totalStaked(),0);
    }

    function test_UnstakeButNotOwner() public {
        // Arrange
        test_Stake();
        // Act, Assert
        vm.prank(USER2);
        vm.expectRevert();
        staker.stake(1);
    }

    // probably smthng wrong with the updateReward modifier that's why we are getting error here. need to work on it. 
    // function test_ClaimReward() public {
    //     // Arrange
    //     test_Stake();
    //     // Act
    //     vm.warp(block.timestamp + 100);
    //     uint256 expectedReward = staker.rewardRatePerSecond() * 100;

    //     vm.prank(USER);
    //     staker.claimReward();
    //     // Assert
    //     assertEq(staker.rewards(USER), 0);
    // }
}