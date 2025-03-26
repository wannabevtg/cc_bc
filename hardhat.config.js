require("@nomicfoundation/hardhat-ethers");
require("dotenv").config();

const SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

module.exports = {
  solidity: "0.8.28",
  networks: {
    sepolia: {
      url: SEPOLIA_RPC_URL,
      accounts: [PRIVATE_KEY]
    },
    localhost: {
      url: "http://127.0.0.1:8545",
      chainId: 31337
    }
  }
  };
