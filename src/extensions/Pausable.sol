// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {FungibleToken} from "../base/FungibleToken.sol";
import {Administered} from "./Administered.sol";

/// @title Pausable
/// @notice Admin-controlled circuit breaker applied to every balance movement.
abstract contract Pausable is FungibleToken, Administered {
    bool public paused;

    event Paused(address indexed by);
    event Unpaused(address indexed by);

    function pause() external onlyAdmin {
        if (paused) revert TransfersPaused();
        paused = true;
        emit Paused(msg.sender);
    }

    function unpause() external onlyAdmin {
        if (!paused) revert TransfersNotPaused();
        paused = false;
        emit Unpaused(msg.sender);
    }

    function _move(address from, address to, uint256 amount) internal virtual override {
        if (paused) revert TransfersPaused();
        super._move(from, to, amount);
    }
}
