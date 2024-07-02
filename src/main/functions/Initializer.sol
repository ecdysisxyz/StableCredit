// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./Schema.sol";
import "./Storage.sol";
import "./PriceConsumer.sol";

contract Initializer {
    function initialize(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _priceFeed
    ) external {
        Schema.GlobalState storage gs = Storage.state();
        require(!gs.initialized, "Already initialized");
        gs.initialized = true;
        gs.name = _name;
        gs.symbol = _symbol;
        gs.decimals = _decimals;
        gs.feeRate = 3; // 0.3%
        gs.lastGoodPrice = 0;
        gs.MINIMUM_COLLATERALIZATION_RATIO = 130; // 最小担保率 130%
        gs.totalCreditScore = 0; // 初期値設定
        gs.lendingPool = 0; // 初期値設定

        // Initialize PriceConsumer
        gs.priceFeed = _priceFeed;
        gs.priceConsumer = new PriceConsumer(_priceFeed);

        gs.initialized = false; // Reset flag after initialization
    }
}
