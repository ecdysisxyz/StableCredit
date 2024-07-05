

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { ERC20Base } from "ecdysisxyz/ERC20/src/main/functions/ERC20Base.sol";
import { Schema as ERC20Schema } from "ecdysisxyz/ERC20/src/main/storage/Schema.sol";
import { Storage as ERC20Storage } from "ecdysisxyz/ERC20/src/main/storage/Storage.sol";
import { Schema } from "../storage/Schema.sol";
import { Storage } from "../storage/Storage.sol";

contract Stablecoin is ERC20Base {
    function transfer(address recipient, uint256 amount) public override returns (bool) {
       _transfer(msg.sender, recipient, amount);
        _recordTransaction(msg.sender, recipient, amount);
        _updateUserStatus(msg.sender);
        _updateCreditScore(recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
       _transfer(sender, recipient, amount);
        _recordTransaction(sender, recipient, amount);
        _updateUserStatus(sender);
        _updateCreditScore(recipient, amount);
        return true;
    }

    function _recordTransaction(address sender, address recipient, uint256 amount) internal {
        Schema.GlobalState storage $cdp = Storage.state();
        uint transactionID = $cdp.transactionCounter++;
        $cdp.transactions[transactionID] = Schema.Transaction({
            transactionID: transactionID,
            sender: sender,
            receiver: recipient,
            amount: amount,
            timestamp: block.timestamp
        });
        $cdp.transactionIDs[sender].push(transactionID);
        $cdp.transactionIDs[recipient].push(transactionID);
    }

    function _updateUserStatus(address user) internal {
        Schema.GlobalState storage $cdp = Storage.state();
        $cdp.users[user].isActive = true;
    }

    function _updateCreditScore(address recipient, uint256 amount) internal {
        Schema.GlobalState storage $cdp = Storage.state();
        uint256 creditScore = _calculateCreditScore(recipient, amount);
        $cdp.users[recipient].creditScore += creditScore;
    }

    function _calculateCreditScore(address recipient, uint256 amount) internal view returns (uint256) {
        Schema.GlobalState storage $cdp = Storage.state();
        uint256 totalSentAmount = 0;
        uint256 totalSenders = 0;

        for (uint i = 0; i < $cdp.users[recipient].transactionIDs.length; i++) {
            Schema.Transaction storage tx = $cdp.transactions[$cdp.users[recipient].transactionIDs[i]];
            if (tx.receiver == recipient) {
                totalSentAmount += tx.amount;
                totalSenders++;
            }
        }

        uint256 averageSentAmount = totalSentAmount / totalSenders;
        return (averageSentAmount * amount);
    }
}
