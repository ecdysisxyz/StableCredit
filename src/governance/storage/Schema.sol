// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

library Schema {
    struct GlobalState {
        mapping(address => User) users;
        mapping(uint => Stake) stakes;
        uint stakeCounter;
        uint totalSupply;
        mapping(address => uint) balances;
        mapping(address => mapping(address => uint)) allowances;
        bool initialized;
        string name;
        string symbol;
        uint8 decimals;
    }

    struct User {
        address userID;
        uint governanceTokensStaked;
    }

    struct Stake {
        uint stakeID;
        address staker;
        uint amount;
        uint startTime;
        uint endTime;
        bool isWithdrawn;
    }
}

