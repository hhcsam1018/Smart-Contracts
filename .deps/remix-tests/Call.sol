// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract OtherContract {
    uint256 private _x = 0; 
   
    event Log(uint amount, uint gas);

    //fallback() external payable{}

    
    function getBalance() view public returns(uint) {
        return address(this).balance;
    }

    function setX(uint256 x) external payable{
        _x = x;

        if(msg.value > 0){
            emit Log(msg.value, gasleft());
        }
    }


    function getX() external view returns(uint x){
        x = _x;
    }
}

contract Call{
    // 定義Response事件，輸出call返回的結果success和data
    event Response(bool success, bytes data);

    function callSetX(address payable _addr, uint256 x) public payable {
        // call setX()，同時可以發送ETH
        (bool success, bytes memory data) = _addr.call{value: msg.value}(
            abi.encodeWithSignature("setX(uint256)", x)
        );

        emit Response(success, data); //释放事件
    }

    function callGetX(address _addr) external returns(uint256){
        
        (bool success, bytes memory data) = _addr.call(
            abi.encodeWithSignature("getX()")
        );

        emit Response(success, data); //释放事件
        return abi.decode(data, (uint256));
    }

    function callNonExist(address _addr) external{
        // call 不存在的函数
        (bool success, bytes memory data) = _addr.call(
            abi.encodeWithSignature("foo(uint256)")
        );

        emit Response(success, data); //释放事件
    }
}