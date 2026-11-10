// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Greeting
 * @dev Stores a greeting message accessible to everyone but modifiable only by the owner.
 * Demonstrates basic access control and string handling.
 */
contract Greeting {
    // Private state variable to store greeting message
    string private greeting;

    // Public state variable to store contract owner
    address public owner;

    /**
     * @dev Emitted whenever the greeting string is updated or reset.
     * @param changer Address of the caller who updated the greeting.
     * @param newGreeting The new greeting text set.
     */
    event GreetingChanged(address indexed changer, string newGreeting);

    /**
     * @dev Initializes contract with an initial greeting and sets deployer as owner.
     * @param _g Initial greeting string.
     */
    constructor(string memory _g) {
        owner = msg.sender;
        greeting = _g;
        emit GreetingChanged(msg.sender, _g);
    }

    /**
     * @dev Updates the greeting message. Only callable by the contract owner.
     * @param _g New greeting string.
     */
    function setGreeting(string memory _g) public {
        require(msg.sender == owner, "Caller is not the owner");
        greeting = _g;
        emit GreetingChanged(msg.sender, _g);
    }

    /**
     * @dev Reads the current greeting.
     * @return The currently stored greeting string.
     */
    function greet() public view returns (string memory) {
        return greeting;
    }

    /**
     * @dev Resets the greeting back to default 'Hello, World!'. Only callable by the owner.
     */
    function resetGreeting() public {
        require(msg.sender == owner, "Caller is not the owner");
        greeting = "Hello, World!";
        emit GreetingChanged(msg.sender, greeting);
    }
}
