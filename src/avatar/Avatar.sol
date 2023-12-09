// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "../interface/IAvatar.sol";

/**
 * @title Avatar
 * @dev Contract for managing user avatars
 */
contract Avatar is ERC721URIStorage, IAvatar {
    using Strings for string;

    /**
     * ========================================================= *
     *                   Storage Declarations                    *
     * ========================================================= *
     */

    // Address of the CoreController contract
    address immutable coreController;

    // Token ID counter
    uint256 public tokenId;

    // Avatar description
    string public description;

    // Mapping to store user attributes by address
    mapping(address => string) public avatarAttributes;

    // Mapping to store the last minted token ID for each user
    mapping(address => uint256) public userMintedToekn;

    // Modifier to restrict access to only the CoreController
    modifier onlyController() {
        require(msg.sender == coreController, "Only factory can call this function");
        _;
    }

    /**
     * ========================================================= *
     *                    Constructor Function                   *
     * ========================================================= *
     */

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the avatar.
     * @param coreController_ The address of the CoreController contract
     * @param name_ Name of the avatar NFT
     * @param symbol_ Symbol of the avatar NFT
     */
    constructor(address coreController_, string memory name_, string memory symbol_) ERC721(name_, symbol_) {
        coreController = coreController_;
    }

    /**
     * ========================================================= *
     *                      Public Function                      *
     * ========================================================= *
     */

    /**
     * @dev Mints new avatar for a user.
     * @param owner_ The address of the user/creator
     * @param tokenURI_ URI for the avatar's metadata
     * @param description_ Description of the avatar
     * @param userAttributes_ Additional attributes of the avatar
     */
    function createAvatar(
        address owner_,
        string memory tokenURI_,
        string memory description_,
        string memory userAttributes_
    ) external override onlyController {
        tokenId = tokenId + 1;
        avatarAttributes[owner_] = userAttributes_;
        userMintedToekn[owner_] = tokenId;
        _mint(owner_, tokenId);
        _setTokenURI(tokenId, tokenURI_);
        description = description_;
    }

    /**
     * @dev Fetches metadata for user avatar for a specific user
     * @param user_ The address of the user/creator
     * @return itemMetadata An array of JSON strings representing the metadata of the items
     */
    function fetchUserAvatar(address user_) external view override returns (string memory itemMetadata) {
        uint256 _tokenId = userMintedToekn[user_];
        string memory ipfsCid = tokenURI(_tokenId);
        string memory avatarAttribute = avatarAttributes[user_];
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
                        '"' ", " '"attributes": ',
                        '"',
                        avatarAttribute,
                        '"}'
                    )
                )
            )
        );
        itemMetadata = string(abi.encodePacked(json));
    }

    /**
     * @dev Updates the image and attributes of a user's avatar.
     * @param user_ The address of the user/creator
     * @param tokenURI_ New URI for the avatar's metadata
     * @param avatarAttribute_ New attributes for the avatar
     */
    function updateUserAvatarImage(address user_, string memory tokenURI_, string memory avatarAttribute_)
        public
        onlyController
    {
        uint256 _tokenId = userMintedToekn[user_];
        _setTokenURI(_tokenId, tokenURI_);
        avatarAttributes[user_] = avatarAttribute_;
    }

    function transfer(address from_, address to_, uint256 tokenId_) public override onlyController {
        userMintedToekn[to_] = tokenId_;
        delete userMintedToekn[from_];
        super.transfer(from_, to_, tokenId_);
    }
}
