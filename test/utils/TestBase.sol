// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

/// @dev Subset of the Foundry cheatcode interface used by this repo's tests.
interface Vm {
    function prank(address caller) external;
    function startPrank(address caller) external;
    function stopPrank() external;
    function expectRevert(bytes calldata revertData) external;
    function expectRevert(bytes4 selector) external;
    function expectEmit(bool t1, bool t2, bool t3, bool data) external;
    function assume(bool condition) external pure;
    function addr(uint256 privateKey) external pure returns (address);
}

/// @dev Tiny assertion helper so the repo needs no external libraries.
abstract contract TestBase {
    Vm internal constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function assertEq(uint256 a, uint256 b) internal pure {
        require(a == b, "assertEq(uint256) failed");
    }

    function assertEq(address a, address b) internal pure {
        require(a == b, "assertEq(address) failed");
    }

    function assertTrue(bool c) internal pure {
        require(c, "assertTrue failed");
    }

    function assertFalse(bool c) internal pure {
        require(!c, "assertFalse failed");
    }

    function makeAddr(string memory label) internal pure returns (address) {
        return address(uint160(uint256(keccak256(bytes(label)))));
    }
}
