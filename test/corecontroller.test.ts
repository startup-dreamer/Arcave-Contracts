import { ethers, waffle } from 'hardhat';
import { expect } from 'chai';
import { CoreController } from '../typechain';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { MockProvider } from 'ethereum-waffle';
import { IAvatar, IItem, GameToken } from '../typechain';

const { parseUnits } = ethers.utils;
const { deployContract } = waffle;

describe('CoreController', () => {
  let owner: SignerWithAddress;
  let user: SignerWithAddress;
  let coreController: CoreController;
  let avatarContract: IAvatar;
  let itemContract: IItem;
  let gameContract: GameToken;

  beforeEach(async () => {
    [owner, user] = await ethers.getSigners();

    // Deploy CoreController
    const CoreControllerFactory = await ethers.getContractFactory('CoreController', owner);
    coreController = (await deployContract(owner, CoreControllerFactory, owner.address, 'Avatar', 'AVT')) as CoreController;

    // Deploy Mock contracts for interfaces
    const MockAvatarFactory = await ethers.getContractFactory('MockAvatar');
    avatarContract = (await deployContract(owner, MockAvatarFactory)) as IAvatar;

    const MockItemFactory = await ethers.getContractFactory('MockItem');
    itemContract = (await deployContract(owner, MockItemFactory)) as IItem;

    const MockGameTokenFactory = await ethers.getContractFactory('MockGameToken');
    gameContract = (await deployContract(owner, MockGameTokenFactory)) as GameToken;

    // Set mock contracts in CoreController
    await coreController.setAvatarContract(avatarContract.address);
    await coreController.setItemContract(itemContract.address);
    await coreController.setGameContract(gameContract.address);
  });

  it('should create an avatar for a user', async () => {
    const tokenURI = 'ipfs://123';
    const description = 'My Avatar';

    await coreController.createAvatar(user.address, tokenURI, description);

    const userAvatarMetadata = await avatarContract.fetchUserAvatar(user.address);
    expect(userAvatarMetadata).to.include(tokenURI);
    expect(userAvatarMetadata).to.include(description);
  });

  it('should create an item for a user', async () => {
    const totalSupply = 100;
    const tokenURI = 'ipfs://456';
    const description = 'My Item';

    await coreController.createItem(user.address, totalSupply, tokenURI, description);

    const userItemMetadata = await itemContract.fetchUserItems(user.address);
    expect(userItemMetadata).to.include(tokenURI);
    expect(userItemMetadata).to.include(description);
  });

  it('should mint tokens for a user', async () => {
    const totalSupply = 100;
    const name = 'MyToken';
    const symbol = 'MT';

    await coreController.mint(user.address, totalSupply, name, symbol);

    const userBalance = await gameContract.balanceOf(user.address);
    expect(userBalance).to.equal(totalSupply);
  });

  it('should burn tokens for a user', async () => {
    const totalSupply = 100;
    const name = 'MyToken';
    const symbol = 'MT';

    await coreController.mint(user.address, totalSupply, name, symbol);

    const initialBalance = await gameContract.balanceOf(user.address);

    await coreController.burn(user.address, totalSupply, name, symbol);

    const finalBalance = await gameContract.balanceOf(user.address);
    expect(finalBalance).to.equal(0);
  });

  it('should set the maximum score for a user', async () => {
    const maxScore = 1000;

    await coreController.setMaxScore(user.address, maxScore);

    const userMaxScore = await coreController.userMaxScore(user.address);
    expect(userMaxScore).to.equal(maxScore);
  });

  it('should set friends for a user', async () => {
    const friends = [ethers.utils.getAddress('0x1'), ethers.utils.getAddress('0x2'), ethers.utils.getAddress('0x3'), ethers.utils.getAddress('0x4')];

    await coreController.setUserFriends(user.address, friends);

    const userFriends = await coreController.userFriends(user.address);
    expect(userFriends).to.deep.equal(friends);
  });

  it('should fetch metadata for a user', async () => {
    const tokenURI = 'ipfs://789';
    const description = 'My Avatar';
    const totalSupply = 100;
    const itemName = 'MyItem';
    const itemSymbol = 'MI';
    const maxScore = 1000;
    const friends = [ethers.utils.getAddress('0x1'), ethers.utils.getAddress('0x2'), ethers.utils.getAddress('0x3'), ethers.utils.getAddress('0x4')];

    await coreController.createAvatar(user.address, tokenURI, description);
    await coreController.createItem(user.address, totalSupply, tokenURI, description);
    await coreController.mint(user.address, totalSupply, itemName, itemSymbol);
    await coreController.setMaxScore(user.address, maxScore);
    await coreController.setUserFriends(user.address, friends);

    const [avatarMetadata, itemMetadata, fetchedMaxScore, fetchedFriends] = await coreController.fetchUserMetadata(user.address);

    expect(avatarMetadata).to.include(tokenURI);
    expect(avatarMetadata).to.include(description);

    expect(itemMetadata).to.include(tokenURI);
    expect(itemMetadata).to.include(description);

    expect(fetchedMaxScore).to.equal(maxScore);
    expect(fetchedFriends).to.deep.equal(friends);
  });
});

