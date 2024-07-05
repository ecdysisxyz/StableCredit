// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

library Schema {
    /// @custom:storage-location erc7201:ecdysisxyz.stablecredit.globalstate
    struct GlobalState {
        bool initialized;
        address governanceTokenAddress;
        address collateralToken;
        uint256 feeRate;
        uint256 lastGoodPrice;
        uint256 minimumCollateralizationRatio;
        uint256 totalCreditScore;
        uint256 lendingPool;
        uint256 loanCounter;
        uint256 mintProposalCounter;
        mapping(address => User) users;
        mapping(address => CDP) cdps;
        mapping(uint256 => LoanApplication) loanApplications;
        mapping(uint256 => MintProposal) mintProposals;
        address[] priorityRegistry;
        mapping(uint256 => mapping(address => bool)) loanVotes;
        mapping(uint256 => Transaction) transactions;
        mapping(address => uint256[]) transactionIDs;
        uint256 transactionCounter;
        address priceFeed;
    }

    struct User {
        bool isFrozen;
        bool isActive;
        bool isStaked;
        uint256 creditScore;
        uint256[] loanApplicationIDs;
        bool repaidWithinYear;
        uint256 repaidAmount;
    }

    struct CDP {
        uint256 collateral;
        uint256 debt;
    }

    struct LoanApplication {
        uint256 loanID;
        address borrower;
        uint256 amount;
        string status;
        uint256 fee;
        uint256 totalVotes;
        uint256 voteCount;
    }

    struct Transaction {
        uint256 transactionID;
        address sender;
        address receiver;
        uint256 amount;
        uint256 timestamp;
    }

    struct FreezeProposal {
        uint256 proposalID;
        address proposedUser;
        address proposer;
        uint256 startTime;
        uint256 endTime;
        uint256 totalVotes;
        uint256 voteCount;
        bool isApproved;
    }

    struct UnfreezeProposal {
        uint256 proposalID;
        address proposedUser;
        address proposer;
        uint256 startTime;
        uint256 endTime;
        uint256 totalVotes;
        uint256 voteCount;
        bool isApproved;
    }

    struct MintProposal {
        uint256 proposalID;
        address proposer;
        uint256 amount;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
        mapping(address => bool) voters;
    }
}
