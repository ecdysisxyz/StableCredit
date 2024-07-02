// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./Schema.sol";
import "./Storage.sol";

contract Transfer {
    modifier nonReentrant() {
        Schema.GlobalState storage gs = Storage.state();
        require(!gs.initialized, "ReentrancyGuard: reentrant call");
        gs.initialized = true;
        _;
        gs.initialized = false;
    }

    function transfer(address recipient, uint256 amount) external nonReentrant returns (bool) {
        Schema.GlobalState storage gs = Storage.state();

        require(amount > 0, "Invalid amount");
        require(gs.balances[msg.sender] >= amount, "Insufficient balance");

        gs.balances[msg.sender] -= amount;
        gs.balances[recipient] += amount;

        // Update transaction record
        uint transactionID = gs.transactionCounter++;
        gs.transactions[transactionID] = Schema.Transaction({
            transactionID: transactionID,
            sender: msg.sender,
            receiver: recipient,
            amount: amount,
            timestamp: block.timestamp
        });

        // Update user status
        gs.users[msg.sender].isActive = true;

        // Calculate credit score
        gs.users[recipient].creditScore += calculateCreditScore(msg.sender, amount);

        return true;
    }

    function calculateCreditScore(address sender, uint256 amount) internal view returns (uint256) {
        Schema.GlobalState storage gs = Storage.state();
        uint256 totalSentAmount = 0;
        uint256 totalSenders = 0;

        for (uint i = 0; i < gs.users[sender].transactionIDs.length; i++) {
            Schema.Transaction storage tx = gs.transactions[gs.users[sender].transactionIDs[i]];
            if (tx.receiver == sender) {
                totalSentAmount += tx.amount;
                totalSenders++;
            }
        }

        uint256 averageSentAmount = totalSentAmount / totalSenders;
        return (averageSentAmount * amount);
    }
}

