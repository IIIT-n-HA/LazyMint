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
    mapping(uint256 => address) public nftOwners; // Maps token id to original owner
    mapping(address => uint256) public balanceOf; // How many NFTs a user has staked
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    // Events
    event Staked(address indexed user, uint256 indexed tokenId);
    event Unstaked(address indexed user, uint256 indexed tokenId);
    event RewardPaid(address indexed user, uint256 amount);

    /**
     * @notice sets the immutable addresses of two asset contracts
     */
    constructor(address _nftCollection, address _rewardToken) {
        nftCollection = IERC721(_nftCollection);
        rewardToken = IRewardToken(_rewardToken);
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;

        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) return rewardPerTokenStored;

        // calculating accumulated rewards utilizing 1e18 for precision maths
        return rewardRatePerSecond + (((block.timestamp - lastUpdateTime) * rewardRatePerSecond * 1e18) / totalStaked);
    }

    function earned(address account) public view returns (uint256) {
        return ((balanceOf[account] * (rewardPerToken() - userRewardPerTokenPaid[account])) / 1e18) + rewards[account];
    }

    function stake(uint256 tokenId) external nonReentrant updateReward(msg.sender) {
        require(nftCollection.ownerOf(tokenId) == msg.sender, "You do not own this token");

        // Update states
        totalStaked += 1;
        balanceOf[msg.sender] += 1;
        nftOwners[tokenId] = msg.sender;

        // transfer of asset
        nftCollection.safeTransferFrom(msg.sender, address(this), tokenId);

        emit Staked(msg.sender, tokenId);
    }

    function unstake(uint256 tokenId) external nonReentrant updateReward(msg.sender) {
        require(nftCollection.ownerOf(tokenId) == msg.sender, "You do not own this token");

        // Update states
        totalStaked -= 1;
        balanceOf[msg.sender] -= 1;
        delete nftOwners[tokenId];

        // transfer asset
        nftCollection.safeTransferFrom(address(this), msg.sender, tokenId);

        emit Unstaked(msg.sender, tokenId);
    }
}
