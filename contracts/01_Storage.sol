// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Storage
 * @dev Basic contract to store and retrieve an unsigned integer on-chain.
 * Implements event emission on state updates and gas-free view reading.
 */
contract Storage {
    // State variable to store the number
    uint256 private storedData;

    /**
     * @dev Emitted when storedData is updated.
     * @param who The address that initiated the value update.
     * @param newValue The new value stored in the contract.
     */
    event ValueSet(address indexed who, uint256 newValue);

    /**
     * @dev Sets the initial value upon contract deployment.
     * @param _init Initial value to store.
     */
    constructor(uint256 _init) {
        storedData = _init;
        emit ValueSet(msg.sender, _init);
    }

    /**
     * @dev Stores a new value in state and logs an event.
     * @param _value The new number to store.
     */
    function set(uint256 _value) public {
        storedData = _value;
        emit ValueSet(msg.sender, _value);
    }

    /**
     * @dev Retrieves the currently stored value.
     * @return The unsigned integer currently held in storage.
     */
    function get() public view returns (uint256) {
        return storedData;
    }
}
