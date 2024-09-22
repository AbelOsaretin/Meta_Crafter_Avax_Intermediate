// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Token} from "../src/Token.sol";
import {Investment} from "../src/Investment.sol";

contract InvestmentScript is Script {
    Token public token;
    Investment public investment;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        token = new Token(msg.sender);
        investment = new Investment(address(token), msg.sender, 500);

        console.log("Token Contract deployed to:", address(token));
        console.log("Investment Contract deployed to:", address(investment));
        vm.stopBroadcast();
    }
}
