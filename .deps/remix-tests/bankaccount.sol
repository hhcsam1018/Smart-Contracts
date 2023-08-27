// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;
contract Test {
    bool public isMerge =true;

    int public I =-123;
    uint public U=999999;
    int8 public I8 =-4;
    uint256 public U256 =3;

    //address
    address public HaoAddr =0xf33888DEEf2390DDD27015974Fa439Ee27477506;
    address payable public payHaoAddr =payable(HaoAddr);

    //enum
    enum Color{Blue,Green}
    Color public C =Color.Blue;
}

contract Hello{
    function hi() public pure returns(string memory){
        return "Hello ETH";
    }
}

contract piggybank{
    address public owner;
    event Create(address owner, uint256 value);
    event Receive(address indexed sender, uint256 value);
    event Withdraw(address indexed owner, uint256 value);
    modifier onlyowner{
        require(owner==msg.sender,"Only owner can call this function");
        _;
    }
    constructor() payable {
        owner=msg.sender;
        emit Create(owner,msg.value);
    }
    receive() payable external {
        emit Receive(msg.sender,msg.value);
    }
    function withdraw() onlyowner external {
        address payable Receiver = payable(msg.sender);
        uint256 value =address(this).balance;
        Receiver.transfer(address(this).balance);
        emit Withdraw(Receiver, value);
    }
}

contract Class {
    mapping(uint => uint) Students;
    function update(uint id,uint score) public{
        Students[id]=score;
    }
    function get(uint id) public view returns(uint){
        return Students[id];
    }
}

