// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./Schema.sol";
import "./Storage.sol";
import "./PriceConsumer.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CDPOperations {
    modifier nonReentrant() {
        Schema.GlobalState storage gs = Storage.state();
        require(!gs.initialized, "ReentrancyGuard: reentrant call");
        gs.initialized = true;
        _;
        gs.initialized = false;
    }

    function deposit(address user, uint256 amount) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();
        IERC20 collateralToken = IERC20(gs.collateralToken);

        require(amount > 0, "Invalid amount");
        require(collateralToken.transferFrom(msg.sender, address(this), amount), "Collateral transfer failed");

        gs.balances[user] += amount;
        gs.totalSupply += amount;

        _updatePriorityRegistry(user);
    }

    function borrow(address borrower, uint256 amount) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();

        require(amount > 0, "Invalid amount");
        require(gs.users[borrower].isActive, "User is not active");

        IERC20 collateralToken = IERC20(gs.collateralToken);
        uint256 collateral = collateralToken.balanceOf(address(this));
        uint256 ethPrice = PriceConsumer(address(this)).getLatestPrice();
        require(ethPrice > 0, "Invalid price");

        uint256 maxBorrow = (collateral * ethPrice) / (gs.MINIMUM_COLLATERALIZATION_RATIO * 1e18);

        require(amount <= maxBorrow, "Insufficient collateral");

        gs.balances[borrower] += amount;
        uint256 fee = (amount * gs.feeRate) / 1000;
        gs.totalSupply += amount - fee;

        gs.cdps[borrower].collateral += collateral;
        gs.cdps[borrower].debt += amount;

        _updatePriorityRegistry(borrower);
    }

    function repay(address borrower, uint256 amount) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();

        require(amount > 0, "Invalid amount");
        require(gs.balances[borrower] >= amount, "Insufficient balance");

        gs.balances[borrower] -= amount;
        gs.totalSupply -= amount;
        gs.cdps[borrower].debt -= amount;

        uint256 reward = (amount * 10) / 100;
        gs.balances[borrower] += reward;
        gs.totalCreditScore += reward;
        gs.users[borrower].creditScore += reward;

        _updatePriorityRegistry(borrower);
    }

    function withdraw(address user, uint256 amount) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();
        IERC20 collateralToken = IERC20(gs.collateralToken);

        require(amount > 0, "Invalid amount");
        require(gs.balances[user] >= amount, "Insufficient balance");

        gs.balances[user] -= amount;
        gs.totalSupply -= amount;

        require(collateralToken.transfer(user, amount), "Collateral transfer failed");

        _updatePriorityRegistry(user);
    }

    function redeem(uint256 amount) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();
        IERC20 collateralToken = IERC20(gs.collateralToken);
        uint256 ethPrice = PriceConsumer(address(this)).getLatestPrice();
        require(ethPrice > 0, "Invalid price");

        uint256 remainingAmount = amount;
        uint256 totalCollateralRedeemed = 0;

        for (uint256 i = 0; i < gs.priorityRegistry.length; i++) {
            if (remainingAmount == 0) break;
            uint256 ICR = gs.priorityRegistry[i];

            for (uint256 j = 0; j < gs.priorityRegistry[ICR].length; j++) {
                address user = gs.priorityRegistry[ICR][j];
                uint256 debt = gs.cdps[user].debt;
                uint256 collateral = gs.cdps[user].collateral;

                if (remainingAmount <= debt) {
                    gs.cdps[user].debt -= remainingAmount;
                    uint256 collateralRedeemed = (remainingAmount * 1e18) / ethPrice;
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
        require(collateralToken.transfer(msg.sender, totalCollateralRedeemed), "Collateral transfer failed");
    }

    function sweep(uint256 amount) external nonReentrant {
        Schema.GlobalState storage gs = Storage.state();
        IERC20 collateralToken = IERC20(gs.collateralToken);
        uint256 ethPrice = PriceConsumer(address(this)).getLatestPrice();
        require(ethPrice > 0, "Invalid price");

        uint256 remainingAmount = amount;
        uint256 totalCollateralSwept = 0;

        for (uint256 i = 0; i < gs.priorityRegistry.length; i++) {
            if (remainingAmount == 0) break;
            uint256 ICR = gs.priorityRegistry[i];

            for (uint256 j = 0; j < gs.priorityRegistry[ICR].length; j++) {
                address user = gs.priorityRegistry[ICR][j];
                uint256 debt = gs.cdps[user].debt;
                uint256 collateral = gs.cdps[user].collateral;

                if (remainingAmount <= debt) {
                    gs.cdps[user].debt -= remainingAmount;
                    uint256 collateralSwept = (remainingAmount * 1e18) / ethPrice;
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
        require(collateralToken.transfer(msg.sender, totalCollateralSwept), "Collateral transfer failed");
    }

    function _updatePriorityRegistry(address user) internal {
        Schema.GlobalState storage gs = Storage.state();
        uint256 ethPrice = PriceConsumer(address(this)).getLatestPrice();
        uint256 debt = gs.cdps[user].debt;
        uint256 collateral = gs.cdps[user].collateral;

        if (debt > 0 && collateral > 0) {
            uint256 ICR = (collateral * ethPrice) / debt;
            gs.priorityRegistry[ICR].push(user);
        } else {
            for (uint256 i = 0; i < gs.priorityRegistry[ICR].length; i++) {
                if (gs.priorityRegistry[ICR][i] == user) {
                    gs.priorityRegistry[ICR][i] = gs.priorityRegistry[ICR][gs.priorityRegistry[ICR].length - 1];
                    gs.priorityRegistry[ICR].pop();
                    break;
                }
            }
        }
    }
}
