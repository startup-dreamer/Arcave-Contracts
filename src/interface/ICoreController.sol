// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

/**
 * @title ICoreController
 * @dev Interface for Core Controller contract
 */
interface ICoreController {
    /**
     * ========================================================= *
     *                   Events                               *
     * ========================================================= *
     */

    event AvatarCreated(address indexed owner, string tokenURI, string description);
    event ItemCreated(address indexed owner, uint256 totalSupply, string tokenURI, string description);
    event TokensMinted(address indexed owner, uint256 totalSupply, string name, string symbol);
    event TokensBurned(address indexed owner, uint256 totalSupply, string name, string symbol);
    event ItemSold(uint256 indexed itemNum, uint256 tokenId);

    /**
     * ========================================================= *
     *                   Custom Errors                          *
     * ========================================================= *
     */

    error InvalidOwnerAddress();
    error EmptyTokenURI();
    error EmptyDescription();
    error InvalidTotalSupply();
    error EmptyName();
    error EmptySymbol();
    error AvatarAlreadyMinted();

    struct UserInfo {
        uint256 x;
        uint256 y;
        uint256 z;
        uint256 userMaxScore;
        address[4] friends;
    }

    /**
     * ========================================================= *
     *                   Public Function                      *
     * ========================================================= *
     */

    function createAvatar(
        address owner_,
        string memory avatarURI_,
        string memory description_,
        string memory userAttributes_
    ) external;

    function createItem(
        address user_,
        uint256 totalSupply_,
        string memory name_,
        string memory symbol_,
        string memory itemURI_,
        string memory description_
    ) external;

    function mint(address owner_, uint256 amount_, string memory name_, string memory symbol_) external;

    function burn(address owner_, uint256 amount_, string memory name_, string memory symbol_) external;

    function fetchUserMetadata(address user_)
        external
        view
        returns (string memory avatarMetadata, string[] memory itemMetadata, uint256 maxScore, address[4] memory friends, UserInfo memory userInfo);
    function listOnMarketplace(uint256 itemNum_, uint256 price_) external;
    function removeFromMarketplace(uint256 itemNum_) external;
    function purchaseItem(uint256 itemNum_) external payable;
}
