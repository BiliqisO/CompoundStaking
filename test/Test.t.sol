// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import "openzeppelin/interfaces/IERC20.sol";

import {CompoundStake} from "../src/CompoundStake.sol";
import {MockReceiptToken} from "../src/ReceiptToken.sol";
import {MockWrappedToken} from "../src/Weth.sol";
import {MockRewardToken} from "../src/RewardToken.sol";

contract testStake is Test {
    CompoundStake compoundStake;
    MockReceiptToken receiptToken;
    MockWrappedToken wrappedToken;
    MockRewardToken rewardToken;

    function setUp() public {
        receiptToken = new MockReceiptToken();
        wrappedToken = new MockWrappedToken();
        rewardToken = new MockRewardToken();
        compoundStake = new CompoundStake(
            address(receiptToken),
            address(wrappedToken),
            address(rewardToken)
        );
    }

    function testDeposit() public {
        vm.startPrank(address(1));
        compoundStake.depositEth({from: address(1), value: 5 ether});
        assert(bal);
    }
}
