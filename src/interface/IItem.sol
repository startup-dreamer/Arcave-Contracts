// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
/**
 * @title IItem
 * @dev Interface for Item contract
 */

interface IItem is IERC721 {
    /**
     * ========================================================= *
     *                   Public Function                      *
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
        external;

    /**
     * @dev Fetches metadata for the specified user's items
     * @param tokenId_ The ID of the token
     * @return itemMetadata The metadata of the user's items
     */
    function fetchUserItems(uint256 tokenId_) external view returns (string memory itemMetadata);

    /**
     * @dev Updates the token URI for a specific token
     * @param tokenId_ The ID of the token
     * @param tokenURI_ The new URI for the token
     */
    function updateTokenURI(uint256 tokenId_, string memory tokenURI_) external;

    /**
     * ========================================================= *
     *                   Custom Errors                          *
     * ========================================================= *
     */

    error OnlyFactory();
}
