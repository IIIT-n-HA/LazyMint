// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract RewardToken is ERC20, Ownable {
    // exact address of NFT staking contract authorized to print tokens
    address public stakingContract;

    // events
    event StakingContractAuthorized(address indexed stakingContract);
    event RewardTokenMinted(address indexed to, uint256 amount);

    /**
     * @dev throws if called by any account other than the authorized one
     */
    modifier onlyStakingContract() {
        require(msg.sender == stakingContract, "Caller is not the staking contract");
        _;
    }

    /**
     * @notice Constructor sets token identity parameters and initial owner.
     * @param initialOwner The address that deploys the contract and configures architectures.
     */
    constructor(address initialOwner) ERC20("RewardToken", "RT") Ownable(initialOwner) {}

    /**
     * @notice Links the NFT Staking contract to this asset.
     * @dev Can only be called once by the contract owner to prevent hijacking.
     * @param _stakingContract The deployed address of the NFTStaker contract.
     */
    function setStakingContract(address _stakingContract) public onlyStakingContract {
        require(_stakingContract != address(0), "Invalid address");
        require(stakingContract == address(0), "Contract already authorized");

        stakingContract = _stakingContract;

        emit StakingContractAuthorized(_stakingContract);
    }

    /**
     * @notice Mints new reward tokens for users claiming yield.
     * @dev Restricted entirely to the math engines running inside the authorized staking contract.
     * @param to The address of the staker receiving their yield.
     * @param amount The precise amount of tokens to generate (scaled to 18 decimals).
     */
    function mint(address to, uint256 amount) public onlyStakingContract {
        _mint(to, amount);
        emit RewardTokenMinted(to, amount);
    }
}
