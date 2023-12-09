import { ethers } from 'hardhat';
import { CORECONTROLLER } from './constants';
import dotenv from 'dotenv';

dotenv.config(); // Load environment variables from .env file

async function main() {
    const Avatar = await ethers.getContractFactory('Avatar');
    const avatar = await Avatar.deploy(CORECONTROLLER, 'Arborg', 'ARB');

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

// The avatar contract address is 0x528d6412374BECa780677c3806FF9A91a131Ab10