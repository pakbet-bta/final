const PakbetUseCase = artifacts.require("PakbetUseCase");

module.exports = function(deployer) {
  deployer.deploy(PakbetUseCase);
};
