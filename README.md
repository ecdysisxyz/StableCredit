## StableCredit

This repository contains the smart contracts for a decentralized lending protocol built on Ethereum. The protocol allows users to issue and transfer stablecoins, submit loan applications, and vote on freezing or unfreezing users. Governance tokens are used to facilitate the voting process, ensuring a decentralized decision-making mechanism.

## Overview

### Features

#### Stablecoin Issuance
Users can issue stablecoins by providing collateral.

#### Loan Applications
Users can submit loan applications, which can be voted on by other users based on their transaction history.

#### Voting Mechanism
Users with governance tokens can vote to freeze or unfreeze other users.

#### Credit Scoring
The protocol calculates credit scores based on transaction history, which influences voting power.

## Contracts

### Main Bundle

#### Initializer.sol
This contract initializes the protocol with the name, symbol, and decimals for the stablecoin. It also sets up the fee rate, minimum collateralization ratio, and integrates the PriceConsumer for fetching the latest ETH price.

#### CDPOperations.sol
This contract handles the core operations of the protocol, including deposit, borrow, repay, withdraw, redeem, and sweep functions. It also updates the priority registry based on the individual collateralization ratios.

#### ERC20Functions.sol
This contract provides the basic ERC-20 functions including transfer, approve, transferFrom, balanceOf, allowance, name, symbol, decimals, and totalSupply. Transfer and transferFrom also handle reputation data.

#### Freeze.sol
This contract allows staked users to propose and vote on freezing other users. If a user is frozen, the credit scores of users who transacted with the frozen user are reduced by 10%.

#### SubmitLoanApplication.sol
This contract handles the submission and voting process for loan applications. It calculates voting power based on past transaction amounts.

#### Unfreeze.sol
This contract allows staked users to propose and vote on unfreezing frozen users.

#### Lend.sol
This contract manages the lending pool, allowing users to mint new governance tokens and withdraw based on their share of the total credit score. It also handles loan repayment and rewards users for successful repayments.

### Governance Token Bundle

#### GovernanceToken.sol
This contract implements a governance token that can be staked to gain voting power. Users can vote to freeze or unfreeze other users.

#### Stake.sol
This contract allows users to stake their governance tokens for a period of 4 years.

#### Initializer.sol
This contract initializes the governance token with the name, symbol, and decimals.

### Storage

#### Schema.sol (Main Bundle)
This library defines the data structures used by the main protocol, including user data, loan applications

#### Storage.sol (Main Bundle)
This library provides storage access for the main protocol's state.

#### Schema.sol (Governance Bundle)
This library defines the data structures used by the governance protocol, including balances, allowances, staked balances, voting power, and votes.

#### Storage.sol (Governance Bundle)
This library provides storage access for the governance protocol's state.

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

