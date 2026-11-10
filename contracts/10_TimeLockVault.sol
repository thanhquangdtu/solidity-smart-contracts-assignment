// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title TimeLockVault
 * @dev Time-locked deposit vault.
 * Anyone can deposit funds, but the designated beneficiary can only withdraw after unlockTime.
 * The beneficiary can extend the lock duration if needed.
 */
contract TimeLockVault {
    address payable public beneficiary;
    uint256 public unlockTime;

    event Deposited(address indexed from, uint256 amount, uint256 newUnlockTime);
    event Withdrawn(address indexed to, uint256 amount);
    event LockExtended(uint256 previousUnlockTime, uint256 newUnlockTime);

    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary, "Caller is not the beneficiary");
        _;
    }

    /**
     * @dev Sets beneficiary and initial lock expiration timestamp.
     * @param _beneficiary Beneficiary address entitled to funds.
     * @param _lockSeconds Duration in seconds to lock the vault.
     */
    constructor(address payable _beneficiary, uint256 _lockSeconds) {
        require(_beneficiary != address(0), "Invalid beneficiary address");
        beneficiary = _beneficiary;
        unlockTime = block.timestamp + _lockSeconds;
    }

    /**
     * @dev Allows anyone to deposit ETH into the vault.
     * Does not alter unlock time.
     */
    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        emit Deposited(msg.sender, msg.value, unlockTime);
    }

    /**
     * @dev Beneficiary can extend lock duration further into the future.
     * @param _extraSeconds Additional seconds to add to unlockTime.
     */
    function extendLock(uint256 _extraSeconds) external onlyBeneficiary {
        require(_extraSeconds > 0, "Extra seconds must be greater than zero");
        uint256 previousTime = unlockTime;
        unlockTime += _extraSeconds;
        emit LockExtended(previousTime, unlockTime);
    }

    /**
     * @dev Allows beneficiary to withdraw all vaulted ETH once unlockTime has passed.
     */
    function withdraw() external onlyBeneficiary {
        require(block.timestamp >= unlockTime, "Vault is still locked");

        uint256 amount = address(this).balance;
        require(amount > 0, "No funds available to withdraw");

        (bool success, ) = beneficiary.call{value: amount}("");
        require(success, "Withdrawal transfer failed");

        emit Withdrawn(beneficiary, amount);
    }

    /**
     * @dev Returns remaining seconds until funds unlock.
     * @return Seconds until unlock (0 if already unlocked).
     */
    function timeRemaining() external view returns (uint256) {
        if (block.timestamp >= unlockTime) {
            return 0;
        }
        return unlockTime - block.timestamp;
    }

    /**
     * @dev Returns current ETH balance held in the vault.
     */
    function vaultBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
