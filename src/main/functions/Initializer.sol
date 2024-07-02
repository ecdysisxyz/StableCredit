// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./Schema.sol";
import "./Storage.sol";

contract Initializer {
    function initialize(string memory _name, string memory _symbol, uint8 _decimals) external {
        Schema.GlobalState storage gs = Storage.state();
        require(!gs.initialized, "Already initialized");
        gs.initialized = true;
        gs.feeRate = 3; // 0.3%
        gs.name = _name;
        gs.symbol = _symbol;
        gs.decimals = _decimals;
        gs.totalCreditScore = 0; // 初期値設定
        gs.lendingPool = 0; // 初期値設定
        gs.initialized = false; // Reset flag after initialization
    }
}
