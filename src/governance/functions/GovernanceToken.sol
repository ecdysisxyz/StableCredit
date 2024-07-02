// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "../storage/Schema.sol";
import "../storage/Storage.sol";

contract GovernanceToken {
    modifier nonReentrant() {
        Schema.GlobalState storage gs = Storage.state();
        require(!gs.initialized, "ReentrancyGuard: reentrant call");
        gs.initialized = true;
        _;
        gs.initialized = false;
    }

    function name() external view returns (string memory) {
        Schema.GlobalState storage gs = Storage.state();
        return gs.name;
    }

    function symbol() external view returns (string memory) {
        Schema.GlobalState storage gs = Storage.state();
        return gs.symbol;
    }

    function decimals() external view returns (uint8) {
        Schema.GlobalState storage gs = Storage.state();
        return gs.decimals;
    }

    function totalSupply() external view returns (uint256) {
        Schema.GlobalState storage gs = Storage.state();
        return gs.totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        Schema.GlobalState storage gs = Storage.state();
        return gs.balances[account];
    }

    function approve(address spender, uint256 amount) external nonReentrant returns (bool) {
        Schema.GlobalState storage gs = Storage.state();
        gs.allowances[msg.sender][spender] = amount;
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        Schema.GlobalState storage gs = Storage.state();
        return gs.allowances[owner][spender];
    }

    function transferFrom(address sender, address recipient, uint256 amount) external nonReentrant returns (bool) {
        Schema.GlobalState storage gs = Storage.state();
        require(gs.balances[sender] >= amount, "Insufficient balance");
        require(gs.allowances[sender][msg.sender] >= amount, "Allowance exceeded");

        gs.balances[sender] -= amount;
        gs.balances[recipient] += amount;
        gs.allowances[sender][msg.sender] -= amount;

        return true;
    }

    function transfer(address recipient, uint256 amount) external nonReentrant returns (bool) {
        Schema.GlobalState storage gs = Storage.state();
        require(amount > 0, "Invalid amount");
        require(gs.balances[msg.sender] >= amount, "Insufficient balance");

        gs.balances[msg.sender] -= amount;
        gs.balances[recipient] += amount;

        return true;
    }
}

