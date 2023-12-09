import { ethers } from 'hardhat';
import { CORECONTROLLER } from './constants';
import dotenv from 'dotenv';

dotenv.config(); // Load environment variables from .env file

async function main() {
    const ArcaveToken = await ethers.getContractFactory('ArcaveToken');
    const arcavetoken = await ArcaveToken.deploy(CORECONTROLLER, 'ArcaveToken', 'ARCA');

    await arcavetoken.deployed();
    console.log(
        `The arcavetoken contract address is ${arcavetoken.address}`
      );
    return;
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// The arcavetoken contract address is 0x8f195dc95de229966E3B201Faac756505d080C69