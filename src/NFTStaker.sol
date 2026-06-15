// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {LazyNFT} from "./LazyNFT.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// minimal interface to interact with our RewardToken's custom mint function
interface IRewardToken {
    function mint(address to, uint256 amount) external;
}

contract NFTStaker is IERC721Receiver, ReentrancyGuard {

    IERC721 public immutable nftCollection;
    IRewardToken public immutable rewardToken;

    // Global states
    uint256 public rewardRatePerSecond = 100000000000000; // 0.0001 whole tokens
    uint256 public totalStaked;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;

    // User states
    mapping(uint256 => address) public nftOwners;
    mapping(address => uint256) public balanceOf;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    constructor(address _nftCollection, address _rewardToken) {
        nftCollection = IERC721(_nftCollection);
        rewardToken = IRewardToken(_rewardToken);
    }
}