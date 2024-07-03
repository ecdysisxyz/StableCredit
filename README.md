## StableCredit

This repository contains the smart contracts for a decentralized lending protocol built on Ethereum. The protocol allows users to issue and transfer stablecoins, submit loan applications, and vote on freezing or unfreezing users. Governance tokens facilitate the voting process, ensuring a decentralized decision-making mechanism. Additionally, the protocol's factory design allows for the creation of diverse credit economies by specifying different collateral tokens and their respective minimum collateralization ratios (MCP) and oracle feeds.

## Overview

### Features

#### Stablecoin Issuance
Users can issue stablecoins by providing collateral.

#### Loan Applications
Users can submit loan applications, which other users can vote on based on their transaction history.

#### Voting Mechanism
Users with governance tokens can vote to freeze or unfreeze other users.

#### Credit Scoring
The protocol calculates credit scores based on transaction history, which influences voting power.

#### Factory Design
The protocol can generate multiple instances of lending systems with different collateral tokens, MCPs, and price oracles through the factory mechanism.

## User Perspectives

### General User
- **Functionality:** Can deposit, borrow, repay, and withdraw funds.
- **Stablecoin Issuance:** Issue stablecoins by providing a specified ERC-20 token as collateral.
- **Loan Application:** Apply for loans based on credit score.

### Voting-Eligible User
- **Functionality:** Can vote on loan applications and unfreeze proposals.
- **Voting Power:** Determined by transaction history.
- **Loan Votes:** Participate in voting for or against loan applications.
- **Unfreeze Votes:** Vote to unfreeze users based on community consensus.

### Voting-Eligible Super User
- **Functionality:** Can propose governance token minting for lending pool procurement/reward and freeze actions, and vote on them.
- **Staking:** Stake governance tokens to gain voting power and participate in governance.
- **Mint Votes:** Initiate proposals to mint governance tokens and can vote.
- **Freeze Votes:** Initiate proposals to freeze users and can vote.

### Incentivized User
- **Functionality:** Eligible for rewards based on timely loan repayments.
- **Rewards:** Receive additional governance tokens for successful and timely loan repayments.
- **Credit Score Improvement:** Boost credit score through timely repayments.

## Contracts

### Main Bundle

#### Initializer.sol
- **Purpose:** Initializes the protocol with the stablecoin's name, symbol, and decimals.
- **Setup:** Configures the fee rate, collateral token, minimum collateralization ratio, and integrates the PriceConsumer for fetching the latest price.

#### CDPOperations.sol
- **Purpose:** Handles core operations including deposit, borrow, repay, withdraw, redeem, and sweep functions.
- **Functionality:** Manages individual collateralization ratios and updates the priority registry.

#### ERC20Functions.sol
- **Purpose:** Provides basic ERC-20 functions like transfer, approve, transferFrom, balanceOf, allowance, name, symbol, decimals, and totalSupply.
- **Additional Features:** Integrates reputation data handling in transfer and transferFrom functions.

#### Freeze.sol
- **Purpose:** Allows staked users to propose and vote on freezing other users.
- **Impact:** Freezing a user reduces the credit scores of users who transacted with them by 10%.

#### SubmitLoanApplication.sol
- **Purpose:** Manages the submission and voting process for loan applications.
- **Voting Power Calculation:** Based on past transaction amounts.

#### Unfreeze.sol
- **Purpose:** Allows staked users to propose and vote on unfreezing frozen users.

#### Lend.sol
- **Purpose:** Manages the lending pool, minting new governance tokens, and user withdrawals based on credit scores.
- **Loan Repayment:** Handles loan repayments and rewards users for successful repayments.

### Governance Token Bundle

#### GovernanceToken.sol
- **Purpose:** Implements a governance token that can be staked to gain voting power.
- **Voting:** Users can vote to freeze or unfreeze other users.

#### Stake.sol
- **Purpose:** Allows users to stake their governance tokens for a period of 4 years.
- **Staking Benefits:** Increases voting power and participation in governance.

#### Initializer.sol
- **Purpose:** Initializes the governance token with the name, symbol, and decimals.

### Storage

#### Schema.sol (Main Bundle)
- **Purpose:** Defines data structures used by the main protocol.
- **Data Types:** User data, loan applications, mint proposals.

#### Storage.sol (Main Bundle)
- **Purpose:** Provides storage access for the main protocol's state.

#### Schema.sol (Governance Bundle)
- **Purpose:** Defines data structures used by the governance protocol.
- **Data Types:** Balances, allowances, staked balances, voting power, votes.

#### Storage.sol (Governance Bundle)
- **Purpose:** Provides storage access for the governance protocol's state.

## Architecture
The protocol is built using a modular architecture, where each functionality is encapsulated in a separate contract. This approach allows for easier maintenance and upgrades.

## Diagrams
For a detailed overview of the protocol's structure and flow, refer to the UML diagrams in [./docs/uml.md](./docs/uml.md).

---

# Meta Contract Template

Welcome to the Meta Contract Template! This template is your fast track to smart contract development, offering a pre-configured setup with the [Meta Contract](https://github.com/metacontract/mc) framework and essential tools like the [ERC-7201 Storage Location Calculator](https://github.com/metacontract/erc7201). It's designed for developers looking to leverage advanced features and best practices right from the start.

## Quick Start
Ensure you have [Foundry](https://github.com/foundry-rs/foundry) installed, then initialize your project with:
```sh
$ forge init <Your Project Name> -t metacontract/template
```