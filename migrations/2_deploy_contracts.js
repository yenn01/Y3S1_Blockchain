var DeX = artifacts.require("DeX");

module.exports = function(deployer) {
  // deployment steps
  deployer.deploy(DeX);
};