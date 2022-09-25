const { task } = require('hardhat/config');

task('deploy', 'Deploy contract').setAction(async ({}, { ethers, upgrades }) => {
  const ReCertificate = await ethers.getContractFactory('ReCertificate');

  const reCertificate = await ReCertificate.deploy('', { gasLimit: 3000000 });

  await reCertificate.deployed('');

  console.log('Contract deployed to: ', reCertificate.address);
});
