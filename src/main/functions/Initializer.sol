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
        uint256 _feeRate,
        address _collateralToken,
        uint256 _minimumCollateralizationRatio
        address _priceFeed;
    ) external {
        Schema.GlobalState storage gs = Storage.state();
        require(!gs.initialized, "Already initialized");
        gs.initialized = true;
        gs.name = _name;
        gs.symbol = _symbol;
        gs.decimals = _decimals;
        gs.feeRate = _feeRate;
        gs.totalCreditScore = 0;
        gs.lendingPool = 0;
        gs.totalSupply = 0;

        gs.collateralToken = _collateralToken;
        gs.MINIMUM_COLLATERALIZATION_RATIO = _minimumCollateralizationRatio;
        gs.priceFeed = _priceFeed;

        gs.initialized = false; // Reset flag after initialization
    }
}
