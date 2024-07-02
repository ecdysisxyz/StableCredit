
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "./Schema.sol";
import "./Storage.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract LoanApplicationContract is ReentrancyGuard {
    Storage private _storage;

    constructor(address storageAddress) {
        _storage = Storage(storageAddress);
    }

    function submitLoanApplication(address borrower, uint256 amount) external nonReentrant {
        require(amount > 0, "Invalid amount");

        Schema.GlobalState storage gs = _storage.state();
        require(!gs.users[borrower].isFrozen, "Borrower is frozen");

        uint loanID = gs.loanCounter++;
        gs.loanApplications[loanID] = Schema.LoanApplication({
            loanID: loanID,
            borrower: borrower,
            amount: amount,
            status: "Pending",
            fee: (amount * gs.feeRate) / 100
        });

        gs.users[borrower].loanApplicationIDs.push(loanID);
    }
}

