// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/**
* 分賬合約 
 * @dev 這個合約會把收到的ETH按事先定好的份額分給幾個賬戶。收到ETH會存在分賬合約中，需要每個受益人調用release()函數來領取。
 */
contract PaymentSplit{

    event PayeeAdded(address account, uint256 shares); // 增加受益人事件
    event PaymentReleased(address to, uint256 amount); // 受益人提款事件
    event PaymentReceived(address from, uint256 amount); // 合約收款事件

    uint256 public totalShares; 
    uint256 public totalReleased; // 總支付

    mapping(address => uint256) public shares; // 每個受益人的份額
    mapping(address => uint256) public released; // 支付給每個受益人的金額
    address[] public payees; // 受益人數組

    /**
    * @dev 初始化受益人數組_payees和分賬份額數組_shares
     * 數組長度不能為0，兩個數組長度要相等。 _shares中元素要大於0，_payees中地址不能為0地址且不能有重複地址
     */
    constructor(address[] memory _payees, uint256[] memory _shares) payable {
        require(_payees.length == _shares.length, "PaymentSplitter: payees and shares length mismatch");
        require(_payees.length > 0, "PaymentSplitter: no payees");
    // 調用_addPayee，更新受益人地址payees、受益人份額shares和總份額totalShares
        for (uint256 i = 0; i < _payees.length; i++) {
            _addPayee(_payees[i], _shares[i]);
        }
    }

    /**
     * @dev 回調函數，收到ETH釋放PaymentReceived事件
     */
    receive() external payable virtual {
        emit PaymentReceived(msg.sender, msg.value);
    }

    /**
     * @dev 為有效受益人地址_account分帳，相應的ETH直接發送到受益人地址。任何人都可以觸發這個函數，但錢會打給account地址。
     * 調用了releasable()函數。
     */
    function release(address payable _account) public virtual {
        // account必須是有效受益人
        require(shares[_account] > 0, "PaymentSplitter: account has no shares");
        // 計算account應得的eth
        uint256 payment = releasable(_account);
        // 應得的eth不能為0
        require(payment != 0, "PaymentSplitter: account is not due payment");
        // 更新總支付totalReleased和支付給每個受益人的金額released
        totalReleased += payment;
        released[_account] += payment;
        
        _account.transfer(payment);
        emit PaymentReleased(_account, payment);
    }

    /**
     * @dev 計算一個賬戶能夠領取的eth。
     */
    function releasable(address _account) public view returns (uint256) {
        // 計算分賬合約總收入totalReceived
        uint256 totalReceived = address(this).balance + totalReleased;
        // 調用_pendingPayment計算account應得的ETH
        return pendingPayment(_account, totalReceived, released[_account]);
    }

    /**
     * @dev 根據受益人地址`_account`, 分賬合約總收入`_totalReceived`和該地址已領取的錢`_alreadyReleased`，計算該受益人現在應分的`ETH`。
     */
    function pendingPayment(
        address _account,
        uint256 _totalReceived,
        uint256 _alreadyReleased
    ) public view returns (uint256) {
        // account應得的ETH = 總應得ETH - 已領到的ETH
        return (_totalReceived * shares[_account]) / totalShares - _alreadyReleased;
    }

    /**
     * @dev 新增受益人_account以及對應的份額_accountShares。只能在構造器中被調用，不能修改。
     */
    function _addPayee(address _account, uint256 _accountShares) private {
        // 檢查_account不為0地址
        require(_account != address(0), "PaymentSplitter: account is the zero address");
        // 檢查_accountShares不為0
        require(_accountShares > 0, "PaymentSplitter: shares are 0");
        // 檢查_account不重複
        require(shares[_account] == 0, "PaymentSplitter: account already has shares");

        payees.push(_account);
        shares[_account] = _accountShares;
        totalShares += _accountShares;

        emit PayeeAdded(_account, _accountShares);
    }
}