// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Import necessary contracts from OpenZeppelin and custom interface
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "../interface/IItem.sol";

/**
 * @title Item
 * @author Krieger
 * @notice Item NFT contract
 */
contract Item is IItem, ERC721URIStorage {
    using Strings for string;

    /**
     * ========================================================= *
     *                   Storage Declarations                    *
     * ========================================================= *
     */

    // Address of the core controller (Item Factory) - Immutable once set
    address immutable coreController;

    // Description of the items (publicly accessible)
    string public description;

    // Constructor to initialize the contract with a name, symbol, and the address of the Item Factory
    constructor(string memory name_, string memory symbol_, address coreController_) ERC721(name_, symbol_) {
        coreController = coreController_;
    }

    // Modifier to restrict access to only the Item Factory
    modifier onlyController() {
        require(msg.sender == coreController, "OnlyFactory: Caller is not the core controller");
        _;
    }

    /**
     * ========================================================= *
     *                      Public Functions                      *
     * ========================================================= *
     */

    /**
     * @dev Mints a batch of tokens for the specified user
     * @param user_ The address of the user
     * @param totalSupply_ The total supply of the tokens
     * @param tokenURI_ The URI for the tokens
     * @param description_ The description of the tokens
     */
    function batchMint(address user_, uint256 totalSupply_, string memory tokenURI_, string memory description_)
        public
        onlyController
    {
        // Update the common description for all minted tokens
        description = description_;

        // Mint tokens and set their token URIs
        for (uint256 i = 1; i <= totalSupply_; i++) {
            _mint(user_, i);
            _setTokenURI(i, tokenURI_);
        }
    }

    /**
     * @dev Fetches metadata for the specified user's items
     * @param tokenId_ The ID of the token
     * @return itemMetadata The metadata of the user's items
     */
    function fetchUserItems(uint256 tokenId_) public view returns (string memory itemMetadata) {
        // Get token URI and construct JSON metadata
        string memory ipfsCid = tokenURI(tokenId_);
        string memory name = name();
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": ',
                        '"',
                        name,
                        '"' ", " '"description": ',
                        '"',
                        description,
                        '"' ", " '"image": ',
                        '"',
                        ipfsCid,
                        '"}'
                    )
                )
            )
        );

        // Concatenate JSON metadata and return
        itemMetadata = string(abi.encodePacked(json));
    }

    /**
     * @dev Updates the token URI for a specific token
     * @param tokenId_ The ID of the token
     * @param tokenURI_ The new URI for the token
     */
    function updateTokenURI(uint256 tokenId_, string memory tokenURI_) public onlyController {
        // Update the token URI for the specified token
        _setTokenURI(tokenId_, tokenURI_);
    }
}
