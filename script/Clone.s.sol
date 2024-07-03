// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "forge-std/Scirpt.sol";
import "usc-contracts/src/proxy/ProxyUtils.sol"
import "./src/main/functions/Initializer.sol";
import "./src/main/functions/Clone.sol";

contract CloneScript is Script {
    function run() external returns () {
        address existingProxy = env.getOr("EXISTING_PROXY");
        address clone = Clone(existingProxy).clone(ProxyUtils.getDictionary());
        Initializer(clone).initialize(
            "StableCredit USD",
            "scUSD",
            18,
            3, // Fee rate as 0.3%
            address(0x123...), // Example collateral token address
            150, // Minimum collateralization ratio
            address(0x456...) // Example price feed address
        );
        return clone;
    }
}

