const Migrations = artifacts.require("./Migrations");

module.exports = async function(_deployer) {
  await _deployer.deploy(Migrations);
};
