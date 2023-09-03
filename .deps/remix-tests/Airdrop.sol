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

contract Airdrop {
    mapping(address => uint) failTransferList;
    /// _token 轉賬的ERC20代幣地址
    /// _addresses 空投地址數組
    /// _amounts 代幣數量數組（每個地址的空投數量）
    function multiTransferToken(
        address _token,
        address[] calldata _addresses,
        uint256[] calldata _amounts
    ) external {
        // 檢查：_addresses和_amounts數組的長度相等
        require(
            _addresses.length == _amounts.length,
            "Lengths of Addresses and Amounts NOT EQUAL"
        );
        IERC20 token = IERC20(_token); 
        uint _amountSum = getSum(_amounts); // 計算空投代幣總量
        // 檢查：授權代幣數量 > 空投代幣總量
        require(
            token.allowance(msg.sender, address(this)) > _amountSum,
            "Need Approve ERC20 token"
        );

        // for循環，利用transferFrom函數發送空投
        for (uint256 i; i < _addresses.length; i++) {
            token.transferFrom(msg.sender, _addresses[i], _amounts[i]);
        }
    }

    // /// 向多個地址轉賬ETH
    // function multiTransferETH(
    //     address payable[] calldata _addresses,
    //     uint256[] calldata _amounts
    // ) public payable {
    //     require(
    //         _addresses.length == _amounts.length,
    //         "Lengths of Addresses and Amounts NOT EQUAL"
    //     );
    //     uint _amountSum = getSum(_amounts); // 計算空投ETH總量
    //     // 檢查轉入ETH等於空投總量
    //     require(msg.value == _amountSum, "Transfer amount error");

    //     for (uint256 i = 0; i < _addresses.length; i++) {

    //         (bool success, ) = _addresses[i].call{value: _amounts[i]}("");
    //         if (!success) {
    //             failTransferList[_addresses[i]] = _amounts[i];
    //         }
    //     }
    // }

    // // 给空投失败提供主动操作机会
    // function withdrawFromFailList(address _to) public {
    //     uint failAmount = failTransferList[msg.sender];
    //     require(failAmount > 0, "You are not in failed list");
    //     failTransferList[msg.sender] = 0;
    //     (bool success, ) = _to.call{value: failAmount}("");
    //     require(success, "Fail withdraw");
    // }

    // 数组求和函数
    function getSum(uint256[] calldata _arr) public pure returns (uint sum) {
        for (uint i = 0; i < _arr.length; i++) sum = sum + _arr[i];
    }
}