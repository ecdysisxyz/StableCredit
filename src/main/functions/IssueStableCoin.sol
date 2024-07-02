// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./Schema.sol";
import "./Storage.sol";

contract IssueStableCoin {
    modifier nonReentrant() {
        Schema.GlobalState storage gs = Storage.state();
        require(!gs.initialized, "ReentrancyGuard: reentrant call");
        gs.initialized = true;
        _;
        gs.initialized = false;
    }

    function issueStableCoin(address borrower, uint256 amount) external payable nonReentrant {
        Schema.GlobalState storage gs = Storage.state();

        require(amount > 0, "Invalid amount");
        require(gs.users[borrower].isActive, "User is not active");

        // Transfer collateral (ETH) to the contract
        require(msg.value >= amount, "Insufficient collateral");

        // Mint StableCoin to the borrower
        gs.balances[borrower] += amount;
        uint fee = (amount * gs.feeRate) / 1000;
        gs.totalSupply += amount - fee;
    }
}

