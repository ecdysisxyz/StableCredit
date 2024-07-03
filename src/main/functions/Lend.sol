// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./Schema.sol";
import "./Storage.sol";
import "bundle/governance/functions/GovernanceToken.sol";

contract Lend {
    uint256 public constant annualInterestRate = 16; // 16%

    modifier nonReentrant() {
        Schema.GlobalState storage gs = Storage.state();
        require(!gs.initialized, "ReentrancyGuard: reentrant call");
        gs.initialized = true;
        _;
        gs.initialized = false;
    }

    function governanceToken() internal view returns (GovernanceToken) {
        Schema.GlobalState storage gs = Storage.state();
        return GovernanceToken(gs.governanceTokenAddress);
    }

    function proposeMint(uint256 amount) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();
        require(amount > 0, "Invalid amount");
        require(gs.governanceTokenAddress != address(0), "Governance token not set");

        uint256 proposalID = gs.mintProposalCounter++;
        gs.mintProposals[proposalID] = Schema.MintProposal({
            proposalID: proposalID,
            proposer: msg.sender,
            amount: amount,
            votesFor: 0,
            votesAgainst: 0,
            executed: false
        });

        emit MintProposalCreated(proposalID, msg.sender, amount);
    }

    function mintVote(uint256 proposalID, bool support) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();
        require(proposalID < gs.mintProposalCounter, "Invalid proposal ID");
        require(!gs.mintProposals[proposalID].executed, "Proposal already executed");

        Schema.MintProposal storage proposal = gs.mintProposals[proposalID];
        require(!proposal.voters[msg.sender], "Already voted");

        uint256 votingPower = governanceToken().balanceOf(msg.sender);
        require(votingPower > 0, "No voting power");

        if (support) {
            proposal.votesFor += votingPower;
        } else {
            proposal.votesAgainst += votingPower;
        }

        proposal.voters[msg.sender] = true;

        emit MintVoteCast(proposalID, msg.sender, support, votingPower);
    }

    function tallyMintVotes(uint256 proposalID) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();
        require(proposalID < gs.mintProposalCounter, "Invalid proposal ID");

        Schema.MintProposal storage proposal = gs.mintProposals[proposalID];
        require(!proposal.executed, "Proposal already executed");

        uint256 totalVotes = proposal.votesFor + proposal.votesAgainst;
        require(totalVotes > 0, "No votes cast");

        if (proposal.votesFor > proposal.votesAgainst) {
            _mintNewGovernanceTokens(proposal.amount);
            proposal.executed = true;
            emit MintProposalExecuted(proposalID, proposal.amount);
        } else {
            proposal.executed = true;
            emit MintProposalRejected(proposalID);
        }
    }

    function _mintNewGovernanceTokens(uint256 amount) internal {
        Schema.GlobalState storage gs = Storage.state();
        require(amount > 0, "Invalid amount");

        // Mint ERC20 governance tokens
        governanceToken().mint(address(this), amount);

        uint256 poolAmount = (amount * 90) / 100;
        uint256 remainingAmount = amount - poolAmount;

        gs.lendingPool += poolAmount;
        gs.totalSupply += amount;

        // Reward incentivised parties with 10%
        uint256 rewardAmount = remainingAmount;
        uint256 totalRepaid = 0;
        uint256 totalEligibleUsers = 0;

        // Calculate total repaid amount and count eligible users
        for (uint i = 0; i < gs.usersList.length; i++) {
            address userAddress = gs.usersList[i];
            if (gs.users[userAddress].repaidWithinYear) {
                totalRepaid += gs.users[userAddress].repaidAmount;
                totalEligibleUsers++;
            }
        }

        // Distribute rewards to eligible users
        for (uint i = 0; i < gs.usersList.length; i++) {
            address userAddress = gs.usersList[i];
            if (gs.users[userAddress].repaidWithinYear) {
                uint256 userReward = (gs.users[userAddress].repaidAmount * rewardAmount) / totalRepaid;
                governanceToken().transfer(userAddress, userReward);
            }
        }
    }

    function proposeLoan(uint256 amount) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();
        require(!gs.users[msg.sender].isFrozen, "User is frozen");

        uint256 userShare = (gs.lendingPool * gs.users[msg.sender].creditScore) / gs.totalCreditScore;
        require(amount <= userShare, "Amount exceeds user share");

        // Create a new LoanApplication
        uint loanID = gs.loanCounter++;
        gs.loanApplications[loanID] = Schema.LoanApplication({
            loanID: loanID,
            borrower: msg.sender,
            amount: amount,
            status: "Pending",
            fee: (amount * gs.feeRate) / 1000,
            totalVotes: 0,
            voteCount: 0
        });

        gs.users[msg.sender].loanApplicationIDs.push(loanID);
    }

    function loanVote(uint loanID, uint voteAmount) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();
        Schema.LoanApplication storage loan = gs.loanApplications[loanID];

        require(loan.loanID == loanID, "Invalid loan ID");
        require(!gs.users[msg.sender].isFrozen, "User is frozen");
        require(msg.sender != loan.borrower, "Borrower cannot vote");

        // Check if the voter has sent stablecoins to the borrower
        uint256 totalSentAmount = 0;
        for (uint i = 0; i < gs.users[msg.sender].transactionIDs.length; i++) {
            Schema.Transaction storage tx = gs.transactions[gs.users[msg.sender].transactionIDs[i]];
            if (tx.receiver == loan.borrower) {
                totalSentAmount += tx.amount;
            }
        }
        require(totalSentAmount >= voteAmount, "Insufficient voting power");

        // Gather ballots
        gs.loanVotes[loanID][msg.sender] += voteAmount;
        loan.totalVotes += voteAmount;
        loan.voteCount++;
    }

    function tallyLoanVotes(uint loanID) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();
        Schema.LoanApplication storage loan = gs.loanApplications[loanID];

        require(loan.loanID == loanID, "Invalid loan ID");

        // Calculate the total voting power of non-frozen, non-borrower stakeholders
        uint256 totalVotingPower = 0;
        for (uint i = 0; i < gs.usersArray.length; i++) {
            address user = gs.usersArray[i];
            if (!gs.users[user].isFrozen && user != loan.borrower) {
                for (uint j = 0; j < gs.users[user].transactionIDs.length; j++) {
                    Schema.Transaction storage tx = gs.transactions[gs.users[user].transactionIDs[j]];
                    if (tx.receiver == loan.borrower) {
                        totalVotingPower += tx.amount;
                    }
                }
            }
        }

        uint256 requiredVotes = totalVotingPower / 2;

        if (loan.totalVotes >= requiredVotes) {
            loan.status = "Approved";
        } else {
            loan.status = "Rejected";
        }

        // Transfer pooled governance tokens from the contract
        governanceToken().transferFrom(address(this), loan.borrower, loan.totalVotes);

        gs.lendingPool -= loan.totalVotes;
    }

    function repayGovernanceToken(uint256 loanID, uint256 amount) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();
        Schema.LoanApplication storage loan = gs.loanApplications[loanID];

        require(loan.loanID == loanID, "Invalid loan ID");
        require(loan.borrower == msg.sender, "Not the borrower");
        require(!gs.users[msg.sender].isFrozen, "User is frozen");

        // Calculate interest
        uint256 interest = (loan.amount * annualInterestRate) / 100;
        uint256 totalRepayAmount = loan.amount + interest;

        require(amount >= totalRepayAmount, "Insufficient amount to cover loan and interest");

        // Check allowance and perform transferFrom
        require(governanceToken().allowance(msg.sender, address(this)) >= totalRepayAmount, "Allowance exceeded");
        governanceToken().transferFrom(msg.sender, address(this), totalRepayAmount);

        loan.status = "Repaid";

        // Update repaid info
        gs.users[msg.sender].repaidWithinYear = true; // Assuming this is set appropriately elsewhere
        gs.users[msg.sender].repaidAmount += amount;

        // Reward logic here
        uint256 reward = (amount * 10) / 100;
        gs.balances[msg.sender] += reward;

        // Update user's credit score and total credit score
        gs.totalCreditScore += reward;
        gs.users[msg.sender].creditScore += reward;
    }
}
