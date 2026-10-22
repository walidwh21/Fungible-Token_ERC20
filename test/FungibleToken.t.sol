// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {TestBase} from "./utils/TestBase.sol";
import {ReferenceToken} from "../src/tokens/ReferenceToken.sol";
import {TokenErrors} from "../src/interfaces/TokenErrors.sol";
import {IFungibleToken} from "../src/interfaces/IFungibleToken.sol";

contract FungibleTokenTest is TestBase {
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed holder, address indexed spender, uint256 amount);

    ReferenceToken internal token;
    address internal alice = makeAddr("alice");
    address internal bob = makeAddr("bob");
    address internal carol = makeAddr("carol");

    uint256 internal constant UNIT = 1e18;

    function setUp() public {
        token = new ReferenceToken("Sample Token", "SMP", 1_000_000, 5_000_000);
        token.transfer(alice, 10_000 * UNIT);
    }

    // ───── deployment ─────
    function test_Metadata() public view {
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), 1_000_000 * UNIT);
        assertEq(token.admin(), address(this));
    }

    function test_InitialSupplyGoesToDeployer() public view {
        assertEq(token.balanceOf(address(this)), 990_000 * UNIT);
    }

    // ───── transfer ─────
    function test_Transfer() public {
        vm.prank(alice);
        token.transfer(bob, 250 * UNIT);
        assertEq(token.balanceOf(alice), 9_750 * UNIT);
        assertEq(token.balanceOf(bob), 250 * UNIT);
    }

    function test_TransferEmitsEvent() public {
        vm.expectEmit(true, true, false, true);
        emit Transfer(alice, bob, 1 * UNIT);
        vm.prank(alice);
        token.transfer(bob, 1 * UNIT);
    }

    function test_TransferRevertsOnInsufficientBalance() public {
        vm.expectRevert(
            abi.encodeWithSelector(TokenErrors.InsufficientBalance.selector, alice, 10_000 * UNIT, 10_001 * UNIT)
        );
        vm.prank(alice);
        token.transfer(bob, 10_001 * UNIT);
    }

    function test_TransferToZeroReverts() public {
        vm.expectRevert(TokenErrors.ZeroAddress.selector);
        vm.prank(alice);
        token.transfer(address(0), 1);
    }

    // ───── approve / transferFrom ─────
    function test_ApproveSetsAllowance() public {
        vm.expectEmit(true, true, false, true);
        emit Approval(alice, bob, 500 * UNIT);
        vm.prank(alice);
        token.approve(bob, 500 * UNIT);
        assertEq(token.allowance(alice, bob), 500 * UNIT);
    }

    function test_TransferFromConsumesAllowance() public {
        vm.prank(alice);
        token.approve(bob, 500 * UNIT);

        vm.prank(bob);
        token.transferFrom(alice, carol, 200 * UNIT);

        assertEq(token.balanceOf(carol), 200 * UNIT);
        assertEq(token.allowance(alice, bob), 300 * UNIT);
    }

    function test_TransferFromRevertsWithoutAllowance() public {
        vm.expectRevert(abi.encodeWithSelector(TokenErrors.InsufficientAllowance.selector, bob, 0, 1));
        vm.prank(bob);
        token.transferFrom(alice, carol, 1);
    }

    function test_InfiniteAllowanceIsNotDecremented() public {
        vm.prank(alice);
        token.approve(bob, type(uint256).max);
        vm.prank(bob);
        token.transferFrom(alice, carol, 5 * UNIT);
        assertEq(token.allowance(alice, bob), type(uint256).max);
    }

    // ───── burn ─────
    function test_BurnReducesSupply() public {
        vm.prank(alice);
        token.burn(100 * UNIT);
        assertEq(token.totalSupply(), 999_900 * UNIT);
        assertEq(token.balanceOf(alice), 9_900 * UNIT);
    }

    function test_BurnFromUsesAllowance() public {
        vm.prank(alice);
        token.approve(bob, 40 * UNIT);
        vm.prank(bob);
        token.burnFrom(alice, 25 * UNIT);
        assertEq(token.allowance(alice, bob), 15 * UNIT);
        assertEq(token.totalSupply(), 999_975 * UNIT);
    }

    // ───── mint / cap ─────
    function test_AdminCanMintUnderCap() public {
        token.mint(bob, 1_000 * UNIT);
        assertEq(token.balanceOf(bob), 1_000 * UNIT);
    }

    function test_MintAboveCapReverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                bytes4(keccak256("CapExceeded(uint256,uint256)")), 5_000_000 * UNIT, 5_000_001 * UNIT
            )
        );
        token.mint(bob, 4_000_001 * UNIT);
    }

    function test_NonAdminCannotMint() public {
        vm.expectRevert(abi.encodeWithSelector(TokenErrors.Unauthorized.selector, alice));
        vm.prank(alice);
        token.mint(alice, 1);
    }

    // ───── pause ─────
    function test_PauseBlocksTransfers() public {
        token.pause();
        vm.expectRevert(TokenErrors.TransfersPaused.selector);
        vm.prank(alice);
        token.transfer(bob, 1);
    }

    function test_UnpauseRestoresTransfers() public {
        token.pause();
        token.unpause();
        vm.prank(alice);
        token.transfer(bob, 1);
        assertEq(token.balanceOf(bob), 1);
    }

    // ───── admin handover ─────
    function test_TwoStepAdminTransfer() public {
        token.proposeAdmin(bob);
        assertEq(token.admin(), address(this));
        vm.prank(bob);
        token.acceptAdmin();
        assertEq(token.admin(), bob);
        assertEq(token.pendingAdmin(), address(0));
    }

    function test_AcceptAdminByStrangerReverts() public {
        token.proposeAdmin(bob);
        vm.expectRevert(abi.encodeWithSelector(TokenErrors.Unauthorized.selector, carol));
        vm.prank(carol);
        token.acceptAdmin();
    }

    // ───── fuzz ─────
    function testFuzz_TransferConservesSupply(address to, uint96 amount) public {
        vm.assume(to != address(0));
        uint256 value = uint256(amount) % (10_000 * UNIT);
        uint256 supplyBefore = token.totalSupply();
        vm.prank(alice);
        token.transfer(to, value);
        assertEq(token.totalSupply(), supplyBefore);
    }

    function testFuzz_ApproveThenSpend(uint96 approved, uint96 spent) public {
        vm.assume(spent <= approved);
        uint256 a = uint256(approved) % (10_000 * UNIT);
        uint256 s = uint256(spent) % (a + 1);
        vm.prank(alice);
        token.approve(bob, a);
        vm.prank(bob);
        token.transferFrom(alice, carol, s);
        assertEq(token.allowance(alice, bob), a - s);
        assertEq(token.balanceOf(carol), s);
    }
}
