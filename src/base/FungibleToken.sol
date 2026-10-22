// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {IFungibleToken} from "../interfaces/IFungibleToken.sol";
import {TokenErrors} from "../interfaces/TokenErrors.sol";

/// @title FungibleToken
/// @notice Dependency-free ERC-20 base. All balance movement goes through `_move`,
///         which is the single hook extensions override to add behaviour.
abstract contract FungibleToken is IFungibleToken, TokenErrors {
    string private _tokenName;
    string private _tokenSymbol;
    uint8 private immutable _decimals;

    uint256 private _supply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        _tokenName = name_;
        _tokenSymbol = symbol_;
        _decimals = decimals_;
    }

    // ───────────── metadata ─────────────
    function name() public view returns (string memory) { return _tokenName; }
    function symbol() public view returns (string memory) { return _tokenSymbol; }
    function decimals() public view returns (uint8) { return _decimals; }

    // ───────────── views ─────────────
    function totalSupply() public view returns (uint256) { return _supply; }
    function balanceOf(address account) public view returns (uint256) { return _balances[account]; }
    function allowance(address holder, address spender) public view returns (uint256) {
        return _allowances[holder][spender];
    }

    // ───────────── user actions ─────────────
    function transfer(address to, uint256 amount) public returns (bool) {
        if (to == address(0)) revert ZeroAddress();
        _move(msg.sender, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        if (to == address(0)) revert ZeroAddress();
        _spendAllowance(from, msg.sender, amount);
        _move(from, to, amount);
        return true;
    }

    // ───────────── internals ─────────────

    /// @dev The one place balances change. `from == 0` means mint, `to == 0` means burn.
    function _move(address from, address to, uint256 amount) internal virtual {
        if (from == address(0)) {
            _supply += amount;
        } else {
            uint256 bal = _balances[from];
            if (bal < amount) revert InsufficientBalance(from, bal, amount);
            unchecked { _balances[from] = bal - amount; }
        }

        if (to == address(0)) {
            unchecked { _supply -= amount; }
        } else {
            unchecked { _balances[to] += amount; } // bounded by _supply, cannot overflow
        }

        emit Transfer(from, to, amount);
    }

    function _mint(address to, uint256 amount) internal {
        if (to == address(0)) revert ZeroAddress();
        _move(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        if (from == address(0)) revert ZeroAddress();
        _move(from, address(0), amount);
    }

    function _approve(address holder, address spender, uint256 amount) internal {
        if (spender == address(0)) revert ZeroAddress();
        _allowances[holder][spender] = amount;
        emit Approval(holder, spender, amount);
    }

    function _spendAllowance(address holder, address spender, uint256 amount) internal {
        uint256 current = _allowances[holder][spender];
        if (current == type(uint256).max) return; // infinite approval
        if (current < amount) revert InsufficientAllowance(spender, current, amount);
        unchecked { _allowances[holder][spender] = current - amount; }
    }
}
