// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IAvatar {
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
    ) external;

    /**
     * @dev Fetches metadata for user avatar for a specific user
     * @param user_ The address of the user/creator
     * @return itemMetadata An array of JSON strings representing the metadata of the items
     */
    function fetchUserAvatar(address user_) external view returns (string memory itemMetadata);

    /**
     * @dev Updates the image and attributes of a user's avatar.
     * @param user_ The address of the user/creator
     * @param tokenURI_ New URI for the avatar's metadata
     * @param avatarAttribute_ New attributes for the avatar
     */
    function updateUserAvatarImage(address user_, string memory tokenURI_, string memory avatarAttribute_) external;
}
