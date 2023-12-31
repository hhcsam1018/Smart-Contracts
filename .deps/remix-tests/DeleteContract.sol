// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract DeleteContract {

    uint public value = 10;

    constructor() payable {}

    receive() external payable {}

    function deleteContract() external {
        // 調用selfdestruct銷毀合約，並把剩餘的ETH轉給msg.sender
        selfdestruct(payable(msg.sender));
    }

    function getBalance() external view returns(uint balance){
        balance = address(this).balance;
    }
}