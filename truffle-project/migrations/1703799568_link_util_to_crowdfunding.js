const Utils = artifacts.require("./Utils");
const Crowdfunding = artifacts.require("./Crowdfunding");

module.exports = async function(_deployer) {
  await _deployer.deploy(Utils);
  _deployer.link(Utils, Crowdfunding);
};