// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./Schema.sol";
import "./Storage.sol";

contract Unfreeze {
    modifier nonReentrant() {
        Schema.GlobalState storage gs = Storage.state();
        require(!gs.initialized, "ReentrancyGuard: reentrant call");
        gs.initialized = true;
        _;
        gs.initialized = false;
    }

    function proposeUnfreeze(address user) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();
        require(gs.users[user].isFrozen, "User is not frozen");

        uint proposalID = gs.unfreezeProposalCounter++;
        gs.unfreezeProposals[proposalID] = Schema.UnfreezeProposal({
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

    function voteOnUnfreeze(uint proposalID) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();
        Schema.UnfreezeProposal storage proposal = gs.unfreezeProposals[proposalID];

        require(proposal.proposalID == proposalID, "Invalid proposal ID");
        require(gs.users[msg.sender].isStaked, "Only staked users can vote");
        require(!gs.unfreezeVotes[proposalID][msg.sender], "Already voted");

        gs.unfreezeVotes[proposalID][msg.sender] = true;
        proposal.totalVotes += gs.users[msg.sender].governanceTokensStaked;
        proposal.voteCount++;

        if (proposal.totalVotes > (gs.totalSupply / 2)) {
            proposal.isApproved = true;
            gs.users[proposal.proposedUser].isFrozen = false;
        }
    }
}

