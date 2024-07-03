// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

library Schema {
    struct GlobalState {
        bool initialized;
        string name;
        string symbol;
        uint8 decimals;
        address governanceTokenAddress;
        uint256 feeRate;
        uint256 lastGoodPrice;
        uint256 MINIMUM_COLLATERALIZATION_RATIO;
        uint256 totalCreditScore;
        uint256 lendingPool;
        uint256 totalSupply;
        uint256 loanCounter;
        uint256 mintProposalCounter;
        mapping(address => User) users;
        mapping(uint => LoanApplication) loanApplications;
        mapping(uint => MintProposal) mintProposals;
        mapping(address => uint256[]) usersList;
        mapping(address => mapping(uint => bool)) loanVotes;
        mapping(address => mapping(address => uint)) allowances;
    }

    struct User {
        bool isFrozen;
        bool isActive;
        bool isStaked;
        uint256 creditScore;
        uint256[] loanApplicationIDs;
        uint256[] transactionIDs;
        bool repaidWithinYear;
        uint256 repaidAmount;
    }

    struct LoanApplication {
        uint loanID;
        address borrower;
        uint256 amount;
        string status;
        uint256 fee;
        uint256 totalVotes;
        uint256 voteCount;
    }

    struct Transaction {
        uint transactionID;
        address sender;
        address receiver;
        uint256 amount;
        uint256 timestamp;
    }

    struct FreezeProposal {
        uint proposalID;
        address proposedUser;
        address proposer;
        uint256 startTime;
        uint256 endTime;
        uint256 totalVotes;
        uint256 voteCount;
        bool isApproved;
    }

    struct UnfreezeProposal {
        uint proposalID;
        address proposedUser;
        address proposer;
        uint256 startTime;
        uint256 endTime;
        uint256 totalVotes;
        uint256 voteCount;
        bool isApproved;
    }

    struct MintProposal {
        uint proposalID;
        address proposer;
        uint256 amount;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
        mapping(address => bool) voters;
    }
}
