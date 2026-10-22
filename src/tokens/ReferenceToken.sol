// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {FungibleToken} from "../base/FungibleToken.sol";
import {Administered} from "../extensions/Administered.sol";
import {Burnable} from "../extensions/Burnable.sol";
import {Pausable} from "../extensions/Pausable.sol";
import {Capped} from "../extensions/Capped.sol";

/// @title ReferenceToken
/// @notice Example composition: base token + admin + burn + pause + supply cap.
contract ReferenceToken is FungibleToken, Administered, Burnable, Pausable, Capped {
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply,
        uint256 maxSupply
    )
        FungibleToken(name_, symbol_, 18)
        Administered(msg.sender)
        Capped(maxSupply * 1e18)
    {
        _mint(msg.sender, initialSupply * 1e18);
    }

    /// @notice Admin-only issuance, bounded by the cap.
    function mint(address to, uint256 amount) external onlyAdmin {
        _mint(to, amount);
    }

    // Resolve the linearised `_move` hook across Pausable and Capped.
    function _move(address from, address to, uint256 amount)
        internal
        override(FungibleToken, Pausable, Capped)
    {
        super._move(from, to, amount);
    }
}
