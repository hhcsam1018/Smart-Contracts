// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface IERC20 {
    //event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    //function totalSupply() external view returns (uint256);

    //function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    
    function approve(address spender, uint256 amount) external returns (bool);
    //function transfer(address to, uint256 amount) external returns (bool);
    //function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract ERC20 is IERC20{
    mapping(address=>mapping(address=>uint256)) _allowance;
    function allowance(address owner, address spender) public view returns (uint256){
        return _allowance[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool){
        _allowance[msg.sender][spender]=amount;
        emit Approval(msg.sender,spender,amount);
        return true;
    }

    
    
}