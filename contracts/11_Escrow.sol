// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Escrow
 * @dev Three-party trustless escrow contract involving Buyer, Seller, and Arbiter.
 * Securely enforces transactional state transitions and arbiter dispute resolution.
 */
contract Escrow {
    enum State {
        AwaitingPayment,
        AwaitingDelivery,
        Complete,
        Refunded,
        Disputed
    }

    address payable public buyer;
    address payable public seller;
    address payable public arbiter;
    State public state;
    uint256 public amount;

    event PaymentDeposited(address indexed buyer, uint256 amount);
    event DeliveryConfirmed(address indexed buyer, address indexed seller, uint256 amount);
    event RefundedToBuyer(address indexed buyer, uint256 amount);
    event DisputeRaised(address indexed raisedBy);
    event DisputeResolvedToSeller(address indexed arbiter, address indexed seller, uint256 amount);
    event DisputeResolvedToBuyer(address indexed arbiter, address indexed buyer, uint256 amount);

    modifier inState(State expectedState) {
        require(state == expectedState, "Invalid state for this action");
        _;
    }

    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer can perform this action");
        _;
    }

    modifier onlyArbiterOrSeller() {
        require(msg.sender == arbiter || msg.sender == seller, "Only arbiter or seller can perform this action");
        _;
    }

    modifier onlyBuyerOrSeller() {
        require(msg.sender == buyer || msg.sender == seller, "Only buyer or seller can perform this action");
        _;
    }

    modifier onlyArbiter() {
        require(msg.sender == arbiter, "Only arbiter can perform this action");
        _;
    }

    /**
     * @dev Sets up escrow parties and deposits initial payment from buyer.
     * @param _seller Recipient address who will deliver service/goods.
     * @param _arbiter Neutral third-party mediator.
     */
    constructor(address payable _seller, address payable _arbiter) payable {
        require(_seller != address(0), "Invalid seller address");
        require(_arbiter != address(0), "Invalid arbiter address");
        require(_seller != msg.sender, "Seller cannot be buyer");
        require(_arbiter != msg.sender && _arbiter != _seller, "Arbiter must be independent");
        require(msg.value > 0, "Deposit must be greater than zero");

        buyer = payable(msg.sender);
        seller = _seller;
        arbiter = _arbiter;
        amount = msg.value;
        state = State.AwaitingDelivery;

        emit PaymentDeposited(msg.sender, msg.value);
    }

    /**
     * @dev Buyer confirms satisfactory delivery; funds are released to seller.
     */
    function confirmDelivery() external onlyBuyer inState(State.AwaitingDelivery) {
        state = State.Complete;
        uint256 payout = address(this).balance;

        (bool success, ) = seller.call{value: payout}("");
        require(success, "Payout to seller failed");

        emit DeliveryConfirmed(buyer, seller, payout);
    }

    /**
     * @dev Seller or arbiter voluntary refunds payment back to buyer.
     */
    function refundBuyer() external onlyArbiterOrSeller inState(State.AwaitingDelivery) {
        state = State.Refunded;
        uint256 refundAmt = address(this).balance;

        (bool success, ) = buyer.call{value: refundAmt}("");
        require(success, "Refund to buyer failed");

        emit RefundedToBuyer(buyer, refundAmt);
    }

    /**
     * @dev Buyer or seller flags transaction as contested, moving it to Disputed state.
     */
    function raiseDispute() external onlyBuyerOrSeller inState(State.AwaitingDelivery) {
        state = State.Disputed;
        emit DisputeRaised(msg.sender);
    }

    /**
     * @dev Arbiter arbitrates in favor of seller; releases vaulted ETH to seller.
     */
    function resolveToSeller() external onlyArbiter inState(State.Disputed) {
        state = State.Complete;
        uint256 payout = address(this).balance;

        (bool success, ) = seller.call{value: payout}("");
        require(success, "Dispute payout to seller failed");

        emit DisputeResolvedToSeller(arbiter, seller, payout);
    }

    /**
     * @dev Arbiter arbitrates in favor of buyer; refunds vaulted ETH to buyer.
     */
    function resolveToBuyer() external onlyArbiter inState(State.Disputed) {
        state = State.Refunded;
        uint256 payout = address(this).balance;

        (bool success, ) = buyer.call{value: payout}("");
        require(success, "Dispute refund to buyer failed");

        emit DisputeResolvedToBuyer(arbiter, buyer, payout);
    }

    /**
     * @dev Returns current contract balance in wei.
     */
    function contractBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
