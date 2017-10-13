var CashPokerProICO = artifacts.require("CashPokerProICO.sol");
var CashPokerProToken = artifacts.require("CashPokerProToken.sol");

module.exports = function(deployer) {
  deployer.deploy(CashPokerProICO);
  deployer.deploy(CashPokerProToken);
};
