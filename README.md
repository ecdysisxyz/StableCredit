# StableCredit
This repository contains the smart contracts for a decentralized lending protocol built on Ethereum. The protocol allows users to issue and transfer stablecoins, submit loan applications, and vote on freezing or unfreezing users. Governance tokens are used to facilitate the voting process, ensuring a decentralized decision-making mechanism.

# Overview
## Features
Stablecoin Issuance: Users can issue stablecoins by providing collateral.
Loan Applications: Users can submit loan applications, which can be voted on by other users based on their transaction history.
Voting Mechanism: Users with governance tokens can vote to freeze or unfreeze other users.
Credit Scoring: The protocol calculates credit scores based on transaction history, which influences voting power.
Contracts
ERC20Functions.sol
This contract provides the basic ERC-20 functions including transfer, approve, transferFrom, balanceOf, allowance, name, symbol, decimals, and totalSupply.

Freeze.sol
This contract allows staked users to propose and vote on freezing other users. If a user is frozen, the credit scores of users who transacted with the frozen user are reduced by 10%.

GovernanceToken.sol
This contract implements a governance token that can be staked to gain voting power. Users can vote to freeze or unfreeze other users.

Initializer.sol
This contract initializes the protocol with the name, symbol, and decimals for the stablecoin.

IssueStableCoin.sol
This contract allows users to issue stablecoins by providing collateral. The stablecoins are minted and added to the user's balance.

LoanApplicationContract.sol
This contract allows users to submit loan applications. Other users can vote on these applications based on their transaction history with the borrower.

### StableCoin.sol
This contract implements the stablecoin using the ERC-20 standard, with additional logic for issuing coins based on provided collateral.

### SubmitLoanApplication.sol
This contract handles the submission and voting process for loan applications. It calculates voting power based on past transaction amounts.

### Transfer.sol
This contract handles the transfer of stablecoins between users, updating credit scores and recording transaction history.

## Storage
### Schema.sol
This library defines the data structures used by the protocol, including user data, loan applications, transactions, freeze proposals, and unfreeze proposals.

### Storage.sol
This library provides storage access for the protocol's state.

# Architecture
The protocol is built using a modular architecture, where each functionality is encapsulated in a separate contract. This approach allows for easier maintenance and upgrades.

# Diagrams
For a detailed overview of the protocol's structure and flow, refer to the UML diagrams in ./docs/uml.md.

---

# Meta Contract Template
Welcome to the Meta Contract Template! This template is your fast track to smart contract development, offering a pre-configured setup with the [Meta Contract](https://github.com/metacontract/mc) framework and essential tools like the [ERC-7201 Storage Location Calculator](https://github.com/metacontract/erc7201). It's designed for developers looking to leverage advanced features and best practices right from the start.

## Quick Start
Ensure you have [Foundry](https://github.com/foundry-rs/foundry) installed, then initialize your project with:
```sh
$ forge init <Your Project Name> -t metacontract/template
```
This command sets up your environment with all the benefits of the meta contract framework, streamlining your development process.

## Features
- Pre-integrated with meta contract for optimal smart contract development with highly flexible upgradeability & maintainability.
- Includes ERC-7201 Storage Location Calculator for calculating storage locations based on ERC-7201 names for enhanced efficiency.
- Ready-to-use project structure for immediate development start.

For detailed documentation and further guidance, visit [Meta Contract Book](https://mc-book.ecdysis.xyz/).

Start building your decentralized applications with meta contract today and enjoy a seamless development experience!
