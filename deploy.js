const hre = require("hardhat");

async function main() {
  // 1. Get the contract factory
  const LandTransferSystem = await hre.ethers.getContractFactory("LandTransferSystem");
  
  // 2. Deploy the contract
  const contract = await LandTransferSystem.deploy();
  console.log("Deployment transaction hash:", contract.deploymentTransaction().hash);
  
  // 3. Wait for deployment confirmation
  await contract.waitForDeployment();
  
  // 4. Get the final deployed address
  const deployedAddress = await contract.getAddress();
  console.log("Deployed to:", deployedAddress);
  
  return deployedAddress; // Useful for verification
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});