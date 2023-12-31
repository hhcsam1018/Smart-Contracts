// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract ValueTypes{
    bool public _bool = true;
    bool public _bool1 = !_bool; 
    bool public _bool2 = _bool && _bool1; 
    bool public _bool3 = _bool || _bool1; 
    bool public _bool4 = _bool == _bool1;
    bool public _bool5 = _bool != _bool1; 

    int public _int = -1;
    uint public _uint = 1;
    uint256 public _number = 20220330;
    uint256 public _number1 = _number + 1; 
    uint256 public _number2 = 2**2; // 指數
    uint256 public _number3 = 7 % 2; // 取餘數
    bool public _numberbool = _number2 > _number3; // 比大小


    address public _address = 0x7A58c0Be72BE218B41C608b7Fe7C5bB630736C71;
    address payable public _address1 = payable(_address); // 可以轉帳
    uint256 public balance = _address1.balance; // 帳戶餘額
    
    
    bytes32 public _byte32 = "MiniSolidity"; // bytes32: 0x4d696e69536f6c69646974790000000000000000000000000000000000000000
    bytes1 public _byte = _byte32[0]; // bytes1: 0x4d
    
    
    enum ActionSet { Buy, Hold, Sell }
    ActionSet action = ActionSet.Buy;

    // enum和uint轉換
    function enumToUint() external view returns(uint){
        return uint(action);
    }
}