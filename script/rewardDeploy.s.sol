// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {RewardToken} from "../src/RewardToken.sol";

contract rewardDeploy is Script {

    RewardToken public rt;

    function run() external returns(RewardToken) {
        vm.startBroadcast();
        rt = new RewardToken(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266); // intialOwner: first account of anvil
        vm.stopBroadcast();

        return rt;
    }
}