const Migrations = artifacts.require("Auction");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
};