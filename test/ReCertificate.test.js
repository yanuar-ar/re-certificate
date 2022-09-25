const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('re:certificate Testing', async () => {
  let reCertificate;
  let owner;
  let nonOwner;

  let domain = {
    name: 'RECERTIFICATE',
    version: '1',
    chainId: 31337,
    verifyingContract: '',
  };

  let types = {
    VerifyCertificate: [
      { name: 'tokenId', type: 'uint256' },
      { name: 'pin', type: 'string' },
    ],
  };

  before(async () => {
    [owner] = await ethers.getSigners();
    const ReCertificate = await ethers.getContractFactory('ReCertificate');
    reCertificate = await ReCertificate.deploy(owner.address);

    domain.verifyingContract = reCertificate.address;
  });

  describe('Deployment', async () => {
    it('should deployed', async function () {
      expect(reCertificate.address).to.not.equal('');
    });
  });

  describe('Testing ERC1155 functionality', async () => {
    it('should set contract URI', async () => {
      await reCertificate.setBaseURI('ipfs://qm6yUiaiak');

      expect(await reCertificate.baseTokenURI()).to.eq('ipfs://qm6yUiaiak');
    });
  });

  describe('Testing Mint & Verify function', async () => {
    it('should mint', async () => {
      await reCertificate.mint(owner.address, 1);

      expect(await reCertificate.balanceOf(owner.address)).to.eq(ethers.BigNumber.from(1));
    });

    it('should verified', async () => {
      const tokenId = 1;
      const pin = '123abc';
      const signature = await owner._signTypedData(domain, types, {
        tokenId: tokenId,
        pin: pin,
      });

      expect(await reCertificate.verifyCertificate(tokenId, pin, signature)).not.to.be.reverted;
    });
  });
});
