// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./ERC20.sol";

/**
。* @title ERC20代幣線性釋放
 * @dev 這個合約會將ERC20代幣線性釋放給給受益人`_beneficiary`。
 * 釋放的代幣可以是一種，也可以是多種。釋放週期由起始時間`_start`和時長`_duration`定義。
 * 所有轉到這個合約上的代幣都會遵循同樣的線性釋放週期，並且需要受益人調用`release()`函數提取。
 * 合約是從OpenZeppelin的VestingWallet簡化而來
 */
contract TokenVesting {
    // 事件
    event ERC20Released(address indexed token, uint256 amount); // 提幣事件


    mapping(address => uint256) public erc20Released; // 代幣地址->釋放數量的映射，記錄受益人已領取的代幣數量
    address public immutable beneficiary; // 受益人地址
    uint256 public immutable start; // 歸屬期起始時間戳
    uint256 public immutable duration; // 歸屬期 (秒)

    /**
     * @dev 初始化受益人地址，釋放週期(秒), 起始時間戳(當前區塊鏈時間戳)
     */
    constructor(
        address beneficiaryAddress,
        uint256 durationSeconds
    ) {
        require(beneficiaryAddress != address(0), "VestingWallet: beneficiary is zero address");
        beneficiary = beneficiaryAddress;
        start = block.timestamp;
        duration = durationSeconds;
    }

    /**
    * @dev 受益人提取已釋放的代幣。
     * 調用vestedAmount()函數計算可提取的代幣數量，然後transfer給受益人。
     * 釋放 {ERC20Released} 事件.
     */
    function release(address token) public {
        // 調用vestedAmount()函數計算可提取的代幣數量
        uint256 releasable = vestedAmount(token, uint256(block.timestamp)) - erc20Released[token];
        // 更新已釋放代幣數量  
        erc20Released[token] += releasable; 
        // 轉代幣給受益人
        emit ERC20Released(token, releasable);
        IERC20(token).transfer(beneficiary, releasable);
    }

    /**
    * @dev 根據線性釋放公式，計算已經釋放的數量。開發者可以通過修改這個函數，自定義釋放方式。
     * @param token: 代幣地址
     * @param timestamp: 查詢的時間戳
     */
    function vestedAmount(address token, uint256 timestamp) public view returns (uint256) {
        // 合約裡總共收到了多少代幣（當前餘額 + 已經提取）
        uint256 totalAllocation = IERC20(token).balanceOf(address(this)) + erc20Released[token];
        // 根據線性釋放公式，計算已經釋放的數量
        if (timestamp < start) {
            return 0;
        } else if (timestamp > start + duration) {
            return totalAllocation;
        } else {
            return (totalAllocation * (timestamp - start)) / duration;
        }
    }
}