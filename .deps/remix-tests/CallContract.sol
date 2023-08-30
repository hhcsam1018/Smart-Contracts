// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract OtherContract {
    uint256 private _x = 0; 
    event Log(uint amount, uint gas);
    
    function getBalance() view public returns(uint) {
        return address(this).balance;
    }

    // 可以調整狀態變量_x的函數，並且可以往合約轉ETH (payable)
    function setX(uint256 x) external payable{
        _x = x;
        // 如果轉入ETH，則釋放Log事件
        if(msg.value > 0){
            emit Log(msg.value, gasleft());
        }
    }

    // 讀取x
    function getX() external view returns(uint x){
        x = _x;
    }
}

contract CallContract{
    function callSetX(address _Address, uint256 x) external{
        OtherContract(_Address).setX(x);
    }

    function callGetX(OtherContract _Address) external view returns(uint x){
        x = _Address.getX();
    }

    function callGetX2(address _Address) external view returns(uint x){
        OtherContract oc = OtherContract(_Address);
        x = oc.getX();
    }

    function setXTransferETH(address otherContract, uint256 x) payable external{
        OtherContract(otherContract).setX{value: msg.value}(x);
    }
}