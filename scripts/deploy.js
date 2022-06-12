const { ethers } = require("hardhat")

async function main() {

  const Test = await ethers.getContractFactory("IslandGirlStaking");
  const test = await Test.deploy('0xD4F37084dDe5d08a152b89f18d172473509DFd75', 10, 25, 40, 70, 90);

  await test.deployed();

  console.log("AIRDROP Address: ", test.address);

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
