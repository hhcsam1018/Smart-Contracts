// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract FunctionTypes{
    uint256 public number = 5;
    
    constructor() payable {}

    // function (<parameter types>) {internal|external} [pure|view|payable] [returns (<return types>)]
    function add() external{
        number = number + 1;
    }

    // pure
    function addPure(uint256 _number) external pure returns(uint256 new_number){
        new_number = _number+1;
    }
    
    // view
    function addView() external view returns(uint256 new_number) {
        new_number = number + 1;
    }

    // 只能從合約內部訪問，繼承的合約可以用
    function minus() internal {
        number = number - 1;
    }

    // 只能從合約外部訪問
    function minusCall() external {
        minus();
    }

    // payable : 可以支付
    function minusPayable() external payable returns(uint256 balance) {
        minus();    
        balance = address(this).balance;
    }
}