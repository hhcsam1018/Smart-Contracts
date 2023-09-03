// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Timelock{

    // 交易取消事件
    event CancelTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature,  bytes data, uint executeTime);
    // 交易執行事件
    event ExecuteTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature,  bytes data, uint executeTime);
    // 交易創建並進入隊列 事件
    event QueueTransaction(bytes32 indexed txHash, address indexed target, uint value, string signature, bytes data, uint executeTime);
    // 修改管理員地址的事件
    event NewAdmin(address indexed newAdmin);

    address public admin; // 管理員地址
    uint public constant GRACE_PERIOD = 7 days; // 交易有效期，過期的交易作廢
    uint public delay; // 交易鎖定時間 （秒）
    mapping (bytes32 => bool) public queuedTransactions; // txHash到bool，記錄所有在時間鎖隊列中的交易
    
    // onlyOwner modifier
    modifier onlyOwner() {
        require(msg.sender == admin, "Timelock: Caller not admin");
        _;
    }

    // onlyTimelock modifier
    modifier onlyTimelock() {
        require(msg.sender == address(this), "Timelock: Caller not Timelock");
        _;
    }

    /**
     * @dev 構造函數，初始化交易鎖定時間 （秒）和管理員地址
     */
    constructor(uint delay_) {
        delay = delay_;
        admin = msg.sender;
    }

    /**
     * @dev 改變管理員地址，調用者必須是Timelock合約。
     */
    function changeAdmin(address newAdmin) public onlyTimelock {
        admin = newAdmin;

        emit NewAdmin(newAdmin);
    }

    /**
    * @dev 創建交易並添加到時間鎖隊列中。
     * @param target: 目標合約地址
     * @param value: 發送eth數額
     * @param signature: 要調用的函數簽名（function signature）
     * @param data: call data，裡面是一些參數
     * @param executeTime: 交易執行的區塊鏈時間戳
     *
     * 要求：executeTime 大於 當前區塊鏈時間戳+delay
     */
    function queueTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 executeTime) public onlyOwner returns (bytes32) {
        // 檢查：交易執行時間滿足鎖定時間
        require(executeTime >= getBlockTimestamp() + delay, "Timelock::queueTransaction: Estimated execution block must satisfy delay.");
        // 計算交易的唯一識別符：一堆東西的hash
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);
        // 將交易添加到隊列
        queuedTransactions[txHash] = true;

        emit QueueTransaction(txHash, target, value, signature, data, executeTime);
        return txHash;
    }

    /**
     * @dev 取消特定交易。
     *
     */
    function cancelTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 executeTime) public onlyOwner{

        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);

        require(queuedTransactions[txHash], "Timelock::cancelTransaction: Transaction hasn't been queued.");
        // 將交易移出隊列
        queuedTransactions[txHash] = false;

        emit CancelTransaction(txHash, target, value, signature, data, executeTime);
    }

    /**
    * @dev 執行特定交易。
     *
     * 要求：
     * 1. 交易在時間鎖隊列中
     * 2. 達到交易的執行時間
     * 3. 交易沒過期
     */
    function executeTransaction(address target, uint256 value, string memory signature, bytes memory data, uint256 executeTime) public payable onlyOwner returns (bytes memory) {
        bytes32 txHash = getTxHash(target, value, signature, data, executeTime);
        // 檢查：交易是否在時間鎖隊列中
        require(queuedTransactions[txHash], "Timelock::executeTransaction: Transaction hasn't been queued.");
        // 檢查：達到交易的執行時間
        require(getBlockTimestamp() >= executeTime, "Timelock::executeTransaction: Transaction hasn't surpassed time lock.");
        // 檢查：交易沒過期
       require(getBlockTimestamp() <= executeTime + GRACE_PERIOD, "Timelock::executeTransaction: Transaction is stale.");
        // 將交易移出隊列
        queuedTransactions[txHash] = false;

        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(bytes4(keccak256(bytes(signature))), data);
        }

        (bool success, bytes memory returnData) = target.call{value: value}(callData);
        require(success, "Timelock::executeTransaction: Transaction execution reverted.");

        emit ExecuteTransaction(txHash, target, value, signature, data, executeTime);

        return returnData;
    }

    /**
     * @dev 獲取當前區塊鏈時間戳
     */
    function getBlockTimestamp() public view returns (uint) {
        return block.timestamp;
    }

    /**
     * @dev 將一堆東西拼成交易的標識符
     */
    function getTxHash(
        address target,
        uint value,
        string memory signature,
        bytes memory data,
        uint executeTime
    ) public pure returns (bytes32) {
        return keccak256(abi.encode(target, value, signature, data, executeTime));
    }
}