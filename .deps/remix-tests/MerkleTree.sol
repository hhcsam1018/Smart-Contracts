// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./bayc/ERC721.sol";


/**
* 利用Merkle樹樹驗證白名單（生成Merkle樹的網頁：https://lab.miguelmota.com/merkletreejs/example/）
 * 選上Keccak-256, hashLeaves和sortPairs選項
 * 4個葉子地址：
    [
    "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", 
    "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
    "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db",
    "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB"
    ]
 * 第一個地址對應的merkle proof
    [
    "0x999bf57501565dbd2fdcea36efa2b9aef8340a8901e3459f4a4c926275d36cdb",
    "0x4726e4102af77216b09ccd94f40daa10531c87c4d60bba7f3b3faf5ff9f19b3c"
    ]
 * Merkle root: 0xeeefd63003e0e702cb41cd0043015a6e26ddb38073cc6ffeb0ba3e808ba8c097
 */


/**
 * @dev 驗證Merkle樹的合約.
 *
 * proof可以用JavaScript庫生成：
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * 注意: hash用keccak256，並且開啟pair sorting （排序）.
 * javascript例子見 `https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/test/utils/cryptography/MerkleProof.test.js`.
 */

library MerkleProof {
    /**
     * @dev 當通過`proof`和`leaf`重建出的`root`與給定的`root`相等時，返回`true`，數據有效。
     * 在重建時，葉子節點對和元素對都是排序過的。
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns 通過Merkle樹用`leaf`和`proof`計算出`root`. 當重建出的`root`和給定的`root`相同時，`proof`才是有效的。
     * 在重建時，葉子節點對和元素對都是排序過的。
     */

    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    // Sorted Pair Hash
    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? keccak256(abi.encodePacked(a, b)) : keccak256(abi.encodePacked(b, a));
    }
}

contract MerkleTree is ERC721 {
    bytes32 immutable public root; // Merkle的根
    mapping(address => bool) public mintedAddress;   //記錄已經mint的地址

    // 構造函數，初始化NFT合集的名稱、代號、Merkle樹的根
    constructor(string memory name, string memory symbol, bytes32 merkleroot)
    ERC721(name, symbol)
    {
        root = merkleroot;
    }

    // 利用Merkle驗證地址並mint
    function mint(address account, uint256 tokenId, bytes32[] calldata proof)
    external
    {
        require(_verify(_leaf(account), proof), "Invalid merkle proof"); // Merkle檢驗通過
        require(!mintedAddress[account], "Already minted!"); // 地址沒有mint過
        
        mintedAddress[account] = true; // 記錄mint過的地址
        _mint(account, tokenId); // mint
    }

    // 計算Merkle葉子的哈希值
    function _leaf(address account)
    internal pure returns (bytes32)
    {
        return keccak256(abi.encodePacked(account));
    }

    // Merkle樹驗證，調用MerkleProof庫的verify()函數
    function _verify(bytes32 leaf, bytes32[] memory proof)
    internal view returns (bool)
    {
        return MerkleProof.verify(proof, root, leaf);
    }
}