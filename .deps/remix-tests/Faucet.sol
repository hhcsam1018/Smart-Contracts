// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

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

contract ERC20 is IERC20 {

    mapping(address => uint256) public override balanceOf;

    mapping(address => mapping(address => uint256)) public override allowance;

    uint256 public override totalSupply;   // 代幣總供給

    string public name;  
    string public symbol; 
    
    uint8 public decimals = 18; 

    // 在合約部署的時候實現合約名稱和符號
    constructor(string memory name_, string memory symbol_){
        name = name_;
        symbol = symbol_;
    }

    function transfer(address recipient, uint amount) external override returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint amount) external override returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external override returns (bool) {
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function mint(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    // 銷毀代幣，從 調用者地址 轉賬給  `0` 地址
    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }

}

// ERC20代幣的水龍頭合約
contract Faucet {

    uint256 public amountAllowed = 100; // 每次領 100單位代幣
    address public tokenContract;   // token合約地址
    mapping(address => bool) public requestedAddress;   // 记录领取过代币的地址

    // SendToken事件    
    event SendToken(address indexed Receiver, uint256 indexed Amount); 

    constructor(address _tokenContract) {
        tokenContract = _tokenContract; // set token contract
    }

    // 用戶領取代幣函數
    function requestTokens() external {
        require(!requestedAddress[msg.sender], "Can't Request Multiple Times!"); // 每個地址只能領一次
        IERC20 token = IERC20(tokenContract); // 創建IERC20合約對象
        require(token.balanceOf(address(this)) >= amountAllowed, "Faucet Empty!"); // 水龍頭空了

        token.transfer(msg.sender, amountAllowed); // 發送token
        requestedAddress[msg.sender] = true; // 記錄領取地址
        
        emit SendToken(msg.sender, amountAllowed); // 釋放SendToken事件
    }
}