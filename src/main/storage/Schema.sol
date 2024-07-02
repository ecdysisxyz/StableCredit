// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

library Schema {
    struct GlobalState {
        mapping(address => User) users;
        mapping(uint => LoanApplication) loanApplications;
        mapping(uint => Transaction) transactions;
        mapping(uint => FreezeProposal) freezeProposals;
        mapping(uint => UnfreezeProposal) unfreezeProposals;
        mapping(address => uint) balances;
        mapping(address => mapping(address => uint)) allowances;
        mapping(uint => mapping(address => uint)) loanVotes; // Loan ID => (Voter => Vote Amount)
        mapping(uint => mapping(address => bool)) freezeVotes; // Freeze Proposal ID => (Voter => Voted)
        mapping(uint => mapping(address => bool)) unfreezeVotes; // Unfreeze Proposal ID => (Voter => Voted)
        uint loanCounter;
        uint transactionCounter;
        uint freezeProposalCounter;
        uint unfreezeProposalCounter;
        uint totalSupply;
        uint totalCreditScore; // 全体の与信値の合計
        uint lendingPool; // レンディングプールのガバナンストークンの量
        uint feeRate;
        bool initialized;
        string name;
        string symbol;
        uint8 decimals;
    }

    struct User {
        address userID;
        uint creditScore;
        bool isActive;
        bool isFrozen;
        bool isStaked;
        uint governanceTokensStaked;
        uint[] loanApplicationIDs;
        uint[] transactionIDs;
    }

    struct LoanApplication {
        uint loanID;
        address borrower;
        uint amount;
        string status;
        uint fee;
        uint totalVotes;
        uint voteCount;
    }

    struct Transaction {
        uint transactionID;
        address sender;
        address receiver;
        uint amount;
        uint timestamp;
    }

    struct FreezeProposal {
        uint proposalID;
        address proposedUser;
        address proposer;
        uint startTime;
        uint endTime;
        uint totalVotes;
        uint voteCount;
        bool isApproved;
    }

    struct UnfreezeProposal {
        uint proposalID;
        address proposedUser;
        address proposer;
        uint startTime;
        uint endTime;
        uint totalVotes;
        uint voteCount;
        bool isApproved;
    }
}

