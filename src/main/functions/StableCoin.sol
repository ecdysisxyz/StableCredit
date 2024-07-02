
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Schema.sol";
import "./Storage.sol";

contract StableCoin is ERC20, ReentrancyGuard {
    Storage private _storage;

    constructor(address storageAddress) ERC20("StableCoin", "SC") {
        _storage = Storage(storageAddress);
    }

    function issueStableCoin(address borrower, uint256 amount) external nonReentrant {
        require(amount > 0, "Invalid amount");

        Schema.GlobalState storage gs = _storage.state();
        require(gs.users[borrower].isActive, "User is not active");

        // Transfer collateral (ETH) to the contract (this is a simplified example)
        require(msg.value >= amount, "Insufficient collateral");

        // Mint StableCoin to the borrower
        _mint(borrower, amount);

        // Update StableCoin balance of user and loan application
        gs.stableCoin.balances[borrower] += amount;
        uint fee = (amount * gs.feeRate) / 100;
        gs.stableCoin.totalSupply += amount - fee;
        gs.governanceToken.totalSupply += fee;
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(amount > 0, "Invalid amount");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        // Standard ERC-20 transfer
        _transfer(msg.sender, recipient, amount);

        // Update transaction record
        Schema.GlobalState storage gs = _storage.state();
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

        // Calculate credit score (this is a simplified example)
        gs.users[recipient].creditScore += calculateCreditScore(msg.sender, amount);

        return true;
    }

    function calculateCreditScore(address sender, uint256 amount) internal view returns (uint256) {
        // This function calculates the credit score based on the graph theory formula
        Schema.GlobalState storage gs = _storage.state();
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

