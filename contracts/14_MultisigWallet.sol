// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title MultisigWallet
 * @dev M-of-N multi-signature treasury wallet.
 * Transactions require approvals from a required threshold of predefined owners before execution.
 * Auto-executes upon meeting the confirmation threshold.
 */
contract MultisigWallet {
    struct Transaction {
        address to;
        uint256 value;
        bool executed;
    }

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public required;

    Transaction[] public transactions;

    // txId => owner => confirmed
    mapping(uint256 => mapping(address => bool)) public confirmed;

    event Submission(uint256 indexed txId);
    event Confirmation(address indexed owner, uint256 indexed txId);
    event Execution(uint256 indexed txId);
    event Deposit(address indexed sender, uint256 amount);

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Caller is not an authorized owner");
        _;
    }

    modifier txExists(uint256 txId) {
        require(txId < transactions.length, "Transaction does not exist");
        _;
    }

    modifier notExecuted(uint256 txId) {
        require(!transactions[txId].executed, "Transaction already executed");
        _;
    }

    modifier notConfirmed(uint256 txId) {
        require(!confirmed[txId][msg.sender], "Transaction already confirmed by this owner");
        _;
    }

    /**
     * @dev Sets up list of owners and confirmation quorum threshold.
     * @param _owners Array of unique owner addresses.
     * @param _required Minimum number of confirmations required for execution.
     */
    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "Owners list cannot be empty");
        require(_required > 0 && _required <= _owners.length, "Invalid confirmation requirement");

        for (uint256 i = 0; i < _owners.length; i++) {
            address ownerAddr = _owners[i];
            require(ownerAddr != address(0), "Owner address cannot be zero");
            require(!isOwner[ownerAddr], "Owner addresses must be unique");

            isOwner[ownerAddr] = true;
            owners.push(ownerAddr);
        }

        required = _required;
    }

    /**
     * @dev Fallback function to accept incoming ETH deposits into wallet treasury.
     */
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @dev Submits a proposed transaction and automatically adds submitter's confirmation.
     * @param to Target destination address.
     * @param value Amount of wei to transfer.
     * @return txId Identifier of submitted transaction.
     */
    function submitTransaction(address to, uint256 value) external onlyOwner returns (uint256) {
        require(to != address(0), "Target address cannot be zero");

        uint256 txId = transactions.length;
        transactions.push(Transaction({
            to: to,
            value: value,
            executed: false
        }));

        emit Submission(txId);

        // Auto-confirm for submitter
        confirmTransaction(txId);

        return txId;
    }

    /**
     * @dev Confirms a pending transaction.
     * Triggers execution automatically once required confirmations are reached.
     * @param txId Transaction identifier.
     */
    function confirmTransaction(uint256 txId)
        public
        onlyOwner
        txExists(txId)
        notExecuted(txId)
        notConfirmed(txId)
    {
        confirmed[txId][msg.sender] = true;
        emit Confirmation(msg.sender, txId);

        if (getConfirmations(txId) >= required) {
            executeTransaction(txId);
        }
    }

    /**
     * @dev Executes a transaction that has collected sufficient confirmations.
     * @param txId Transaction identifier.
     */
    function executeTransaction(uint256 txId)
        public
        onlyOwner
        txExists(txId)
        notExecuted(txId)
    {
        require(getConfirmations(txId) >= required, "Insufficient confirmations to execute");

        Transaction storage txn = transactions[txId];
        require(address(this).balance >= txn.value, "Insufficient balance in multisig treasury");

        txn.executed = true;

        (bool success, ) = txn.to.call{value: txn.value}("");
        require(success, "Transaction execution call failed");

        emit Execution(txId);
    }

    /**
     * @dev Counts the number of valid owner confirmations for a given transaction.
     * @param txId Transaction identifier.
     * @return count Number of confirmations.
     */
    function getConfirmations(uint256 txId) public view txExists(txId) returns (uint256 count) {
        for (uint256 i = 0; i < owners.length; i++) {
            if (confirmed[txId][owners[i]]) {
                count += 1;
            }
        }
    }

    /**
     * @dev Returns total number of submitted transactions.
     */
    function getTransactionCount() external view returns (uint256) {
        return transactions.length;
    }

    /**
     * @dev Returns list of all wallet owners.
     */
    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    /**
     * @dev Returns the current ETH balance held by the multisig contract.
     */
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
