    // SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "src/interface/IAvatar.sol";
import "src/interface/ICoreController.sol";
import "src/marketplace/Items.sol";
import "src/token/ArcaveToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title CoreController
 * @dev Contract for managing avatars, items, and arcave token
 */

contract CoreController is ICoreController, Ownable {
    using Strings for string;
    /**
     * ========================================================= *
     *                   Storage Declarations                    *
     * ========================================================= *
     */

    uint256 private constant MAX_INT = 2 ** 256 - 1; // Maximum possible value for uint256
    address public avatarContract;
    address public arcaveTokenContract;
    uint256 public totalItems; // Total number of items created

    struct ItemOnMarketplace {
        bool listing; // Indicates if the item is listed on the marketplace
        uint256 price; // Price of the item
        uint256 totalSupply; // Total supply of the item
        uint256 totalSold; // Total items sold
        address itemAddress; // Address of the item contract
        address creator; // Address of the creator
        string itemURI; // URI of the item
        string itemName; // Name of the item
    }

    mapping(uint256 => ItemOnMarketplace) public itemNumToItem; // Mapping of item number to item details
    mapping(address => address[]) public creatorToItemAddresses; // Mapping of creator address to their item addresses
    mapping(address => bool) public alreadyAvatarMinted;
    mapping(address => UserInfo) public userUserInfo;
    mapping(address => mapping(address => uint256)) public userItemAddressToItemId;

    modifier isItemExists(string memory name_, string memory itemURI_) {
        // Check if an item with the same name or URI already exists
        for (uint256 i = 1; i <= totalItems;) {
            require(!name_.equal(itemNumToItem[i].itemName), "Item exists");
            require(!itemURI_.equal(itemNumToItem[i].itemURI), "Item exists");
            unchecked {
                ++i;
            }
        }
        _;
    }

    /**
     * ========================================================= *
     *                      Public Function                      *
     * ========================================================= *
     */

    /**
     * @dev Creates an avatar for the specified owner
     * @param owner_ The address of the owner
     * @param avatarURI_ The URI for the avatar token
     * @param description_ The description of the avatar
     */
    function createAvatar(
        address owner_,
        string memory avatarURI_,
        string memory description_,
        string memory userAttributes_
    ) public {
        if (owner_ == address(0)) revert InvalidOwnerAddress();
        if (bytes(avatarURI_).length == 0) revert EmptyTokenURI();
        if (bytes(description_).length == 0) revert EmptyDescription();
        if (alreadyAvatarMinted[owner_]) revert AvatarAlreadyMinted();

        alreadyAvatarMinted[owner_] = true;
        IAvatar(avatarContract).createAvatar(owner_, avatarURI_, description_, userAttributes_);
        emit AvatarCreated(owner_, avatarURI_, description_);
    }

    /**
     * @dev Creates an item for the specified owner
     * @param user_ The address of the owner
     * @param totalSupply_ The total supply of the item
     * @param name_ The URI for the item token
     * @param symbol_ The URI for the item token
     * @param itemURI_ The URI for the item token
     * @param description_ The description of the item
     */
    function createItem(
        address user_,
        uint256 totalSupply_,
        string memory name_,
        string memory symbol_,
        string memory itemURI_,
        string memory description_
    ) public isItemExists(name_, itemURI_) {
        totalItems += 1;
        uint256 newItemNum = totalItems;

        Item item = new Item(name_, symbol_, address(this));
        item.batchMint(address(this), totalSupply_, itemURI_, description_);

        ItemOnMarketplace memory tmp = ItemOnMarketplace({
            listing: false,
            price: MAX_INT,
            totalSupply: totalSupply_,
            totalSold: 0,
            creator: user_,
            itemAddress: address(item),
            itemURI: itemURI_,
            itemName: name_
        });

        creatorToItemAddresses[msg.sender].push(address(item));
        itemNumToItem[newItemNum] = tmp;

        emit ItemCreated(user_, totalSupply_, itemURI_, description_);
    }

    /**
     * @dev Lists the item on marketplace
     * @param itemNum_ The token number of the item
     * @param price_ The price of the item
     */
    function listOnMarketplace(uint256 itemNum_, uint256 price_) public {
        ItemOnMarketplace storage itemStruct = itemNumToItem[itemNum_];
        require(itemStruct.creator == msg.sender, "Only owner can list the token on marketplace");
        itemStruct.listing = true;
        itemStruct.price = price_;
    }

    /**
     * @dev Removes the item from marketplace
     * @param itemNum_ The token number of the item
     */
    function removeFromMarketplace(uint256 itemNum_) public {
        ItemOnMarketplace storage itemStruct = itemNumToItem[itemNum_];
        require(itemStruct.creator == msg.sender, "Only owner can remove the token from marketplace");
        itemStruct.listing = false;
        itemStruct.price = MAX_INT;
    }

    /**
     * @dev Purchase the item from marketplace
     * @param itemNum_ The token number of the item
     */
    function purchaseItem(uint256 itemNum_) public payable {
        ItemOnMarketplace storage itemStruct = itemNumToItem[itemNum_];
        require(itemStruct.listing, "The token is not listed");
        require(msg.value == itemStruct.price, "The price is not correct");

        uint256 tokenId_ = itemStruct.totalSold + 1;

        // Transfer the token
        IItem(itemStruct.itemAddress).transferFrom(address(this), msg.sender, tokenId_);
        userItemAddressToItemId[msg.sender][itemStruct.itemAddress] = tokenId_;
        // Update marketplace to remove the listing
        itemStruct.totalSold += 1;

        // Handling the case when all tokens are sold.
        if (itemStruct.totalSold == itemStruct.totalSupply) {
            itemStruct.listing = false;
            itemStruct.price = MAX_INT;
        }
        emit ItemSold(itemNum_, tokenId_);
    }

    function updateUserItemtokenURI(address user_, address itemContract_, uint256 tokenId_, string memory itemURI_) public {
        IItem itemContract = IItem(itemContract_);
        require(itemContract.ownerOf(tokenId_) == user_, "User does not own the token");
        itemContract.updateTokenURI(tokenId_, itemURI_);
    }

    function updateUserAvatarImage(string memory avatarURI_, string memory avatarAttribute_) public {
        require(alreadyAvatarMinted[msg.sender], "Avatar does not exists");
        IAvatar(avatarContract).updateUserAvatarImage(msg.sender, avatarURI_, avatarAttribute_);
    }

    /**
     * @dev Mints tokens for the specified owner
     * @param owner_ The address of the owner
     * @param amount_ The total supply of the tokens
     * @param name_ The name of the tokens
     * @param symbol_ The symbol of the tokens
     */
    function mint(address owner_, uint256 amount_, string memory name_, string memory symbol_) public onlyOwner {
        if (owner_ == address(0)) revert InvalidOwnerAddress();
        if (amount_ == 0) revert InvalidTotalSupply();
        if (bytes(name_).length == 0) revert EmptyName();
        if (bytes(symbol_).length == 0) revert EmptySymbol();

        ArcaveToken(arcaveTokenContract).mint(owner_, amount_);
        emit TokensMinted(owner_, amount_, name_, symbol_);
    }

    /**
     * @dev Burns tokens for the specified owner
     * @param owner_ The address of the owner
     * @param amount_ The total supply of the tokens
     * @param name_ The name of the tokens
     * @param symbol_ The symbol of the tokens
     */
    function burn(address owner_, uint256 amount_, string memory name_, string memory symbol_) public onlyOwner {
        if (owner_ == address(0)) revert InvalidOwnerAddress();
        if (amount_ == 0) revert InvalidTotalSupply();
        if (bytes(name_).length == 0) revert EmptyName();
        if (bytes(symbol_).length == 0) revert EmptySymbol();

        ArcaveToken(arcaveTokenContract).burn(owner_, amount_);
        emit TokensBurned(owner_, amount_, name_, symbol_);
    }

    /**
     * @dev Sets the friends for the specified user
     * @param user_ The address of the user
     * @param friends The array of user's friends
     */
    function setUserFriends(address user_, address[] memory friends) public {
        uint256 friendsLength = friends.length;
        require(friendsLength <= 4, "Maximum 4 friends allowed");
        for(uint256 i = 0; i < friendsLength; i++) {
            userUserInfo[user_].friends[i] = friends[i];
        }
    }

    /**
     * @dev Fetches metadata for the specified user
     * @param user_ The address of the user
     */
    function fetchUserMetadata(address user_)
        public
        view
        returns (string memory avatarMetadata, string[] memory itemMetadata, uint256 maxScore, address[4] memory friends, UserInfo memory userInfo)
    {
        avatarMetadata = IAvatar(avatarContract).fetchUserAvatar(user_);
        address[] memory itemAddresses = creatorToItemAddresses[user_];
        uint256 itemAddressesLength = itemAddresses.length;
        itemMetadata = new string[](itemAddressesLength);

        for (uint256 i = 0; i < itemAddressesLength; i++) {
            Item _item = Item(itemAddresses[i]);
            uint256 tokenId = userItemAddressToItemId[user_][itemAddresses[i]];
            string memory json = _item.fetchUserItems(tokenId);
            itemMetadata[i] = json;
        }
        userInfo = userUserInfo[user_];
    }

    function setAvatarContract(address avatarContract_) public onlyOwner {
        avatarContract = avatarContract_;
    }

    function setArcaveTokenContract(address arcaveTokenContract_) public onlyOwner {
        arcaveTokenContract = arcaveTokenContract_;
    }

    function setUserInfo(address user_, uint256 x_, uint256 y_, uint256 z_, uint256 userMaxScore_) public {
        UserInfo memory tmp = UserInfo({x: x_, y: y_, z: z_, userMaxScore: userMaxScore_, friends: [address(0), address(0), address(0), address(0)]});
        userUserInfo[user_] = tmp;
    }
}
