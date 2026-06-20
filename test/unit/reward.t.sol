// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {RewardToken} from "../../src/RewardToken.sol";

contract reward is Test {

    RewardToken public rt;
    address public STAKER = makeAddr("staker");
    address public OWNER = makeAddr("owner");
    uint256 rewardAmount = 1 ether;
    address public RECEIVER = makeAddr("receiver");

    event StakingContractAuthorized(address indexed stakingContract);

    function setUp() public {
        rt = new RewardToken(OWNER);
    }

    function test_RightOwner() public view {
        // Arrange, Act, Assert
        assertEq(rt.owner(), OWNER);
        assertEq(rt.stakingContract(), address(this));
    }

    function test_SetStakingContract() public {
        // Arrange, Act
        // vm.expectEmit(true, false, false, false);
        // emit StakingContractAuthorized(STAKER); ----> need to working on testing events getting emitted
        rt.setStakingContract(STAKER);
        // Assert
        assertEq(rt.stakingContract(), STAKER);
        // assertEq(rt.StakingContractAuthorized.selector, STAKER);
    }

    function test_Mint() public {
        // Arrange, Act
        rt.mint(RECEIVER, rewardAmount);
        // Assert 
        assertEq(rt.balanceOf(RECEIVER), rewardAmount);
    }

    function test_Modifier() public view {
        // Arrange
        // Act
        // Assert
        assertEq(rt.stakingContract(),address(this));
    }
}
