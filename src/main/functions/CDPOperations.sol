// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./Schema.sol";
import "./Storage.sol";
import "./PriceConsumer.sol";

contract CDPOperations {
    modifier nonReentrant() {
        Schema.GlobalState storage gs = Storage.state();
        require(!gs.initialized, "ReentrancyGuard: reentrant call");
        gs.initialized = true;
        _;
        gs.initialized = false;
    }


    function deposit(address user, uint256 amount) external payable nonReentrant {
        Schema.GlobalState storage gs = Storage.state();

        require(amount > 0, "Invalid amount");
        require(msg.value == amount, "Incorrect amount of ETH sent");

        gs.balances[user] += amount;
        gs.totalSupply += amount;

        _updatePriorityRegistry(user);
    }

    function borrow(address borrower, uint256 amount) external payable nonReentrant {
        Schema.GlobalState storage gs = Storage.state();

        require(amount > 0, "Invalid amount");
        require(gs.users[borrower].isActive, "User is not active");

        // Transfer collateral (ETH) to the contract
        require(msg.value > 0, "Insufficient collateral");

        uint ethPrice = PriceConsumer(address(this)).getLatestPrice();
        require(ethPrice > 0, "Invalid price");

        uint collateral = msg.value;
        uint maxBorrow = (collateral * ethPrice) / (gs.MINIMUM_COLLATERALIZATION_RATIO * 1e18); // Ensure the MCR (130%) is applied

        require(amount <= maxBorrow, "Insufficient collateral");

        // Mint StableCoin to the borrower
        gs.balances[borrower] += amount;
        uint fee = (amount * gs.feeRate) / 1000;
        gs.totalSupply += amount - fee;

        // Update CDP
        gs.cdps[borrower].collateral += collateral;
        gs.cdps[borrower].debt += amount;

        // Update Priority Registry
        _updatePriorityRegistry(borrower);
    }

    function repay(address borrower, uint256 amount) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();

        require(amount > 0, "Invalid amount");
        require(gs.balances[borrower] >= amount, "Insufficient balance");

        gs.balances[borrower] -= amount;
        gs.totalSupply -= amount;
        gs.cdps[borrower].debt -= amount;

        uint reward = (amount * 10) / 100;
        gs.balances[borrower] += reward;
        gs.totalCreditScore += reward;
        gs.users[borrower].creditScore += reward;

        // Update Priority Registry
        _updatePriorityRegistry(borrower);
    }

    function withdraw(address user, uint256 amount) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();

        require(amount > 0, "Invalid amount");
        require(gs.balances[user] >= amount, "Insufficient balance");

        gs.balances[user] -= amount;
        gs.totalSupply -= amount;

        payable(user).transfer(amount);

        // Update Priority Registry
        _updatePriorityRegistry(user);
    }

    function redeem(uint256 amount) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();
        uint ethPrice = PriceConsumer(address(this)).getLatestPrice();
        require(ethPrice > 0, "Invalid price");

        uint remainingAmount = amount;
        uint totalCollateralRedeemed = 0;

        for (uint i = 0; i < gs.priorityRegistry.length; i++) {
            if (remainingAmount == 0) break;
            uint ICR = gs.priorityRegistry[i];

            for (uint j = 0; j < gs.priorityRegistry[ICR].length; j++) {
                address user = gs.priorityRegistry[ICR][j];
                uint debt = gs.cdps[user].debt;
                uint collateral = gs.cdps[user].collateral;

                if (remainingAmount <= debt) {
                    gs.cdps[user].debt -= remainingAmount;
                    uint collateralRedeemed = (remainingAmount * 1e18) / ethPrice;
                    gs.cdps[user].collateral -= collateralRedeemed;
                    totalCollateralRedeemed += collateralRedeemed;
                    remainingAmount = 0;
                    break;
                } else {
                    gs.cdps[user].debt = 0;
                    gs.cdps[user].collateral = 0;
                    totalCollateralRedeemed += collateral;
                    remainingAmount -= debt;
                }
            }
        }

        require(remainingAmount == 0, "Insufficient debt to redeem");

        // Transfer the redeemed collateral to the sender
        payable(msg.sender).transfer(totalCollateralRedeemed);
    }

    function sweep(uint256 amount) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();
        uint ethPrice = PriceConsumer(address(this)).getLatestPrice();
        require(ethPrice > 0, "Invalid price");

        uint remainingAmount = amount;
        uint totalCollateralSwept = 0;

        for (uint i = 0; i < gs.priorityRegistry.length; i++) {
            if (remainingAmount == 0) break;
            uint ICR = gs.priorityRegistry[i];

            for (uint j = 0; j < gs.priorityRegistry[ICR].length; j++) {
                address user = gs.priorityRegistry[ICR][j];
                uint debt = gs.cdps[user].debt;
                uint collateral = gs.cdps[user].collateral;

                if (remainingAmount <= debt) {
                    gs.cdps[user].debt -= remainingAmount;
                    uint collateralSwept = (remainingAmount * 1e18) / ethPrice;
                    gs.cdps[user].collateral -= collateralSwept;
                    totalCollateralSwept += collateralSwept;
                    remainingAmount = 0;
                    break;
                } else {
                    gs.cdps[user].debt = 0;
                    gs.cdps[user].collateral = 0;
                    totalCollateralSwept += collateral;
                    remainingAmount -= debt;
                }
            }
        }

        require(remainingAmount == 0, "Insufficient debt to sweep");

        // Transfer the swept collateral to the sender
        payable(msg.sender).transfer(totalCollateralSwept);
    }

    function _updatePriorityRegistry(address user) internal {
        Schema.GlobalState storage gs = Storage.state();
        uint ethPrice = PriceConsumer(address(this)).getLatestPrice();
        uint debt = gs.cdps[user].debt;
        uint collateral = gs.cdps[user].collateral;

        if (debt > 0 && collateral > 0) {
            uint ICR = (collateral * ethPrice) / debt;
            gs.priorityRegistry[ICR].push(user);
        } else {
            for (uint i = 0; i < gs.priorityRegistry[ICR].length; i++) {
                if (gs.priorityRegistry[ICR][i] == user) {
                    gs.priorityRegistry[ICR][i] = gs.priorityRegistry[ICR][gs.priorityRegistry[ICR].length - 1];
                    gs.priorityRegistry[ICR].pop();
                    break;
                }
            }
        }
    }
}

