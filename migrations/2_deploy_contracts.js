var Splitter = artifacts.require("./Splitter.sol");

module.exports = function(deployer) {
  deployer.deploy(
      Splitter,
      "0x51030097f30621e59a1792579babfc8848e36da3",
      "0xcf4a36a183783438bece2985b921e8f544265992",
      "0x1b7bd0b069309cae8aff3b382cc356432d6c96f6"
  );
};
