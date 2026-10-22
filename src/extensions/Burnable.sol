// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {FungibleToken} from "../base/FungibleToken.sol";

/// @title Burnable
/// @notice Lets holders destroy their own tokens, or tokens they hold an allowance for.
abstract contract Burnable is FungibleToken {
    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function burnFrom(address holder, uint256 amount) external {
        _spendAllowance(holder, msg.sender, amount);
        _burn(holder, amount);
    }
}
