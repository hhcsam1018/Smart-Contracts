// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract Owner {
   address public owner; 

   constructor() {
      owner = msg.sender; // 部署合約的时候，將owner設為部署者的地址
   }

   // modifier
   modifier onlyOwner {
      require(msg.sender == owner); // 檢查調用者是否為owner地址
      _; // 如果是的话，繼續執行；否則報錯並revert交易
   }

   // 定義带onlyOwner修飾的函数
   function changeOwner(address _newOwner) external onlyOwner{
      owner = _newOwner; // 只有owner地址執行这个函数，並改變owner
   }
}
