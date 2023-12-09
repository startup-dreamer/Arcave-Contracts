// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title ArcaveToken
 * @dev Arcave Token contract
 * @author Krieger
 */

contract ArcaveToken is ERC20, ERC20Burnable {
    address immutable coreContorller;

    // Modifier to restrict access to only the core contract
    modifier onlyController() {
        require(msg.sender == coreContorller, "Only factory can call this function");
        _;
    }

    /**
     * @dev Constructor to initialize the ArcaveToken
     * @param coreContorller_ The address of the core controller
     * @param name_ The name of the token
     * @param symbol_ The symbol of the token
     */
    constructor(address coreContorller_, string memory name_, string memory symbol_) ERC20(name_, symbol_) {
        coreContorller = coreContorller_;
    }

    /**
     * @dev Function to mint new tokens
     * @param to_ The address to which the tokens will be minted
     * @param amount_ The amount of tokens to mint
     */
    function mint(address to_, uint256 amount_) public onlyController {
        _mint(to_, amount_);
    }

    /**
     * @dev Function to burn tokens
     * @param from_ The address from which the tokens will be burned
     * @param amount_ The amount of tokens to burn
     */
    function burn(address from_, uint256 amount_) public onlyController {
        _burn(from_, amount_);
    }
}
