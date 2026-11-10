// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Counter
 * @dev Implements a bounded counter that operates within [0, MAX].
 * Guards boundary conditions using require statements and emits event notifications.
 */
contract Counter {
    // Current count value
    uint256 public count;

    // Maximum upper bound limit for count
    uint256 public constant MAX = 100;

    /**
     * @dev Emitted when count is incremented.
     * @param by Address that called increment.
     * @param newCount Updated count value.
     */
    event Incremented(address indexed by, uint256 newCount);

    /**
     * @dev Emitted when count is decremented.
     * @param by Address that called decrement.
     * @param newCount Updated count value.
     */
    event Decremented(address indexed by, uint256 newCount);

    /**
     * @dev Emitted when counter is reset to zero.
     * @param by Address that called reset.
     */
    event Reset(address indexed by);

    /**
     * @dev Increments the counter by 1.
     * Reverts if the counter has reached the MAX limit.
     */
    function increment() public {
        require(count < MAX, "Max limit reached");
        count += 1;
        emit Incremented(msg.sender, count);
    }

    /**
     * @dev Decrements the counter by 1.
     * Reverts if the counter is already zero.
     */
    function decrement() public {
        require(count > 0, "Count is zero");
        count -= 1;
        emit Decremented(msg.sender, count);
    }

    /**
     * @dev Resets the counter explicitly back to zero.
     */
    function reset() public {
        count = 0;
        emit Reset(msg.sender);
    }
}
