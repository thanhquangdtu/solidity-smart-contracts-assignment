// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title EnglishAuction
 * @dev Timed English auction incorporating the secure pull-payment (withdrawal) pattern.
 * Instead of pushing funds to outbid parties during the bid transaction (which introduces
 * re-entrancy risks and denial-of-service vulnerabilities), losing bidders independently pull
 * their refunds via `withdrawPending()`.
 */
contract EnglishAuction {
    address payable public seller;
    uint256 public auctionEnd;
    address public highestBidder;
    uint256 public highestBid;

    // Minimum percentage increase required for new bids (5%)
    uint256 public constant MIN_INCREMENT = 5;

    // Pending refundable balances for outbid bidders (Pull-Payment pattern)
    mapping(address => uint256) public pendingReturns;

    // Status flag
    bool public ended;

    event NewBid(address indexed bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);
    event Withdrawal(address indexed bidder, uint256 amount);

    /**
     * @dev Initializes auction with duration and starting price.
     * @param _biddingSeconds Duration of auction in seconds.
     * @param _startPrice Minimum starting bid in wei.
     */
    constructor(uint256 _biddingSeconds, uint256 _startPrice) {
        require(_biddingSeconds > 0, "Auction duration must be > 0");
        seller = payable(msg.sender);
        auctionEnd = block.timestamp + _biddingSeconds;
        highestBid = _startPrice;
    }

    /**
     * @dev Places a higher bid on the auction.
     * Calculates minimum required bid with 5% increment.
     * Credits prior highest bidder's funds to pendingReturns (pull-payment).
     */
    function bid() external payable {
        require(!ended, "Auction has already ended");
        require(block.timestamp < auctionEnd, "Auction bidding window has closed");

        if (highestBidder == address(0)) {
            // First bid must meet or exceed startPrice
            require(msg.value >= highestBid, "Bid below starting price");
        } else {
            // Enforce minimum 5% increment over current highest bid
            uint256 minRequiredBid = highestBid + ((highestBid * MIN_INCREMENT) / 100);
            require(msg.value >= minRequiredBid, "Bid increment too low (min 5% required)");

            // Credit previous highest bidder for withdrawal
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        emit NewBid(msg.sender, msg.value);
    }

    /**
     * @dev Pull-payment withdrawal function for outbid bidders to claim their refunds.
     * Applies Checks-Effects-Interactions to prevent re-entrancy.
     * @return True if refund transfer succeeds.
     */
    function withdrawPending() external returns (bool) {
        uint256 amount = pendingReturns[msg.sender];
        require(amount > 0, "No pending returns to withdraw");

        // Zero balance before external transfer (Effects)
        pendingReturns[msg.sender] = 0;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            // Revert state if transfer fails
            pendingReturns[msg.sender] = amount;
            return false;
        }

        emit Withdrawal(msg.sender, amount);
        return true;
    }

    /**
     * @dev Concludes the auction after time expiry and transfers highest bid to seller.
     * Anyone can trigger this once auctionEnd is reached.
     */
    function endAuction() external {
        require(!ended, "Auction has already ended");
        require(block.timestamp >= auctionEnd, "Auction has not yet reached its deadline");

        ended = true;

        if (highestBidder != address(0)) {
            (bool success, ) = seller.call{value: highestBid}("");
            require(success, "Payout to seller failed");
            emit AuctionEnded(highestBidder, highestBid);
        } else {
            emit AuctionEnded(address(0), 0);
        }
    }

    /**
     * @dev Returns remaining seconds before auction closes.
     */
    function getRemainingTime() external view returns (uint256) {
        if (block.timestamp >= auctionEnd) {
            return 0;
        }
        return auctionEnd - block.timestamp;
    }
}
