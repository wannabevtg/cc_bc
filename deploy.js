const hre = require("hardhat");

async function main() {

  const LandTransferSystem = await hre.ethers.getContractFactory("LandTransferSystem");
  
  
  const contract = await LandTransferSystem.deploy();
  console.log("Deployment transaction hash:", contract.deploymentTransaction().hash);
  
 
  await contract.waitForDeployment();
  
  const deployedAddress = await contract.getAddress();
  console.log("Deployed to:", deployedAddress);
  
  return deployedAddress; // Useful for verification
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
