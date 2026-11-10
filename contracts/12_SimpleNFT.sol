// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SimpleNFT
 * @dev Standalone Non-Fungible Token (NFT) contract without external dependencies.
 * Implements token minting with supply and price caps, owner-based transfers, approval delegation,
 * transferFrom mechanisms, and administrative revenue withdrawal.
 */
contract SimpleNFT {
    string public name;
    string public symbol;
    address public owner;

    uint256 public nextTokenId;
    uint256 public constant MAX_SUPPLY = 100;
    uint256 public mintPrice = 0.01 ether;

    // Token ID to owner address
    mapping(uint256 => address) public ownerOf;

    // Owner address to token balance count
    mapping(address => uint256) public balances;

    // Token ID to approved spender address
    mapping(uint256 => address) public approvals;

    event Minted(address indexed to, uint256 indexed tokenId);
    event TransferNFT(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 indexed tokenId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call");
        _;
    }

    /**
     * @dev Initializes NFT collection name, symbol, and contract owner.
     * @param _name Collection name (e.g. "SimpleNFT")
     * @param _symbol Collection ticker (e.g. "SNFT")
     */
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        owner = msg.sender;
    }

    /**
     * @dev Mints a new unique token ID to the caller.
     * Requires exact payment of mintPrice and total supply < MAX_SUPPLY.
     * @return Assigned tokenId.
     */
    function mint() external payable returns (uint256) {
        require(msg.value == mintPrice, "Must pay exact mint price of 0.01 ETH");
        require(nextTokenId < MAX_SUPPLY, "Max supply reached");

        uint256 tokenId = nextTokenId;
        nextTokenId += 1;

        ownerOf[tokenId] = msg.sender;
        balances[msg.sender] += 1;

        emit Minted(msg.sender, tokenId);
        emit TransferNFT(address(0), msg.sender, tokenId);

        return tokenId;
    }

    /**
     * @dev Direct transfer of token ownership by the token owner.
     * @param to Destination address.
     * @param tokenId Token identifier to transfer.
     */
    function transferNFT(address to, uint256 tokenId) external {
        require(to != address(0), "Cannot transfer to zero address");
        require(ownerOf[tokenId] == msg.sender, "Caller is not the token owner");

        // Clear existing approval
        delete approvals[tokenId];

        balances[msg.sender] -= 1;
        balances[to] += 1;
        ownerOf[tokenId] = to;

        emit TransferNFT(msg.sender, to, tokenId);
    }

    /**
     * @dev Approves an external operator/spender to transfer a specific token ID.
     * @param spender Address granted transfer permission.
     * @param tokenId Token identifier being approved.
     */
    function approve(address spender, uint256 tokenId) external {
        require(ownerOf[tokenId] == msg.sender, "Caller is not token owner");
        require(spender != msg.sender, "Cannot approve self");

        approvals[tokenId] = spender;
        emit Approval(msg.sender, spender, tokenId);
    }

    /**
     * @dev Transfers token on behalf of owner using delegated approval.
     * @param from Address of current token owner.
     * @param to Recipient address.
     * @param tokenId Token identifier being transferred.
     */
    function transferFrom(address from, address to, uint256 tokenId) external {
        require(to != address(0), "Cannot transfer to zero address");
        require(ownerOf[tokenId] == from, "From address does not own token");
        require(
            msg.sender == ownerOf[tokenId] || msg.sender == approvals[tokenId],
            "Caller is not owner or approved spender"
        );

        // Clear approval
        delete approvals[tokenId];

        balances[from] -= 1;
        balances[to] += 1;
        ownerOf[tokenId] = to;

        emit TransferNFT(from, to, tokenId);
    }

    /**
     * @dev Allows contract owner to withdraw collected minting revenue.
     */
    function withdrawPayments() external onlyOwner {
        uint256 revenue = address(this).balance;
        require(revenue > 0, "No funds to withdraw");

        (bool success, ) = payable(owner).call{value: revenue}("");
        require(success, "Revenue withdrawal failed");
    }
}
