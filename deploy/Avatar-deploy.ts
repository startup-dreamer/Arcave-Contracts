import { ethers } from 'hardhat';
import dotenv from 'dotenv';

dotenv.config(); // Load environment variables from .env file

async function main() {
    const Avatar = await ethers.getContractFactory('Avatar');
    const avatar = await Avatar.deploy('0xe5b5cF4E9a6ADfe3287647184b44c15Ff5E7E4ab');

    await avatar.deployed();
    console.log(
        `The avatar contract address is ${avatar.address}`
      );
    return;
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

