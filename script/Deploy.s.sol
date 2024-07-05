// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { MCDevKit } from "@devkit/MCDevKit.sol";
import { MCScript } from "@devkit/MCScript.sol";

import { Stablecoin } from "../src/main/functions/Stablecoin.sol";
import { CDP } from "../src/main/functions/CDP.sol";
import { Initialize as CDPInitialize } from "../src/main/functions/Initialize.sol";


import { GovernanceToken } from "../src/governance/functions/GovernanceToken.sol";
import { Stake } from "../src/governance/functions/Stake.sol";
import { Initialize as GovenanceInitialize } from "../src/main/functions/Initialize.sol";

contract Deployment is MCScript {
    function run() public startBroadcastWith("DEPLOYER_PRIV_KEY") {
        
        // Deal some initial ether to the deployer address
        vm.deal(deployer, 100 ether);

        // Initialize the meta contract context
        mc.init("StableCredit");

        // Use the deployed contracts with the meta contract
        mc.use("Stablecoin", Stablecoin);
        mc.use("CDP", CDP);
        mc.use("Initialize", CDPInitialize);

        // Deploy the meta contract
        address proxy1 = mc.deploy().toProxyAddress();
        console2.log("Meta contract deployed at:", proxy1);
        
        // Initialize the contract
        CDPInitialize(proxy1).initialize();

        // Save the addresses to the .env file for further use
        bytes memory encodedData1 = abi.encodePacked(
            "PROXY_ADDR=", vm.toString(address(proxy1)), "\n" // Adjusted for proxy address
        );
        vm.writeLine(
            string(
                abi.encodePacked(vm.projectRoot(), "/.env")
            ),
            string(encodedData1)
        );


        mc.init("SCT");

        // Use the deployed contracts with the meta contract
        mc.use("GovernanceToken", GovernanceToken);
        mc.use("Stake", Stake);
        mc.use("Initialize", GovenanceInitialize);

        // Deploy the meta contract
        address proxy2 = mc.deploy().toProxyAddress();
        console2.log("Meta contract deployed at:", proxy2);
        
        // Initialize the contract
        GovenanceInitialize(proxy2).initialize();

        // Save the addresses to the .env file for further use
        bytes memory encodedData2 = abi.encodePacked(
            "PROXY_ADDR=", vm.toString(address(proxy2)), "\n" // Adjusted for proxy address
        );
        vm.writeLine(
            string(
                abi.encodePacked(vm.projectRoot(), "/.env")
            ),
            string(encodedData2)
        );

    }
}
