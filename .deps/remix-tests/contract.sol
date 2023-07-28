// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract Donation{
    address public owner;
    mapping(address=>uint256) donationList;

    event Donate(address indexed sender, uint256 value);
    event Withdraw(address indexed owner, uint256 value);
    
    modifier onlyowner{
        require(owner==msg.sender,"Only owner can call this function");
        _;
    }

    constructor(){
        //將合約擁有者設定成創建合約的人
        owner=msg.sender;
    }

    //收捐款的函式
    function donate() public payable{
        //捐款的人把他的捐款數字加上去
        donationList[msg.sender]=msg.value;
        emit Donate(msg.sender,msg.value);
    }

    //查詢捐款金額
    function getHistory() public view returns(uint256){
        return donationList[msg.sender];
    }

    //查詢vip等級
    function getRank() public view returns(string memory){
        if (donationList[msg.sender]>10 ether){
            return "UR";
        }else if (donationList[msg.sender]>5 ether){
            return "SR";
        }else if (donationList[msg.sender]>1 ether){
            return "R";
        }else if (donationList[msg.sender]>0 ether){
            return "N";     
        }else{
            return "None";
        }
    }

    //提領餘額
    function withdraw() onlyowner public{
        address payable Receiver = payable(owner);
        uint256 value = address(this).balance;
        Receiver.transfer(value);
        emit Withdraw(Receiver, value);
    }
}