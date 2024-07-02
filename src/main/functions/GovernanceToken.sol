
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Schema.sol";
import "./Storage.sol";

contract GovernanceToken is ERC20, ReentrancyGuard {
    Storage private _storage;

    constructor(address storageAddress) ERC20("GovernanceToken", "GT") {
        _storage = Storage(storageAddress);
    }

    function stakeGovernanceToken(uint256 amount) external nonReentrant {
        require(amount > 0, "Invalid amount");
        _transfer(msg.sender, address(this), amount);

        Schema.GlobalState storage gs = _storage.state();
        gs.users[msg.sender].isStaked = true;
        gs.governanceToken.stakedBalances[msg.sender] += amount;
        gs.governanceToken.votingPower[msg.sender] += amount;
    }

    function unstakeGovernanceToken(uint256 amount) external nonReentrant {
        require(amount > 0, "Invalid amount");
        Schema.GlobalState storage gs = _storage.state();
        require(gs.governanceToken.stakedBalances[msg.sender] >= amount, "Insufficient staked balance");

        _transfer(address(this), msg.sender, amount);

        gs.governanceToken.stakedBalances[msg.sender] -= amount;
        gs.governanceToken.votingPower[msg.sender] -= amount;

        if (gs.governanceToken.stakedBalances[msg.sender] == 0) {
            gs.users[msg.sender].isStaked = false;
        }
    }

    function voteToFreezeUser(address user) external nonReentrant {
        Schema.GlobalState storage gs = _storage.state();
        require(gs.users[msg.sender].isStaked, "Only staked users can vote");
        require(!gs.users[user].isFrozen, "User is already frozen");

        gs.governanceToken.votes[msg.sender][user] = true;

        // Tally votes
        uint256 totalVotes = 0;
        for (uint i = 0; i < gs.users.length; i++) {
            if (gs.governanceToken.votes[gs.users[i].userID][user]) {
                totalVotes += gs.governanceToken.votingPower[gs.users[i].userID];
            }
        }

        if (totalVotes > (gs.governanceToken.totalSupply / 2)) {
            _freezeUser(user);
        }
    }

    function _freezeUser(address user) internal {
        Schema.GlobalState storage gs = _storage.state();
        gs.users[user].isFrozen = true;

        // Decrease credit scores of users who have transacted with the frozen user
        for (uint i = 0; i < gs.users[user].transactionIDs.length; i++) {
            Schema.Transaction storage tx = gs.transactions[gs.users[user].transactionIDs[i]];
            if (tx.receiver == user) {
                gs.users[tx.sender].creditScore = (gs.users[tx.sender].creditScore * 90) / 100;
            }
        }
    }

    function unfreezeUser(address user) external nonReentrant {
        Schema.GlobalState storage gs = _storage.state();
        require(gs.users[user].isFrozen, "User is not frozen");
        require(gs.users[msg.sender].isStaked, "Only staked users can vote");

        gs.governanceToken.votes[msg.sender][user] = false;

        // Tally votes
        uint256 totalVotes = 0;
        for (uint i = 0; i < gs.users.length; i++) {
            if (gs.governanceToken.votes[gs.users[i].userID][user]) {
                totalVotes += gs.governanceToken.votingPower[gs.users[i].userID];
            }
        }

        if (totalVotes <= (gs.governanceToken.totalSupply / 2)) {
            gs.users[user].isFrozen = false;
        }
    }
}

