import { ethers } from 'hardhat';
import { CORECONTROLLER, AVATAR, ARCAVETOKEN } from './constants';

async function main() {

    const corecontroller = await ethers.getContractAt('CoreController', CORECONTROLLER);

    const tx = await corecontroller.setAvatarContract(AVATAR);
    await tx.wait();
    const tx1 = await corecontroller.setArcaveTokenContract(ARCAVETOKEN);
    await tx1.wait();

    const corecontroller = await ethers.getContractAt('CoreController', CORECONTROLLER);

    // const tx = await corecontroller.fetchUserMetadata('user');
    // console.log(tx);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
