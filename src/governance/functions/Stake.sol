// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./Schema.sol";
import "./Storage.sol";

contract Stake {
    modifier nonReentrant() {
        Schema.GlobalState storage gs = Storage.state();
        require(!gs.initialized, "ReentrancyGuard: reentrant call");
        gs.initialized = true;
        _;
        gs.initialized = false;
    }

    function stakeTokens(uint256 amount) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();
        require(amount > 0, "Invalid amount");
        require(gs.balances[msg.sender] >= amount, "Insufficient balance");

        gs.balances[msg.sender] -= amount;

        uint stakeID = gs.stakeCounter++;
        gs.stakes[stakeID] = Schema.Stake({
            stakeID: stakeID,
            staker: msg.sender,
            amount: amount,
            startTime: block.timestamp,
            endTime: block.timestamp + 4 years,
            isWithdrawn: false
        });

        gs.users[msg.sender].governanceTokensStaked += amount;
    }

    function withdrawStake(uint stakeID) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();
        Schema.Stake storage stake = gs.stakes[stakeID];

        require(stake.stakeID == stakeID, "Invalid stake ID");
        require(stake.staker == msg.sender, "Not the staker");
        require(!stake.isWithdrawn, "Already withdrawn");
        require(block.timestamp >= stake.endTime, "Stake period not ended");

        stake.isWithdrawn = true;
        gs.balances[msg.sender] += stake.amount;
        gs.users[msg.sender].governanceTokensStaked -= stake.amount;
    }
}

