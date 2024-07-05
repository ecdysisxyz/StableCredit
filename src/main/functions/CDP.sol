// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { Schema as ERC20Schema } from "ecdysisxyz/ERC20/src/main/storage/Schema.sol";
import { Storage as ERC20Storage } from "ecdysisxyz/ERC20/src/main/storage/Storage.sol";
import { Schema } from "../storage/Schema.sol";
import { Storage } from "../storage/Storage.sol";
import "./PriceConsumer.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CDP {
    modifier nonReentrant() {
        Schema.GlobalState storage $cdp = Storage.state();
        require(!$cdp.initialized, "ReentrancyGuard: reentrant call");
        $cdp.initialized = true;
        _;
        $cdp.initialized = false;
    }

    function deposit(address user, uint256 amount) external nonReentrant {
        Schema.GlobalState storage $cdp = Storage.state();
        IERC20 collateralToken = IERC20($cdp.collateralToken);

        require(amount > 0, "Invalid amount");
        require(collateralToken.transferFrom(msg.sender, address(this), amount), "Collateral transfer failed");

        $cdp.balances[user] += amount;
        $cdp.totalSupply += amount;

        _updatePriorityRegistry(user);
    }

    function borrow(address borrower, uint256 amount) external nonReentrant {
        Schema.GlobalState storage $cdp = Storage.state();
        ERC20Schema.GlobalState storage $erc20 = ERC20Storage.state();

        require(amount > 0, "Invalid amount");
        require($cdp.users[borrower].isActive, "User is not active");

        IERC20 collateralToken = IERC20($cdp.collateralToken);
        uint256 collateral = collateralToken.balanceOf(address(this));
        uint256 collateralPrice = PriceConsumer(address(this)).getLatestPrice();
        require(collateralPrice > 0, "Invalid price");

        uint256 maxBorrow = (collateral * collateralPrice) / ($cdp.minimumCollateralizationRatio * 1e18);

        require(amount <= maxBorrow, "Insufficient collateral");

        $erc20.balances[borrower] += amount;
        $erc20.totalSupply += amount;

        $cdp.cdps[borrower].debt += amount;

        _updatePriorityRegistry(borrower);
    }

    function repay(address borrower, uint256 amount) external nonReentrant {
        Schema.GlobalState storage $cdp = Storage.state();
        ERC20Schema.GlobalState storage $erc20 = ERC20Storage.state();

        require(amount > 0, "Invalid amount");
        require($erc20.balances[borrower] >= amount, "Insufficient balance");

        $erc20.balances[borrower] -= amount;
        $erc20.totalSupply -= amount;
        $cdp.cdps[borrower].debt -= amount;

        uint256 reward = (amount * 10) / 100;
        $erc20.balances[borrower] += reward;
        $cdp.totalCreditScore += reward;
        $cdp.users[borrower].creditScore += reward;

        _updatePriorityRegistry(borrower);
    }

    function withdraw(address user, uint256 amount) external nonReentrant {
        Schema.GlobalState storage $cdp = Storage.state();
        ERC20Schema.GlobalState storage $erc20 = ERC20Storage.state();
        IERC20 collateralToken = IERC20($cdp.collateralToken);

        require(amount > 0, "Invalid amount");
        require($erc20.balances[user] >= amount, "Insufficient balance");

        $erc20.balances[user] -= amount;
        $erc20.totalSupply -= amount;

        require(collateralToken.transfer(user, amount), "Collateral transfer failed");

        _updatePriorityRegistry(user);
    }

    function redeem(uint256 amount) external nonReentrant {
        Schema.GlobalState storage $cdp = Storage.state();
        ERC20Schema.GlobalState storage $erc20 = ERC20Storage.state();
        IERC20 collateralToken = IERC20($cdp.collateralToken);
        uint256 collateralPrice = PriceConsumer(address(this)).getLatestPrice();
        require(collateralPrice > 0, "Invalid price");

        uint256 remainingAmount = amount;
        uint256 totalCollateralRedeemed = 0;

        for (uint256 i = 0; i < $cdp.priorityRegistry.length; i++) {
            if (remainingAmount == 0) break;
            uint256 ICR = $cdp.priorityRegistry[i];

            for (uint256 j = 0; j < $cdp.priorityRegistry[ICR].length; j++) {
                address user = $cdp.priorityRegistry[ICR][j];
                uint256 debt = $cdp.cdps[user].debt;
                uint256 collateral = $cdp.cdps[user].collateral;

                if (remainingAmount <= debt) {
                    $cdp.cdps[user].debt -= remainingAmount;
                    uint256 collateralRedeemed = (remainingAmount * 1e18) / collateralPrice;
                    $cdp.cdps[user].collateral -= collateralRedeemed;
                    totalCollateralRedeemed += collateralRedeemed;
                    remainingAmount = 0;
                    break;
                } else {
                    $cdp.cdps[user].debt = 0;
                    $cdp.cdps[user].collateral = 0;
                    totalCollateralRedeemed += collateral;
                    remainingAmount -= debt;
                }
            }
        }

        require(remainingAmount == 0, "Insufficient debt to redeem");
        require(collateralToken.transfer(msg.sender, totalCollateralRedeemed), "Collateral transfer failed");

        $erc20.balances[msg.sender] -= amount;
    }

    function sweep(uint256 amount) external nonReentrant {
        Schema.GlobalState storage $cdp = Storage.state();
        ERC20Schema.GlobalState storage $erc20 = ERC20Storage.state();
        IERC20 collateralToken = IERC20($cdp.collateralToken);
        uint256 collateralPrice = PriceConsumer(address(this)).getLatestPrice();
        require(collateralPrice > 0, "Invalid price");

        uint256 remainingAmount = amount;
        uint256 totalCollateralSwept = 0;

        for (uint256 i = 0; i < $cdp.priorityRegistry.length; i++) {
            if (remainingAmount == 0) break;
            uint256 ICR = $cdp.priorityRegistry[i];

            for (uint256 j = 0; j < $cdp.priorityRegistry[ICR].length; j++) {
                address user = $cdp.priorityRegistry[ICR][j];
                uint256 debt = $cdp.cdps[user].debt;
                uint256 collateral = $cdp.cdps[user].collateral;

                if (remainingAmount <= debt) {
                    $cdp.cdps[user].debt -= remainingAmount;
                    uint256 collateralSwept = (remainingAmount * 1e18) / collateralPrice;
                    $cdp.cdps[user].collateral -= collateralSwept;
                    totalCollateralSwept += collateralSwept;
                    remainingAmount = 0;
                    break;
                } else {
                    $cdp.cdps[user].debt = 0;
                    $cdp.cdps[user].collateral = 0;
                    totalCollateralSwept += collateral;
                    remainingAmount -= debt;
                }
            }
        }

        require(remainingAmount == 0, "Insufficient debt to sweep");
        require(collateralToken.transfer(msg.sender, totalCollateralSwept), "Collateral transfer failed");

        $erc20.balances[address(this)] -= amount;
    }

    function _updatePriorityRegistry(address user) internal {
        Schema.GlobalState storage $cdp = Storage.state();
        uint256 collateralPrice = PriceConsumer(address(this)).getLatestPrice();
        uint256 debt = $cdp.cdps[user].debt;
        uint256 collateral = $cdp.cdps[user].collateral;

        if (debt > 0 && collateral > 0) {
            uint256 ICR = (collateral * collateralPrice) / debt;
            $cdp.priorityRegistry[ICR].push(user);
        } else {
            for (uint256 i = 0; i < $cdp.priorityRegistry[ICR].length; i++) {
                if ($cdp.priorityRegistry[ICR][i] == user) {
                    $cdp.priorityRegistry[ICR][i] = $cdp.priorityRegistry[ICR][$cdp.priorityRegistry[ICR].length - 1];
                    $cdp.priorityRegistry[ICR].pop();
                    break;
                }
            }
        }
    }
}
