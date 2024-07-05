// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "../storage/Schema.sol";
import "../storage/Storage.sol";

contract Stake {
    modifier nonReentrant() {
        Schema.GlobalState storage $s = Storage.state();
        require(!$s.initialized, "ReentrancyGuard: reentrant call");
        $s.initialized = true;
        _;
        $s.initialized = false;
    }

    function stakeTokens(uint256 amount) external nonReentrant {
        Schema.GlobalState storage $s = Storage.state();
        require(amount > 0, "Invalid amount");
        require($s.balances[msg.sender] >= amount, "Insufficient balance");

        $s.balances[msg.sender] -= amount;

        uint stakeID = $s.stakeCounter++;
        $s.stakes[stakeID] = Schema.Stake({
            stakeID: stakeID,
            staker: msg.sender,
            amount: amount,
            startTime: block.timestamp,
            endTime: block.timestamp + 4 years,
            isWithdrawn: false
        });

        $s.stakedBalances[msg.sender] += amount;
    }

    function withdrawStake(uint stakeID) external nonReentrant {
        Schema.GlobalState storage $s = Storage.state();
        Schema.Stake storage stake = $s.stakes[stakeID];

        require(stake.stakeID == stakeID, "Invalid stake ID");
        require(stake.staker == msg.sender, "Not the staker");
        require(!stake.isWithdrawn, "Already withdrawn");
        require(block.timestamp >= stake.endTime, "Stake period not ended");

        stake.isWithdrawn = true;
        $s.balances[msg.sender] += stake.amount;
        $s.stakedBalances[msg.sender] -= stake.amount;
    }
}

