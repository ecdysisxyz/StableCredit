# StableCredit Protocol - Main Bundle

Welcome to the Main Bundle of the StableCredit Protocol. This bundle contains the core smart contracts for a decentralized lending protocol built on Ethereum. The protocol allows users to issue and transfer stablecoins, submit loan applications, and participate in governance using governance tokens.

## Overview

### Initializer
- The `Initializer.sol` contract serves as a replacement for constructors. It initializes the protocol with the necessary parameters such as the name, symbol, and decimals for the stablecoin, and integrates the price feed for fetching the latest ETH price. This approach ensures flexible and upgradeable contract initialization.

### ERC20 Functionality
- The `ERC20Functions.sol` contract provides all the standard ERC-20 functionalities including `transfer`, `approve`, `transferFrom`, `balanceOf`, `allowance`, `name`, `symbol`, `decimals`, and `totalSupply`. Additionally, it records custom transaction states in `GlobalState`, enabling extended functionalities like credit scoring and transaction history tracking.

### Collateralized Debt Positions (CDP)
- The `CDPOperations.sol` contract manages all operations related to Collateralized Debt Positions (CDPs). This includes functions for `deposit`, `borrow`, `repay`, `withdraw`, `redeem`, and `sweep`. It ensures that users can leverage their collateral to borrow stablecoins and manage their debt positions efficiently.

### Lending with Governance Tokens
- The `Lend.sol` contract allows users to lend their governance tokens and participate in the protocol's lending activities. Users can mint new governance tokens, propose loans, vote on loan proposals, tally votes, and repay loans. The contract ensures that governance tokens are used as collateral for lending, providing a robust credit system.

### Frozen Operations
- The `FrozenOperations.sol` contract handles the protocol's governance actions related to freezing and unfreezing users. Staked users can propose to freeze or unfreeze other users, and these proposals are voted on by the community. The contract ensures that only non-frozen users can participate in voting, maintaining the integrity of the protocol.
