// // SPDX-License-Identifier: MIT

// pragma solidity ^0.8.24;

// import {Test, console} from "forge-std/Test.sol";
// import {lazyDeploy} from "../script/lazyDeploy.s.sol";
// import {rewardDeploy} from "../script/rewardDeploy.s.sol";
// import {stakerDeploy} from "../script/stakerDeploy.s.sol";
// import {LazyNFT} from "../src/LazyNFT.sol";
// import {NFTStaker} from "../src/NFTStaker.sol";
// import {RewardToken} from "../src/RewardToken.sol";
// import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

// contract scriptTest is Test {

//     lazyDeploy public lazy;
//     rewardDeploy public reward;
//     stakerDeploy public staker;
//     address public expectedAddress;
//     LazyNFT public lazyContract;

//     function setUp() public {
//         lazy = new lazyDeploy();
//         reward = new rewardDeploy();
//         staker = new stakerDeploy();

//         lazyContract = lazy.run();
//         expectedAddress = DevOpsTools.get_most_recent_deployment("LazyNFT", 31337);
//     }

//     // getting errors need to work on it

//     function test_lazyScript() public {
//         // Arrange
//         // Act
//         // LazyNFT lazyContract = lazy.run();
//         // address expectedAddress = DevOpsTools.get_most_recent_deployment(lazyContract, 31337);
//         // Assert
//         assertEq(address(lazyContract), expectedAddress);
//     }
// }