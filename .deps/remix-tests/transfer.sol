// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    //event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
    //function allowance(address owner, address spender) external view returns (uint256);
    
    //function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    //function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract ERC20 is IERC20{
    uint256 _totalSupply;
    mapping(address=>uint256) _balance;

    //自己10000顆，總發行量10000顆
    constructor(){
        _balance[msg.sender]=10000;
        _totalSupply=10000;
    }

    function totalSupply() public  view returns (uint256){
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256){
        return _balance[account];
    }

    function transfer(address to, uint256 amount) external returns (bool){
        uint256 mybalance=_balance[msg.sender];
        require(mybalance>=amount,"No money to transfer");
        require(to!=address(0),"Tranfer to address 0 ");
        _balance[msg.sender]=mybalance-amount;
        _balance[to]=_balance[to]+amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

}