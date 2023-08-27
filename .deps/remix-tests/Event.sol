// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract Events {
    // 定義_balances，記錄每個地址的持幣數量
    mapping(address => uint256) public _balances;

    // 定義Transfer event，記錄transfer交易的轉賬地址，接收地址和轉賬數量
    event Transfer(address indexed from, address indexed to, uint256 value);


    // 轉帳
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) external {

        _balances[from] = 10000000; // 給轉賬地址一些初始代幣

        _balances[from] -=  amount; // from地址減去轉賬數量
        _balances[to] += amount; // to地址加上轉賬數量

        // 事件
        emit Transfer(from, to, amount);
    }
}