// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {ReferenceToken} from "../src/tokens/ReferenceToken.sol";

interface IScriptVm {
    function startBroadcast() external;
    function stopBroadcast() external;
}

/// @notice Deployment entrypoint:
///   forge script script/Deploy.s.sol --rpc-url <RPC_URL> --broadcast
contract Deploy {
    IScriptVm private constant vm = IScriptVm(address(uint160(uint256(keccak256("hevm cheat code")))));

    string internal constant TOKEN_NAME = "Sample Token";
    string internal constant TOKEN_SYMBOL = "SMP";
    uint256 internal constant INITIAL_SUPPLY = 1_000_000; // whole tokens
    uint256 internal constant MAX_SUPPLY = 5_000_000;     // whole tokens

    function run() external returns (ReferenceToken token) {
        vm.startBroadcast();
        token = new ReferenceToken(TOKEN_NAME, TOKEN_SYMBOL, INITIAL_SUPPLY, MAX_SUPPLY);
        vm.stopBroadcast();
    }
}
