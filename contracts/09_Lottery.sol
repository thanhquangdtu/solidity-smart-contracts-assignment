// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Lottery
 * @dev Autonomous pooled lottery where players join by paying an exact entry fee.
 * The manager triggers winner selection once minimum player threshold is met.
 *
 * NOTE ON RANDOMNESS:
 * In production blockchains, using on-chain block properties (such as blockhash or block.timestamp)
 * for randomness is insecure because miners/validators can preview or manipulate hashes to favor their
 * own addresses or withhold unfavorable blocks. Production protocols must integrate cryptographic
 * oracles such as Chainlink VRF (Verifiable Random Function) for provably fair, tamper-proof randomness.
 */
contract Lottery {
    // List of active participants in current round
    address payable[] private players;

    // Manager / administrator
    address public manager;

    // Exact entry fee required in wei
    uint256 public entryFee;

    // Minimum number of participants required before winner can be selected
    uint256 public minPlayers;

    // Current lottery round counter
    uint256 public lotteryRound;

    event PlayerEntered(address indexed player, uint256 round);
    event WinnerSelected(address indexed winner, uint256 amount, uint256 round);

    modifier onlyManager() {
        require(msg.sender == manager, "Only manager can execute");
        _;
    }

    /**
     * @dev Initializes lottery settings.
     * @param _entryFee Required ticket fee in wei.
     * @param _minPlayers Minimum number of players before selecting winner.
     */
    constructor(uint256 _entryFee, uint256 _minPlayers) {
        require(_entryFee > 0, "Entry fee must be greater than zero");
        require(_minPlayers > 0, "Minimum players must be at least 1");

        manager = msg.sender;
        entryFee = _entryFee;
        minPlayers = _minPlayers;
        lotteryRound = 1;
    }

    /**
     * @dev Allows participants to buy a ticket into the current lottery round.
     * Manager cannot participate to prevent conflict of interest.
     */
    function enter() public payable {
        require(msg.sender != manager, "Manager cannot enter lottery");
        require(msg.value == entryFee, "Must pay exact entry fee");

        players.push(payable(msg.sender));
        emit PlayerEntered(msg.sender, lotteryRound);
    }

    /**
     * @dev Returns count of current round entrants.
     */
    function playersCount() public view returns (uint256) {
        return players.length;
    }

    /**
     * @dev Returns list of all current round players.
     */
    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }

    /**
     * @dev Picks winner, sends entire pot, and resets player array for the next round.
     */
    function pickWinner() public onlyManager {
        require(players.length >= minPlayers, "Not enough players to pick winner");

        // Generate pseudo-random index using blockhash, timestamp, and array length
        uint256 randomness = uint256(
            keccak256(
                abi.encodePacked(
                    blockhash(block.number - 1),
                    block.timestamp,
                    players.length
                )
            )
        );

        uint256 index = randomness % players.length;
        address payable winner = players[index];
        uint256 prize = address(this).balance;
        uint256 roundCompleted = lotteryRound;

        // Reset state for new round before transferring funds (CEI pattern)
        players = new address payable[](0);
        lotteryRound += 1;

        (bool success, ) = winner.call{value: prize}("");
        require(success, "Prize payout failed");

        emit WinnerSelected(winner, prize, roundCompleted);
    }
}
