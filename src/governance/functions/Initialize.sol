// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "../storage/Schema.sol";
import "../storage/Storage.sol";
import { Schema as ERC20Schema } from "ecdysisxyz/ERC20/src/main/storage/Schema.sol";
import { Storage as ERC20Storage } from "ecdysisxyz/ERC20/src/main/storage/Storage.sol";

contract Initialize {
    function initialize(string memory _name, string memory _symbol, uint8 _decimals) external {
        ERC20Schema.GlobalState storage $erc20 = ERC20Storage.state();
        Schema.GlobalState storage $s = Storage.state();
        require(!$s.initialized, "Already initialized");
        $s.initialized = true;
        $erc20.name = _name;
        $erc20.symbol = _symbol;
        $erc20.decimals = _decimals;
    }
}

