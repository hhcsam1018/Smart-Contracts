// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// B和C的數據存儲佈局必須相同！變量類型、聲明的前後順序要相同，不然會搞砸合約。

// 被調用的合約C
contract C {
    uint public num;
    address public sender;

    function setVars(uint _num) public payable {
        num = _num;
        sender = msg.sender;
    }
}

// 起delegatecall的合約B
contract B {
    uint public num;
    address public sender;

    // 通過call來調用C的setVars()函數，將改變合約C裡的狀態變量
    function callSetVars(address _addr, uint _num) external payable{
        // call setVars()
        (bool success, bytes memory data) = _addr.call(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
    }
    // 通過delegatecall來調用C的setVars()函數，將改變合約B裡的狀態變量
    function delegatecallSetVars(address _addr, uint _num) external payable{
        // delegatecall setVars()
        (bool success, bytes memory data) = _addr.delegatecall(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
    }
}