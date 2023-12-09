import fs from "fs";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-preprocessor";
import "@nomiclabs/hardhat-etherscan";
import dotenv from 'dotenv';
import { HardhatUserConfig, task } from "hardhat/config";

dotenv.config();


function getRemappings() {
  return fs
    .readFileSync("remappings.txt", "utf8")
    .split("\n")
    .filter(Boolean)
    .map((line) => line.trim().split("="));
}

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    hardhat: {
      forking: {
        url: `https://mainnet.infura.io/v3/${
          process.env.API_KEY ? process.env.API_KEY : ''
        }`,
        blockNumber: 14390000,
      },
      accounts: {
        count: 50,
      },
    },
    mantle: {
      url: "https://rpc.mantle.xyz", //mainnet
      accounts: process.env.DEPLOYMENT_PRIVATE_KEY
        ? [process.env.DEPLOYMENT_PRIVATE_KEY]
        : [],
    },
    mantleTest: {
      url: "https://rpc.ankr.com/mantle_testnet", // Replace with the actual URL of the sepoli network
      accounts: process.env.DEPLOYMENT_PRIVATE_KEY
        ? [process.env.DEPLOYMENT_PRIVATE_KEY]
        : [],
    },
    sepolia: {
      url: `https://sepolia.infura.io/v3/${
        process.env.API_KEY ? process.env.API_KEY : ''
      }`, // Replace with the actual URL of the sepoli network
      accounts: process.env.DEPLOYMENT_PRIVATE_KEY
        ? [process.env.DEPLOYMENT_PRIVATE_KEY]
        : [],
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${
        process.env.API_KEY ? process.env.API_KEY : ''
      }`, // Replace with the actual URL of the goerli network
      accounts: process.env.DEPLOYMENT_PRIVATE_KEY
        ? [process.env.DEPLOYMENT_PRIVATE_KEY]
        : [],
    },
    mumbai: {
      url: 'https://rpc.ankr.com/polygon_mumbai',
      accounts: process.env.DEPLOYMENT_PRIVATE_KEY
        ? [process.env.DEPLOYMENT_PRIVATE_KEY]
        : [],
    },
    polygon: {
      url: 'https://rpc-mainnet.maticvigil.com',
      accounts: process.env.DEPLOYMENT_PRIVATE_KEY
        ? [process.env.DEPLOYMENT_PRIVATE_KEY]
        : [],
    },
  },
  paths: {
    sources: "./src", // Use ./src rather than ./contracts as Hardhat expects
    cache: "./cache_hardhat", // Use a different cache for Hardhat than Foundry
  },
  // This fully resolves paths for imports in the ./lib directory for Hardhat
  preprocess: {
    eachLine: (hre) => ({
      transform: (line: string) => {
        if (line.match(/^\s*import /i)) {
          getRemappings().forEach(([find, replace]) => {
            if (line.match(find)) {
              line = line.replace(find, replace);
            }
          });
        }
        return line;
      },
    }),
  },
  etherscan: {
    apiKey: process.env.API_KEY,
    customChains: [
        {
            network: "mantleTest",
            chainId: 5001,
            urls: {
            apiURL: "https://testnet.mantlescan.org/DXAJD7RXBKZIGXE9XIIH6Z9WYPPW26CEG7",
            browserURL: "https://testnet.mantlescan.org/"
            }
        }
    ]
},
};

export default config;
