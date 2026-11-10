// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Voting
 * @dev Democratic election system managed by a chairperson.
 * Voters are authorized by the chairperson and can vote once for listed candidates.
 */
contract Voting {
    struct Candidate {
        string name;
        uint256 voteCount;
    }

    struct Voter {
        bool authorized;
        bool voted;
        uint256 voteIndex;
    }

    // Dynamic array of election candidates
    Candidate[] public candidates;

    // Mapping from voter address to their registration & voting record
    mapping(address => Voter) public voters;

    // Chairperson who controls voter authorization
    address public chairperson;

    event VoterAuthorized(address indexed voter);
    event Voted(address indexed voter, uint256 indexed candidateIndex);

    modifier onlyChairperson() {
        require(msg.sender == chairperson, "Only chairperson can authorize");
        _;
    }

    /**
     * @dev Initializes election with a list of candidate names.
     * @param candidateNames Array of candidate names.
     */
    constructor(string[] memory candidateNames) {
        require(candidateNames.length > 0, "At least one candidate is required");
        chairperson = msg.sender;

        for (uint256 i = 0; i < candidateNames.length; i++) {
            candidates.push(Candidate({
                name: candidateNames[i],
                voteCount: 0
            }));
        }
    }

    /**
     * @dev Chairperson authorizes an address to cast a vote.
     * @param voter Address to grant voting privilege.
     */
    function authorize(address voter) external onlyChairperson {
        require(voter != address(0), "Invalid voter address");
        require(!voters[voter].authorized, "Voter is already authorized");
        require(!voters[voter].voted, "Voter has already voted");

        voters[voter].authorized = true;
        emit VoterAuthorized(voter);
    }

    /**
     * @dev Casts vote for the candidate at candidateIndex.
     * @param candidateIndex Index in the candidates array.
     */
    function vote(uint256 candidateIndex) external {
        Voter storage sender = voters[msg.sender];
        require(sender.authorized, "Not authorized to vote");
        require(!sender.voted, "Already voted");
        require(candidateIndex < candidates.length, "Invalid candidate index");

        sender.voted = true;
        sender.voteIndex = candidateIndex;
        candidates[candidateIndex].voteCount += 1;

        emit Voted(msg.sender, candidateIndex);
    }

    /**
     * @dev Returns the total votes received by candidate at candidateIndex.
     * @param candidateIndex Index of the candidate.
     * @return Number of votes.
     */
    function totalVotes(uint256 candidateIndex) external view returns (uint256) {
        require(candidateIndex < candidates.length, "Invalid candidate index");
        return candidates[candidateIndex].voteCount;
    }

    /**
     * @dev Calculates and returns the name of the winning candidate.
     * @return winnerName_ Name of candidate with maximum votes.
     */
    function winnerName() external view returns (string memory winnerName_) {
        require(candidates.length > 0, "No candidates registered");
        uint256 winningVoteCount = 0;
        uint256 winningIndex = 0;

        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > winningVoteCount) {
                winningVoteCount = candidates[i].voteCount;
                winningIndex = i;
            }
        }

        winnerName_ = candidates[winningIndex].name;
    }

    /**
     * @dev Returns total number of registered candidates.
     */
    function getCandidatesCount() external view returns (uint256) {
        return candidates.length;
    }
}
