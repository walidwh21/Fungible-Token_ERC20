// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/// @notice Custom errors shared by the token modules (cheaper than revert strings).
interface TokenErrors {
    error ZeroAddress();
    error InsufficientBalance(address account, uint256 available, uint256 required);
    error InsufficientAllowance(address spender, uint256 available, uint256 required);
    error Unauthorized(address caller);
    error TransfersPaused();
    error TransfersNotPaused();
}
