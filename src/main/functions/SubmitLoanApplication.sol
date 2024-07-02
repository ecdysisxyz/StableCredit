// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./Schema.sol";
import "./Storage.sol";

contract SubmitLoanApplication {
    modifier nonReentrant() {
        Schema.GlobalState storage gs = Storage.state();
        require(!gs.initialized, "ReentrancyGuard: reentrant call");
        gs.initialized = true;
        _;
        gs.initialized = false;
    }

    function submitLoanApplication(address borrower, uint256 amount) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();

        require(amount > 0, "Invalid amount");
        require(!gs.users[borrower].isFrozen, "Borrower is frozen");

        uint loanID = gs.loanCounter++;
        gs.loanApplications[loanID] = Schema.LoanApplication({
            loanID: loanID,
            borrower: borrower,
            amount: amount,
            status: "Pending",
            fee: (amount * gs.feeRate) / 1000,
            totalVotes: 0,
            voteCount: 0
        });

        gs.users[borrower].loanApplicationIDs.push(loanID);
    }

    function voteOnLoanApplication(uint loanID, uint voteAmount) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();
        Schema.LoanApplication storage loan = gs.loanApplications[loanID];

        require(loan.loanID == loanID, "Invalid loan ID");
        uint votingPower = getVotingPower(msg.sender, loan.borrower);
        require(votingPower >= voteAmount, "Insufficient voting power");

        gs.loanVotes[loanID][msg.sender] += voteAmount;
        loan.totalVotes += voteAmount;
        loan.voteCount++;
    }

    function approveLoanApplication(uint loanID) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();
        Schema.LoanApplication storage loan = gs.loanApplications[loanID];

        require(loan.loanID == loanID, "Invalid loan ID");

        uint totalVotesNeeded = getTotalVotesNeeded(loan.borrower);

        if (loan.totalVotes >= totalVotesNeeded) {
            loan.status = "Approved";
        } else {
            loan.status = "Rejected";
        }
    }

    function getVotingPower(address voter, address borrower) internal view returns (uint) {
        require(voter != borrower, "Self-voting is not allowed");
        Schema.GlobalState storage gs = Storage.state();
        uint votingPower = 0;

        for (uint i = 0; i < gs.users[borrower].transactionIDs.length; i++) {
            Schema.Transaction storage tx = gs.transactions[gs.users[borrower].transactionIDs[i]];
            if (tx.sender == voter && tx.receiver == borrower) {
                votingPower += tx.amount;
            }
        }

        return votingPower;
    }

    function getTotalVotesNeeded(address borrower) internal view returns (uint) {
        Schema.GlobalState storage gs = Storage.state();
        uint totalVotesNeeded = 0;

        for (uint i = 0; i < gs.users[borrower].transactionIDs.length; i++) {
            Schema.Transaction storage tx = gs.transactions[gs.users[borrower].transactionIDs[i]];
            if (tx.receiver == borrower) {
                totalVotesNeeded += tx.amount;
            }
        }

        return totalVotesNeeded;
    }
}

