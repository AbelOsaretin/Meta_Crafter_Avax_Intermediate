// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Investment} from "../src/Investment.sol";
import {Token} from "../src/Token.sol";

contract InvestmentTest is Test {
    Token public token;
    Investment public investment;

    address owner = address(0x0099999999999999999999);

    address user1 = address(0x0011111111111111111111);

    address user2 = address(0x0022222222222222222222);

    address user3 = address(0x0033333333333333333333);

    function setUp() public {
        token = new Token(owner);
        investment = new Investment(address(token));

        investment.setAdmin(owner);

        investment.checkAdmin(owner);
    }
}
