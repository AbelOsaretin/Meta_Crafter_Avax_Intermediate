// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Investment} from "../src/Investment.sol";
import {Token} from "../src/Token.sol";

contract InvestmentTest is Test {
    Token public token;
    Investment public investment;

    address owner = makeAddr("owner");

    address admin1 = makeAddr("admin1");

    address admin2 = makeAddr("admin2");

    address user1 = makeAddr("user1");

    address user2 = makeAddr("user2");

    address user3 = makeAddr("user3");

    function setUp() public {
        token = new Token(owner);
        investment = new Investment(address(token), owner, 500);

        vm.startPrank(owner);
        investment.setAdmin(admin1);
        investment.setAdmin(admin2);

        vm.deal(owner, 15 ether);

        (bool success, ) = address(investment).call{value: 5 ether}("");
        require(success, "Transfer failed");

        assertEq(address(investment).balance, 5 ether);

        token.transfer(address(investment), 100 ether);

        assertEq(token.balanceOf(address(investment)), 100 ether);

        token.transfer(user1, 100 ether);
        token.transfer(user2, 10 ether);

        assertEq(token.balanceOf(user1), 100 ether);
        assertEq(token.balanceOf(user2), 10 ether);
        vm.stopPrank();

        vm.startPrank(admin1);
        investment.addInvestor(user1);
        investment.addInvestor(user2);
        investment.addInvestor(user3);
        vm.stopPrank();
    }

    function test_CheckingAdmin() public {
        vm.startPrank(owner);
        assertTrue(investment.checkAdmin(admin1));
    }

    function test_RemoveAdmin() public {
        vm.startPrank(owner);

        assertTrue(investment.checkAdmin(admin2));
        investment.removeAdmin(admin2);

        assertFalse(investment.checkAdmin(admin2));
    }

    function test_Remove_Investor() public {
        vm.startPrank(admin1);
        assertTrue(investment.checkInvestor(user3));
        investment.removeInvestor(user3);
        assertFalse(investment.checkInvestor(user3));
    }

    function test_Add_Ethers_Investment() public {
        vm.startPrank(user1);

        uint256 amount = 1 ether;
        investment.addInvestmentEthers(amount);

        assertEq(investment.getInvestmentEthers(), amount);
    }

    function test_Withdraw_Ethers_Investment() public {
        vm.startPrank(user1);

        uint256 amount = 1 ether;
        investment.addInvestmentEthers(amount);

        uint256 oneYearLater = block.timestamp + 365 days;
        vm.warp(oneYearLater);

        investment.withdrawInvestmentEthers();
    }

    function test_Add_Token_Investment() public {
        vm.startPrank(user1);

        token.approve(address(investment), 100 ether);

        investment.addInvestmentERC20(100 ether);

        assertEq(investment.getInvestmentERC20(), 100 ether);
    }

    function test_Withdraw_ERC20_Investment() public {
        test_Add_Token_Investment();

        uint256 oneYearLater = block.timestamp + 365 days;
        vm.warp(oneYearLater);

        investment.withdrawInvestmentERC20();
    }

    function test_Increase_Intrest_Rate() public {
        vm.startPrank(owner);
        investment.setInterestRate(1000);

        uint256 interestRate = investment.getInterestRate();

        assertEq(interestRate, 1000);
    }
}
