// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {LazyNFT} from "../src/LazyNFT.sol";

contract lazyDeploy is Script {
    LazyNFT lazyNFT;

    function run() external returns (LazyNFT) {
        vm.startBroadcast();
        lazyNFT = new LazyNFT(msg.sender, 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
        vm.stopBroadcast();
        return lazyNFT;
    }
}
