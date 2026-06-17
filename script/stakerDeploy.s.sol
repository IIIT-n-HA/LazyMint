// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {NFTStaker} from "../src/NFTStaker.sol";

contract stakerDeploy is Script {

    NFTStaker public staker;
    address public  nftCollection;
    address public rewardToken;

    function run() external returns (NFTStaker) {
        vm.startBroadcast();
        staker = new NFTStaker(nftCollection, rewardToken);
        vm.stopBroadcast();

        return staker;
    }
}
