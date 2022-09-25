// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/cryptography/draft-EIP712.sol';

contract ReCertificate is ERC721, ERC721Enumerable, EIP712, Pausable, Ownable {
    using ECDSA for bytes32;

    string public baseTokenURI = '';

    // signer address
    address public signer;

    constructor(address _signer) ERC721('re:certificate', 'RCT') EIP712('RECERTIFICATE', '1') {
        signer = _signer;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 tokenId) public whenNotPaused onlyOwner {
        _safeMint(to, tokenId);
    }

    // token URI
    function setBaseURI(string calldata _baseTokenURI) external onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), 'Token does not exists !');
        return bytes(baseTokenURI).length > 0 ? string(abi.encodePacked(baseTokenURI, Strings.toString(tokenId))) : '';
    }

    function verifyCertificate(
        uint256 tokenId,
        string calldata pin,
        bytes calldata _signature
    ) public payable whenNotPaused returns (bool) {
        // validate signature
        require(_exists(tokenId), 'Token does not exists !');
        require(signer == _verify(tokenId, pin, _signature), 'Invalid signature');

        return true;
    }

    function _verify(
        uint256 tokenId,
        string calldata pin,
        bytes calldata signature
    ) internal view returns (address) {
        bytes32 TYPEHASH = keccak256('VerifyCertificate(uint256 tokenId,string pin)');
        bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(TYPEHASH, tokenId, pin)));
        return ECDSA.recover(digest, signature);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
