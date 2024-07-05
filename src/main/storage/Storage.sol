// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {Schema} from "./Schema.sol";

library Storage {
    // cast index-erc7201 ecdysisxyz.stablecredit.globalstate
    function state() internal pure returns(Schema.GlobalState storage s) {
        assembly { s.slot := 0xe63abce30f82cf4101277e24ae079dd2523ff194d38cd21ed39e733d7a400a00 }
    }
}
