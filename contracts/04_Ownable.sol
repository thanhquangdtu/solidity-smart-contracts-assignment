// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Ownable
 * @dev Reusable base contract providing ownership access control mechanism.
 * Function modifiers streamline validation and eliminate redundant code.
 */
contract Ownable {
    address public owner;

    /**
     * @dev Emitted when ownership is handed over to a new address.
     * @param previousOwner The former contract owner.
     * @param newOwner The newly assigned contract owner.
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes deployer as the initial owner.
     */
    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    /**
     * @dev Modifier to restrict function invocation to the contract owner only.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    /**
     * @dev Transfers ownership to a new address.
     * @param newOwner Address to receive ownership rights (cannot be zero address).
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

/**
 * @title ProtectedVault
 * @dev Inherits Ownable to guard treasury withdrawals.
 * Anyone can deposit ETH, but only the owner can withdraw stored funds.
 */
contract ProtectedVault is Ownable {
    uint256 private treasure;

    event Deposited(address indexed sender, uint256 amount);
    event Withdrawn(address indexed to, uint256 amount);

    /**
     * @dev Allows any user to deposit ETH into the vault.
     */
    function deposit() public payable {
        require(msg.value > 0, "Deposit must be greater than zero");
        treasure += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    /**
     * @dev Allows only the owner to withdraw a specified amount to a destination address.
     * @param to Recipient address for the withdrawn ETH.
     * @param amt Amount of wei to transfer.
     */
    function withdraw(address to, uint256 amt) public onlyOwner {
        require(to != address(0), "Cannot withdraw to zero address");
        require(amt <= address(this).balance, "Insufficient contract balance");

        if (amt <= treasure) {
            treasure -= amt;
        } else {
            treasure = 0;
        }

        (bool success, ) = payable(to).call{value: amt}("");
        require(success, "Withdrawal transfer failed");

        emit Withdrawn(to, amt);
    }

    /**
     * @dev Returns total ETH balance held by the vault.
     * @return Current contract balance in wei.
     */
    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
