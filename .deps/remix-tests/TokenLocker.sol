// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


import "./ERC20.sol";

/**
 * @dev ERC20代幣時間鎖合約。受益人在鎖倉一段時間後才能取出代幣。
 */
contract TokenLocker {

    // 事件
    event TokenLockStart(address indexed beneficiary, address indexed token, uint256 startTime, uint256 lockTime);
    event Release(address indexed beneficiary, address indexed token, uint256 releaseTime, uint256 amount);

    // 被鎖倉的ERC20代幣合約
    IERC20 public immutable token;
    // 受益人地址
    address public immutable beneficiary;
    // 鎖倉時間(秒)
    uint256 public immutable lockTime;
    // 鎖倉起始時間戳(秒)
    uint256 public immutable startTime;

    /**
    * @dev 部署時間鎖合約，初始化代幣合約地址，受益人地址和鎖倉時間。
     * @param token_: 被鎖倉的ERC20代幣合約
     * @param beneficiary_: 受益人地址
     * @param lockTime_: 鎖倉時間(秒)
     */
    constructor(
        IERC20 token_,
        address beneficiary_,
        uint256 lockTime_
    ) {
        require(lockTime_ > 0, "TokenLock: lock time should greater than 0");
        token = token_;
        beneficiary = beneficiary_;
        lockTime = lockTime_;
        startTime = block.timestamp;

        emit TokenLockStart(beneficiary_, address(token_), block.timestamp, lockTime_);
    }

    /**
     * @dev 在鎖倉時間過後，將代幣釋放給受益人。
     */
    function release() public {
        require(block.timestamp >= startTime+lockTime, "TokenLock: current time is before release time");

        uint256 amount = token.balanceOf(address(this));
        require(amount > 0, "TokenLock: no tokens to release");

        token.transfer(beneficiary, amount);

        emit Release(msg.sender, address(token), block.timestamp, amount);
    }
}