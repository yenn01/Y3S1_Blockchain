var DeX = artifacts.require("DeX");

module.exports = function(deployer) {
  // Deploy the SolidityContract contract as our only task
  // deployment steps
  deployer.deploy(DeX);
};