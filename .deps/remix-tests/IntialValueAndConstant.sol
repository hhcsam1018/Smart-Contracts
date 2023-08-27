// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract InitialValue {
    
    bool public _bool; // false
    string public _string; // ""
    int public _int; // 0
    uint public _uint; // 0
    address public _address; // 0x0000000000000000000000000000000000000000

    enum ActionSet { Buy, Hold, Sell}
    ActionSet public _enum; // 第一个元素 0

    function fi() internal{} // internal空白
    function fe() external{} // external空白

    uint[8] public _staticArray; // [0,0,0,0,0,0,0,0]
    uint[] public _dynamicArray; // `[]`
    mapping(uint => address) public _mapping; // mapping 0, 0
    
    struct Student{
        uint256 id;
        uint256 score; 
    }
    Student public student;

    // delete操作
    bool public _bool2 = true; 
    function d() external {
        delete _bool2; // delete 讓 bool2變回默認值，false
    }
}

contract Constant {
    // constant必须在聲明之後初始化，之後不能改變
    uint256 public constant CONSTANT_NUM = 10;
    string public constant CONSTANT_STRING = "0xAA";
    bytes public constant CONSTANT_BYTES = "WTF";
    address public constant CONSTANT_ADDRESS = 0x0000000000000000000000000000000000000000;

    // immutable可以在constructor初始化，之後不能改變
    uint256 public immutable IMMUTABLE_NUM = 9999999999;
    address public immutable IMMUTABLE_ADDRESS;
    uint256 public immutable IMMUTABLE_BLOCK;
    uint256 public immutable IMMUTABLE_TEST;

    constructor(){
        IMMUTABLE_ADDRESS = address(this);
        IMMUTABLE_BLOCK = block.number;
        IMMUTABLE_TEST = test();
    }

    function test() public pure returns(uint256){
        uint256 what = 9;
        return(what);
    }
}