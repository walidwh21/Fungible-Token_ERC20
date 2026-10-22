// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {TokenErrors} from "../interfaces/TokenErrors.sol";

/// @title Administered
/// @notice Single-admin access control with two-step handover.
abstract contract Administered is TokenErrors {
    address public admin;
    address public pendingAdmin;

    event AdminTransferStarted(address indexed previousAdmin, address indexed proposedAdmin);
    event AdminTransferred(address indexed previousAdmin, address indexed newAdmin);

    modifier onlyAdmin() {
        if (msg.sender != admin) revert Unauthorized(msg.sender);
        _;
    }

    constructor(address initialAdmin) {
        if (initialAdmin == address(0)) revert ZeroAddress();
        admin = initialAdmin;
        emit AdminTransferred(address(0), initialAdmin);
    }

    function proposeAdmin(address proposed) external onlyAdmin {
        pendingAdmin = proposed;
        emit AdminTransferStarted(admin, proposed);
    }

    function acceptAdmin() external {
        if (msg.sender != pendingAdmin) revert Unauthorized(msg.sender);
        emit AdminTransferred(admin, msg.sender);
        admin = msg.sender;
        pendingAdmin = address(0);
    }
}
