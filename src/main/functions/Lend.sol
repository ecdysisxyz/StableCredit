// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./Schema.sol";
import "./Storage.sol";

contract Lend {
    modifier nonReentrant() {
        Schema.GlobalState storage gs = Storage.state();
        require(!gs.initialized, "ReentrancyGuard: reentrant call");
        gs.initialized = true;
        _;
        gs.initialized = false;
    }

    function mintNewGovernanceTokens(uint256 amount) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();
        
        require(amount > 0, "Invalid amount");

        uint256 poolAmount = (amount * 90) / 100;
        uint256 remainingAmount = amount - poolAmount;

        gs.lendingPool += poolAmount;
        gs.totalSupply += amount;

        // Reward pool tokens to lending pool
        gs.balances[address(this)] += remainingAmount;
    }

    function withdrawGovernanceTokens(uint256 amount) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();

        uint256 userShare = (gs.lendingPool * gs.users[msg.sender].creditScore) / gs.totalCreditScore;
        require(amount <= userShare, "Amount exceeds user share");

        gs.lendingPool -= amount;
        gs.balances[msg.sender] += amount;
    }

    function repayLoan(uint256 loanID, uint256 amount) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();
        Schema.LoanApplication storage loan = gs.loanApplications[loanID];

        require(loan.loanID == loanID, "Invalid loan ID");
        require(loan.borrower == msg.sender, "Not the borrower");
        require(amount >= loan.amount, "Insufficient amount");

        loan.status = "Repaid";

        uint256 reward = (amount * 10) / 100;
        gs.balances[msg.sender] += reward;

        // Update user's credit score and total credit score
        gs.totalCreditScore += reward;
        gs.users[msg.sender].creditScore += reward;
    }
}

