// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Crowdfunding
 * @dev Timed fundraising campaign.
 * If goal is achieved by the deadline, creator can claim all ETH.
 * If goal fails, contributors can reclaim their exact ETH deposit (one-shot safe).
 */
contract Crowdfunding {
    struct Contribution {
        address contributor;
        uint256 amount;
    }

    address payable public owner;
    uint256 public goal;            // Target amount in wei
    uint256 public deadline;        // Timestamp when campaign ends
    uint256 public raised;          // Total amount raised in wei
    bool public claimed;            // Flag indicating if owner has claimed funds

    mapping(address => uint256) public contributions;

    event Contributed(address indexed contributor, uint256 amount, uint256 totalRaised);
    event FundsClaimed(address indexed owner, uint256 amount);
    event RefundClaimed(address indexed contributor, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }

    /**
     * @dev Initializes campaign with funding goal and duration.
     * @param _goal Fundraising goal in wei.
     * @param _durationSeconds Duration of campaign in seconds.
     */
    constructor(uint256 _goal, uint256 _durationSeconds) {
        require(_goal > 0, "Goal must be greater than zero");
        require(_durationSeconds > 0, "Duration must be greater than zero");

        owner = payable(msg.sender);
        goal = _goal;
        deadline = block.timestamp + _durationSeconds;
    }

    /**
     * @dev Allows contributors to pledge ETH while campaign is active.
     */
    function contribute() external payable {
        require(block.timestamp < deadline, "Campaign deadline has passed");
        require(msg.value > 0, "Contribution amount must be greater than zero");

        contributions[msg.sender] += msg.value;
        raised += msg.value;

        emit Contributed(msg.sender, msg.value, raised);
    }

    /**
     * @dev Returns remaining time in seconds until campaign deadline.
     * @return Seconds remaining (0 if expired).
     */
    function getRemainingTime() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        }
        return deadline - block.timestamp;
    }

    /**
     * @dev Allows owner to withdraw collected funds after deadline if goal was met.
     */
    function claimFunds() external onlyOwner {
        require(block.timestamp >= deadline, "Campaign deadline not yet reached");
        require(raised >= goal, "Funding goal was not met");
        require(!claimed, "Funds have already been claimed");

        claimed = true;
        uint256 balance = address(this).balance;

        (bool sent, ) = owner.call{value: balance}("");
        require(sent, "Claim transfer failed");

        emit FundsClaimed(owner, balance);
    }

    /**
     * @dev Enables contributors to pull refund if campaign failed to reach goal by deadline.
     * Uses Checks-Effects-Interactions pattern for re-entrancy safety.
     */
    function refund() external {
        require(block.timestamp >= deadline, "Campaign deadline not yet reached");
        require(raised < goal, "Goal was reached, no refunds allowed");

        uint256 amount = contributions[msg.sender];
        require(amount > 0, "No contributions to refund or already refunded");

        // Set contribution to 0 before sending ETH
        contributions[msg.sender] = 0;

        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "Refund transfer failed");

        emit RefundClaimed(msg.sender, amount);
    }
}
