// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title MyToken
 * @dev Standalone ERC-20 compliant fungible token built without external libraries.
 * Implements core token mechanics: minting, balance tracking, approvals, and 2-step transferFrom delegations.
 */
contract MyToken {
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    // Balances mapping: account => token balance
    mapping(address => uint256) public balanceOf;

    // Allowances mapping: owner => spender => approved allowance
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Initializes token metadata and mints total supply to the deployer.
     * @param _n Token name (e.g. "MyToken")
     * @param _s Token ticker symbol (e.g. "MTK")
     * @param _supply Initial token supply in whole units (will be scaled by 10^18).
     */
    constructor(string memory _n, string memory _s, uint256 _supply) {
        name = _n;
        symbol = _s;
        totalSupply = _supply * (10 ** uint256(decimals));
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    /**
     * @dev Transfers tokens directly from caller to recipient.
     * @param to Recipient address.
     * @param value Amount of tokens to transfer (in smallest wei unit).
     * @return True if transfer succeeds.
     */
    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0), "Cannot transfer to the zero address");
        require(balanceOf[msg.sender] >= value, "Insufficient balance");

        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;

        emit Transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Authorizes a spender to withdraw up to `value` tokens from caller's account.
     * @param spender Address permitted to spend funds.
     * @param value Max token allowance granted.
     * @return True if approval succeeds.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0), "Cannot approve zero address");

        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfers tokens on behalf of `from` to `to` using previously approved allowance.
     * @param from Source token holder address.
     * @param to Destination address.
     * @param value Token amount to transfer.
     * @return True if operation succeeds.
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(from != address(0), "Cannot transfer from zero address");
        require(to != address(0), "Cannot transfer to zero address");
        require(balanceOf[from] >= value, "Insufficient balance");
        require(allowance[from][msg.sender] >= value, "Insufficient allowance");

        allowance[from][msg.sender] -= value;
        balanceOf[from] -= value;
        balanceOf[to] += value;

        emit Transfer(from, to, value);
        return true;
    }
}
