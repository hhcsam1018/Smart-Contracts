// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// 發送ETH
// transfer
// send
// call

error SendFailed(); 
error CallFailed(); 

contract SendETH {
    // payable使得部署的時候可以轉eth進去
    constructor() payable{}
    // receive方法，接收eth時被觸發
    receive() external payable{}

    // transfer()發送ETH
    function transferETH(address payable _to, uint256 amount) external payable{
        _to.transfer(amount);
    }

    // send()發送ETH
    function sendETH(address payable _to, uint256 amount) external payable{
        bool success = _to.send(amount);
        if(!success){
            revert SendFailed();
        }
    }

    // call()發送ETH
    function callETH(address payable _to, uint256 amount) external payable{
        (bool success,) = _to.call{value: amount}("");
        if(!success){
            revert CallFailed();
        }
    }
}

contract ReceiveETH {
    // 收到eth事件，記錄amount和gas
    event Log(uint amount, uint gas);

    // receive方法，接收eth時被觸發
    receive() external payable{
        emit Log(msg.value, gasleft());
    }
    
    // 返回ETH餘額
    function getBalance() view public returns(uint) {
        return address(this).balance;
    }
}