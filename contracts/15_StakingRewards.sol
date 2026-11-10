// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title StakingRewards
 * @dev Continuous yield staking contract inspired by DeFi protocols (Curve/Lido).
 * Users stake ETH and accrue rewards proportionally per second.
 * Implements strict Checks-Effects-Interactions, one-shot safe unstaking, and reward pool guarantees.
 */
contract StakingRewards {
    address payable public owner;

    // Reward rate per whole 1 ETH staked per second (in wei)
    uint256 public rewardRatePerSecond;

    // Total ETH currently staked by all users
    uint256 public totalStaked;

    // Dedicated reward pool funded by owner
    uint256 public rewardPool;

    struct Stake {
        uint256 amount;       // Amount of ETH staked in wei
        uint256 startTime;    // Timestamp of last stake or claim action
        uint256 rewardDebt;   // Accumulated rewards accrued prior to last stake adjustment
    }

    mapping(address => Stake) public stakes;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 principal, uint256 reward);
    event RewardClaimed(address indexed user, uint256 reward);
    event RewardPoolFunded(address indexed funder, uint256 amount);
    event RewardRateUpdated(uint256 oldRate, uint256 newRate);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can execute");
        _;
    }

    /**
     * @dev Seeds the reward pool with initial ETH deposit and sets reward emission rate.
     * @param _rate Wei of reward accrued per staked ETH per second (e.g. 1000 wei/s).
     */
    constructor(uint256 _rate) payable {
        owner = payable(msg.sender);
        rewardRatePerSecond = _rate;
        rewardPool = msg.value;

        if (msg.value > 0) {
            emit RewardPoolFunded(msg.sender, msg.value);
        }
    }

    /**
     * @dev Calculates pending reward accrued for a specific user.
     * Formula: rewardDebt + (amount * rewardRatePerSecond * elapsedSeconds) / 1 ether
     * @param user Address to calculate rewards for.
     * @return Accumulated pending reward in wei.
     */
    function pendingReward(address user) public view returns (uint256) {
        Stake storage userStake = stakes[user];
        if (userStake.amount == 0) {
            return userStake.rewardDebt;
        }

        uint256 elapsed = block.timestamp - userStake.startTime;
        uint256 accrued = (userStake.amount * rewardRatePerSecond * elapsed) / 1 ether;
        return userStake.rewardDebt + accrued;
    }

    /**
     * @dev Stakes ETH into the pool.
     * Accumulates any pending reward into rewardDebt before updating the principal amount.
     */
    function stake() external payable {
        require(msg.value > 0, "Staked amount must be greater than zero");

        Stake storage userStake = stakes[msg.sender];

        // Snapshot accrued rewards into rewardDebt before increasing stake
        if (userStake.amount > 0) {
            userStake.rewardDebt = pendingReward(msg.sender);
        }

        userStake.amount += msg.value;
        userStake.startTime = block.timestamp;
        totalStaked += msg.value;

        emit Staked(msg.sender, msg.value);
    }

    /**
     * @dev Claims only accrued rewards without unstaking principal.
     */
    function claimReward() external {
        uint256 reward = pendingReward(msg.sender);
        require(reward > 0, "No pending reward to claim");
        require(rewardPool >= reward, "Insufficient reward pool funds");

        Stake storage userStake = stakes[msg.sender];

        // Effects: reset reward state
        rewardPool -= reward;
        userStake.rewardDebt = 0;
        userStake.startTime = block.timestamp;

        // Interactions: send reward to caller
        (bool success, ) = payable(msg.sender).call{value: reward}("");
        require(success, "Reward transfer failed");

        emit RewardClaimed(msg.sender, reward);
    }

    /**
     * @dev Unstakes all principal and claims all accrued rewards in one atomic transaction.
     * Clears stake record to prevent re-entrant or repeated withdrawals.
     */
    function unstake() external {
        Stake memory userStake = stakes[msg.sender];
        require(userStake.amount > 0, "No staked balance to unstake");

        uint256 reward = pendingReward(msg.sender);
        require(rewardPool >= reward, "Insufficient reward pool funds");

        uint256 principal = userStake.amount;
        uint256 totalPayout = principal + reward;

        // Effects: clear stake record and adjust pools
        rewardPool -= reward;
        totalStaked -= principal;
        delete stakes[msg.sender];

        // Interactions: send principal + reward
        (bool success, ) = payable(msg.sender).call{value: totalPayout}("");
        require(success, "Unstake payout failed");

        emit Unstaked(msg.sender, principal, reward);
    }

    /**
     * @dev Allows owner to deposit additional ETH to top up the reward pool.
     */
    function fundRewards() external payable onlyOwner {
        require(msg.value > 0, "Must send ETH to fund rewards");
        rewardPool += msg.value;
        emit RewardPoolFunded(msg.sender, msg.value);
    }

    /**
     * @dev Allows owner to adjust the per-second reward emission rate.
     * @param _newRate New rate in wei per second per ETH.
     */
    function setRewardRate(uint256 _newRate) external onlyOwner {
        emit RewardRateUpdated(rewardRatePerSecond, _newRate);
        rewardRatePerSecond = _newRate;
    }

    /**
     * @dev Returns total contract balance (stakes + reward pool).
     */
    function contractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
