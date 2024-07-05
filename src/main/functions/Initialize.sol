// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { Schema as ERC20Schema } from "ecdysisxyz/ERC20/src/main/storage/Schema.sol";
import { Storage as ERC20Storage } from "ecdysisxyz/ERC20/src/main/storage/Storage.sol";
import { Schema } from "../storage/Schema.sol";
import { Storage } from "../storage/Storage.sol";
import "./PriceConsumer.sol";

contract Initialize {
    function initialize(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _feeRate,
        address _collateralToken,
        uint256 _minimumCollateralizationRatio,
        address _priceFeed
    ) external {
        Schema.GlobalState storage $cdp = Storage.state();
        ERC20Schema.GlobalState storage $erc20 = ERC20Storage.state();

        require(!$cdp.initialized, "Already initialized");
        $cdp.initialized = true;
        
        $cdp.feeRate = _feeRate;
        $cdp.collateralToken = _collateralToken;
        $cdp.minimumCollateralizationRatio = _minimumCollateralizationRatio;
        $cdp.priceFeed = _priceFeed;

        $erc20.name = _name;
        $erc20.symbol = _symbol;
        $erc20.decimals = _decimals;
    }
}
