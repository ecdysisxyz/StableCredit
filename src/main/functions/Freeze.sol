// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./Schema.sol";
import "./Storage.sol";

contract Freeze {
    modifier nonReentrant() {
        Schema.GlobalState storage gs = Storage.state();
        require(!gs.initialized, "ReentrancyGuard: reentrant call");
        gs.initialized = true;
        _;
        gs.initialized = false;
    }

    function proposeFreeze(address user) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();
        require(gs.users[msg.sender].isStaked, "Only staked users can propose freeze");
        require(!gs.users[user].isFrozen, "User is already frozen");

        uint proposalID = gs.freezeProposalCounter++;
        gs.freezeProposals[proposalID] = Schema.FreezeProposal({
            proposalID: proposalID,
            proposedUser: user,
            proposer: msg.sender,
            startTime: block.timestamp,
            endTime: block.timestamp + 1 weeks,
            totalVotes: 0,
            voteCount: 0,
            isApproved: false
        });
    }

    function voteOnFreeze(uint proposalID) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();
        Schema.FreezeProposal storage proposal = gs.freezeProposals[proposalID];

        require(proposal.proposalID == proposalID, "Invalid proposal ID");
        require(gs.users[msg.sender].isStaked, "Only staked users can vote");
        require(!gs.freezeVotes[proposalID][msg.sender], "Already voted");

        gs.freezeVotes[proposalID][msg.sender] = true;
        proposal.totalVotes += gs.users[msg.sender].governanceTokensStaked;
        proposal.voteCount++;

        if (proposal.totalVotes > (gs.totalSupply / 2)) {
            proposal.isApproved = true;
            gs.users[proposal.proposedUser].isFrozen = true;

            // Reduce the credit scores of users who have transacted with the frozen user by 10%
            for (uint i = 0; i < gs.users[proposal.proposedUser].transactionIDs.length; i++) {
                Schema.Transaction storage tx = gs.transactions[gs.users[proposal.proposedUser].transactionIDs[i]];
                if (tx.receiver == proposal.proposedUser) {
                    gs.users[tx.sender].creditScore = (gs.users[tx.sender].creditScore * 90) / 100;
                }
            }
        }
    }
}

