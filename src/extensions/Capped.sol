// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {FungibleToken} from "../base/FungibleToken.sol";

/// @title Capped
/// @notice Enforces a hard ceiling on total supply when new tokens are minted.
abstract contract Capped is FungibleToken {
    error CapExceeded(uint256 cap, uint256 attempted);

    uint256 public immutable cap;

    constructor(uint256 cap_) {
        cap = cap_;
    }

    function _move(address from, address to, uint256 amount) internal virtual override {
        super._move(from, to, amount);
        if (from == address(0) && totalSupply() > cap) {
            revert CapExceeded(cap, totalSupply());
        }
    }
}
