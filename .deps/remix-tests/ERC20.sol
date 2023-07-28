// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract ERC20 is IERC20{

    //transfer
    uint256 _totalSupply;
    mapping(address=>uint256) _balance;
    string _name;
    string _symbol;
    address _owner;

    modifier onlyOwner() {
        require(_owner == msg.sender, "ERROR: only owner can access this function");
        _;
    }

    function mint(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "ERROR: mint to address 0");
        _totalSupply += amount;
        _balance[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function burn(address account, uint256 amount) public onlyOwner {
        require(account != address(0), "ERROR: burn from address 0");
        uint256 accountBalance = _balance[account];
        require(accountBalance >= amount, "ERROR: no more token to burn");
        _balance[account] = accountBalance - amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }


    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return 18;
    }

    //自己10000顆，總發行量10000顆
    constructor(string memory name_,string memory symbol_){
        _name=name_;
        _symbol=symbol_;
        _owner=msg.sender;
        _balance[msg.sender]=10000;
        _totalSupply=10000;
    }

    function totalSupply() public  view returns (uint256){
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256){
        return _balance[account];
    }

    function _transfer(address from, address to, uint256 amount) internal {
        uint256 myBalance = _balance[from];
        require(myBalance >= amount, "No money to transfer");
        require(to != address(0), "Transfer to address 0");

        _balance[from] = myBalance - amount;
        _balance[to] = _balance[to] + amount;
        emit Transfer(from, to, amount);
    }

    function transfer(address to, uint256 amount) public returns (bool){
        _transfer(msg.sender,to,amount);
        return true;
    }

    //授權
    mapping(address=>mapping(address=>uint256)) _allowance;
    function allowance(address owner, address spender) public view returns (uint256){
        return _allowance[owner][spender];
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        _allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function approve(address spender, uint256 amount) public returns (bool){
        _approve(msg.sender,spender,amount);
        return true;
    }
    
    function transferFrom(address from, address to, uint256 amount) external returns (bool){
        uint256 myallowance=_allowance[from][msg.sender];
        require(myallowance>=amount,"ERROR:myallowannce < amount");
        _approve(from,msg.sender,myallowance-amount);
        _transfer(from,to,amount);
        return true;
    }

}