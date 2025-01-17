// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 */
library ERC7546Clones {
    /**
     * @dev A clone instance deployment failed.
     */
    error ERC7546FailedCreateClone();

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address dictionary, bytes memory initData) internal returns (address instance) {
        bytes memory _deploymentBytecode = hex"61022238036102225f395f51803b61008057505f5f525f6020525f6040525f6060527f4e4f4e5f434f4e54524143540000000000000000000000000000000000000000600c600061007d577f08c379a0000000000000000000000000000000000000000000000000000000005f52602060045260245260445260805ffd5b50505b807f267691be3525af8a813d30db0c9e2bad08f63baecf6dceb85e2cf3676cff56f455807fa657f2ad315cf3bb35cf1964158da75c3f334481df05a4a1644b2376b17a59b25f5fa26040516101395750346100da576101a0565b7f455243313936375f4e6f6e50617961626c65000000000000000000000000000060126000610136577f08c379a0000000000000000000000000000000000000000000000000000000005f52602060045260245260445260805ffd5b50505b6060517fffffffff000000000000000000000000000000000000000000000000000000001663dc9cc64560e01b5f526004525f5f60245f845afa61018057503d5f5f3e3d5ffd5b503d5f5f3e5f515f5f6040516060845af461019e57503d5f5f3e3d5ffd5b505b6077806101ab3d393df33615610073577f267691be3525af8a813d30db0c9e2bad08f63baecf6dceb85e2cf3676cff56f45460045f5f375f5163dc9cc64560e01b5f526004525f5f60245f845afa61005057503d5f5f3e3d5ffd5b503d5f5f3e5f51365f80375f803681845af43d5f803e1561006f573d5ff35b3d5ffd5b5f5ff3";
        bytes memory _constructorArgs = bytes.concat(
            abi.encode(address(dictionary)),
            abi.encode(bytes(initData))
        );
        bytes memory _initCode = bytes.concat(_deploymentBytecode, _constructorArgs);
        // console2.logBytes(_initCode);
        /// @solidity memory-safe-assembly
        assembly {
            instance := create(0, add(_initCode, 0x20), mload(_initCode))
        }
        if (instance == address(0)) {
            revert ERC7546FailedCreateClone();
        }
    }

}