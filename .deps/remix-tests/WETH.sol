// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20{
    // 事件：存款和取款
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);

    // 初始化ERC20的名字
    constructor() ERC20("WETH", "WETH"){
    }

    //回調函數，當用戶往WETH合約轉ETH時，會觸發deposit()函數
    fallback() external payable {
        deposit();
    }
   
    receive() external payable {
        deposit();
    }

    // 存款函數，當用戶存入ETH時，給他鑄造等量的WETH
    function deposit() public payable {
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    // 提款函數，用戶銷毀WETH，取回等量的ETH
    function withdraw(uint amount) public {
        require(balanceOf(msg.sender) >= amount);
        _burn(msg.sender, amount);
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }
}