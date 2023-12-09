import { ethers } from 'hardhat';
import dotenv from 'dotenv';

dotenv.config(); // Load environment variables from .env file

async function main() {
    const Avatar = await ethers.getContractFactory('Avatar');
    const avatar = await Avatar.deploy('0xAe5B5512AaE8E03E48421BA944Ce0Aa9E514633E', 'Arborg', 'ARB');

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

// The avatar contract address is 0x23816d996ac25B8eB130E713b79DD409db4A5944