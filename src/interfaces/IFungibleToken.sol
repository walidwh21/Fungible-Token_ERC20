// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/// @title IFungibleToken
/// @notice Minimal ERC-20 compatible surface (EIP-20) plus metadata getters.
interface IFungibleToken {
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed holder, address indexed spender, uint256 amount);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
    function allowance(address holder, address spender) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
