// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { ERC20Base } from "ecdysisxyz/ERC20/src/main/functions/ERC20Base.sol";
import { Schema as ERC20Schema } from "ecdysisxyz/ERC20/src/main/storage/Schema.sol";
import { Storage as ERC20Storage } from "ecdysisxyz/ERC20/src/main/storage/Storage.sol";
import { Schema } from "../storage/Schema.sol";
import { Storage } from "../storage/Storage.sol";

contract Stablecoin is ERC20Base {

    function stakedBalanceOf(address account) external view returns (uint256) {
        Schema.GlobalState storage gs = Storage.state();
        return gs.stakedBalances[account];
    }

}
