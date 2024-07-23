// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ABC is ERC20, Ownable {
    uint256 private immutable _maxSupply;
    mapping(address => bool) private _whitelist;

    /**
     * @dev Emitted when an address is added to the whitelist
     * @param account The address added to the whitelist
     */
    event WhitelistAdded(address indexed account);

    /**
     * @dev Emitted when an address is removed from the whitelist
     * @param account The address removed from the whitelist
     */
    event WhitelistRemoved(address indexed account);

    /**
     * @dev Constructor that sets the name, symbol and max supply of the token
     * @param name_ The name of the token
     * @param symbol_ The symbol of the token
     * @param maxSupply_ The maximum supply of the token
     */
    constructor(string memory name_, string memory symbol_, uint256 maxSupply_) 
        ERC20(name_, symbol_)
    {
        _maxSupply = maxSupply_;
    }

    /**
     * @dev Modifier to check if an address is whitelisted
     */
    modifier onlyWhitelisted() {
        require(_whitelist[msg.sender], "ABC: Caller is not whitelisted");
        _;
    }

    /**
     * @dev Adds an address to the whitelist
     * @param account The address to be added to the whitelist
     * @notice Only the owner can call this function
     */
    function addToWhitelist(address account) external onlyOwner {
        require(!_whitelist[account], "ABC: Account is already whitelisted");
        _whitelist[account] = true;
        emit WhitelistAdded(account);
    }

    /**
     * @dev Removes an address from the whitelist
     * @param account The address to be removed from the whitelist
     * @notice Only the owner can call this function
     */
    function removeFromWhitelist(address account) external onlyOwner {
        require(_whitelist[account], "ABC: Account is not whitelisted");
        _whitelist[account] = false;
        emit WhitelistRemoved(account);
    }

    /**
     * @dev Checks if an address is whitelisted
     * @param account The address to check
     * @return bool True if the address is whitelisted, false otherwise
     */
    function isWhitelisted(address account) public view returns (bool) {
        return _whitelist[account];
    }

    /**
     * @dev Mints new tokens
     * @param to The address that will receive the minted tokens
     * @param amount The amount of tokens to mint
     * @notice Only the owner can call this function and the recipient must be whitelisted
     */
    function mint(address to, uint256 amount) public onlyOwner {
        require(isWhitelisted(to), "ABC: Recipient is not whitelisted");
        require(totalSupply() + amount <= _maxSupply, "ABC: Max supply exceeded");
        _mint(to, amount);
    }

    /**
     * @dev Overrides the transfer function to enforce whitelist restrictions
     * @param to The recipient address
     * @param value The amount of tokens to transfer
     * @return bool True if the transfer was successful
     */
    function transfer(address to, uint256 value) public virtual override onlyWhitelisted returns (bool) {
        require(isWhitelisted(to), "ABC: Recipient is not whitelisted");
        return super.transfer(to, value);
    }

    /**
     * @dev Overrides the transferFrom function to enforce whitelist restrictions
     * @param from The sender address
     * @param to The recipient address
     * @param value The amount of tokens to transfer
     * @return bool True if the transfer was successful
     */
    function transferFrom(address from, address to, uint256 value) public virtual override onlyWhitelisted returns (bool) {
        require(isWhitelisted(to), "ABC: Recipient is not whitelisted");
        return super.transferFrom(from, to, value);
    }

    /**
     * @dev Returns the max supply of the token
     * @return The maximum supply of the token
     */
    function maxSupply() public view returns (uint256) {
        return _maxSupply;
    }
}