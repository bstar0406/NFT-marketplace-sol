require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
const mnemonic = "";
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.10",
  settings: {
    optimizer: {
      enabled: true,
      runs: 2000,
    },
  },

  defaultNetwork: "rinkeby",
  networks: {
    // development: {
    //  host: "127.0.0.1",     // Localhost (default: none)
    //  port: 8545,            // Standard Ethereum port (default: none)
    //  network_id: "*",       // Any network (default: none)
    // },
    localhost: {
      url: "http://127.0.0.1:7545",
      network_id: "5777"
    },
    hardhat: {
    },
    rinkeby: {
      url: "https://eth-rinkeby.alchemyapi.io/v2/GF_x59vnWpBGjxHj08nYisJexwrpO0h3",
      chainId: 4,
      gasPrice: 20000000000,
      accounts: ["bb09a86d4e497cf5d124236743cdb3cd387653a62c8f730aafad237b68794e0e"]
    },
    testnet: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      chainId: 97,
      gasPrice: 20000000000,
      accounts: ["bb09a86d4e497cf5d124236743cdb3cd387653a62c8f730aafad237b68794e0e"]
    },
    ethereummainnet: {
      url: "https://eth-mainnet.alchemyapi.io/v2/ceCjUJUuptARchZNQRB-8Fv-9dMXf4ni/",
      chainId: 1,
      gasPrice: 20000000000,
      accounts: {mnemonic: mnemonic}
    },
    bscmainnet: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56,
      gasPrice: 10000000000,
      accounts:  ["bb09a86d4e497cf5d124236743cdb3cd387653a62c8f730aafad237b68794e0e"]
    }
  },
  etherscan: {
    apiKey: "VH2CKUS6SV7VSCR2TFR5YU5PJPU33TQS1X", // Etherscan
    //apiKey: "MX8MMZN3GCIAP9J33GVDI7F8PCPUBKVA3C",   //bsc
  },
  bscscan:{
    apiKey: "MX8MMZN3GCIAP9J33GVDI7F8PCPUBKVA3C",
  }
};
