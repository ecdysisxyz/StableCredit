// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

library Schema {
    struct GlobalState {
        mapping(address => uint) balances;
        mapping(address => mapping(address => uint)) allowances;
        mapping(address => uint) stakedBalances;
        mapping(address => uint) votingPower;
        mapping(address => mapping(address => bool)) votes;
        uint totalSupply;
        uint totalStaked;
        bool initialized;
        string name;
        string symbol;
        uint8 decimals;
    }
}

