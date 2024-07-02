// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "../storage/Schema.sol";
import "../storage/Storage.sol";

contract Initializer {
    function initialize(string memory _name, string memory _symbol, uint8 _decimals) external {
        GovernanceSchema.GlobalState storage gs = GovernanceStorage.state();
        require(!gs.initialized, "Already initialized");
        gs.initialized = true;
        gs.name = _name;
        gs.symbol = _symbol;
        gs.decimals = _decimals;
        gs.initialized = false; // Reset flag after initialization
    }
}

