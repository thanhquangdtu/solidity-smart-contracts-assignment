// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SimpleBank
 * @dev Manages individual ETH deposit balances with secure withdrawal functionality.
 * Implements the Checks-Effects-Interactions (CEI) design pattern to eliminate re-entrancy vulnerabilities.
 */
contract SimpleBank {
    // Mapping from user address to individual deposit balance in wei
    mapping(address => uint256) private balances;

    /**
     * @dev Emitted when a user deposits ETH.
     * @param user The address making the deposit.
     * @param amount The value deposited in wei.
     */
    event Deposited(address indexed user, uint256 amount);

    /**
     * @dev Emitted when a user successfully withdraws ETH.
     * @param user The address withdrawing funds.
     * @param amount The value withdrawn in wei.
     */
    event Withdrawn(address indexed user, uint256 amount);

    /**
     * @dev Allows users to deposit ETH into their personal bank ledger.
     */
    function deposit() public payable {
        require(msg.value > 0, "Deposit must be greater than zero");
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /**
     * @dev Allows a user to withdraw a specified amount from their own balance.
     * Follows strict Checks-Effects-Interactions pattern:
     * 1. Checks: Validate caller has sufficient balance and requested amount > 0.
     * 2. Effects: Update user's balance state variable before external interaction.
     * 3. Interactions: Send ETH via low-level call and verify return boolean.
     * @param amount The amount of wei to withdraw.
     */
    function withdraw(uint256 amount) public {
        // 1. CHECKS
        require(amount > 0, "Amount must be greater than zero");
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // 2. EFFECTS (state updated before any external invocation)
        balances[msg.sender] -= amount;

        // 3. INTERACTIONS (external call performed last)
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "ETH transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    /**
     * @dev Returns caller's deposited balance.
     * @return Caller balance in wei.
     */
    function myBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    /**
     * @dev Returns specific user's balance.
     * @param user Address to inspect.
     * @return User balance in wei.
     */
    function getBalanceOf(address user) public view returns (uint256) {
        return balances[user];
    }

    /**
     * @dev Returns total ETH reserve stored inside this contract.
     * @return Contract total balance in wei.
     */
    function bankTotal() public view returns (uint256) {
        return address(this).balance;
    }
}
