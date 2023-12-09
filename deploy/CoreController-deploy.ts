import { ethers } from 'hardhat';
import dotenv from 'dotenv';

dotenv.config(); // Load environment variables from .env file

async function main() {
    const CoreController = await ethers.getContractFactory('CoreController');
    const corecontroller = await CoreController.deploy();

    await corecontroller.deployed();
    console.log(
        `The corecontroller contract address is ${corecontroller.address}`
      );
    return;
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

// The corecontroller contract address is 0xd34Dfde3EaBFAa64fD60944b045003F2B9632D70