// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Selector{
    // event 返回msg.data
    event Log(bytes data);

    // 输入参数 to: 0x2c44b726ADF1963cA47Af88B284C06f30380fC78
    function mint(address /*to*/) external{
        emit Log(msg.data);
    } 

    // 輸出selector
    // “鑄幣（地址）”： 0x6a627842
    function mintSelector() external pure returns(bytes4 mSelector){
        return bytes4(keccak256("mint(address)"));
    }

    // 使用selector來調用函數
    function callWithSignature() external returns(bool, bytes memory){
        // 只需要利用`abi.encodeWithSelector`將`mint`函數的`selector`和參數打包編碼
        (bool success, bytes memory data) = address(this).call(abi.encodeWithSelector(0x6a627842, 0x2c44b726ADF1963cA47Af88B284C06f30380fC78));
        return(success, data);
    }
}