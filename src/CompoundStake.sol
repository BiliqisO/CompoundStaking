// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "./interface.sol";

contract Staking {
    IStaking ReceiptToken;
    IStaking WrappedToken;
    IStaking RewardToken;

    struct Staker {
        address owner;
        uint TimeStaked;
        uint rewardTokenBal;
        uint BiliTokenBal;
        bool autocompound;
    }
    address[] autoCompundAddresses;
    mapping(address => uint) autoCompoundBal;
    mapping(address => uint) autoCompoundTime;
    uint autoCompoundPool;
    uint[] onePercent;

    address public poolOwner;

    mapping(address => Staker) public mapStake;

    constructor(
        address _ReceiptToken,
        address _WrappedToken,
        address _RewardToken
    ) {
        ReceiptToken = IStaking(_ReceiptToken);
        WrappedToken = IStaking(_WrappedToken);
        RewardToken = IStaking(_RewardToken);
        poolOwner = msg.sender;
    }

    function depositEth(bool _autocompound) public payable {
        Staker storage staker = mapStake[msg.sender];
        uint depositAmount = msg.value;
        //mint rewardToken (token we calculate 14% from)
        RewardToken.mint(msg.sender, depositAmount);
        //weth an equivalence of the eth deposited
        WrappedToken.mint(poolOwner, depositAmount);
        ReceiptToken.mint(msg.sender, depositAmount);
        staker.owner = msg.sender;
        staker.rewardTokenBal += depositAmount;
        staker.TimeStaked = block.timestamp;
        staker.autocompound = _autocompound;
        require(staker.autocompound, "autocompund");

        autoCompoundPool += depositAmount;
        autoCompundAddresses.push(msg.sender);
        autoCompoundBal[msg.sender] += depositAmount;
        autoCompoundTime[msg.sender] = block.timestamp;
        // uint onePercentperAdd = autoCompoundPool * 1 / (100 *  autoCompoundTime[msg.sender]);
        // onePercent.push(onePercentperAdd);
    }

    //trigger this function to get your money
    //it automatically generates a one percent fee that is stored in the contract;
    //every address have a one percent increment per 30 days
    //
    function getAutocompounded() public {
        Staker memory staker = mapStake[msg.sender];
        require(
            staker.autocompound == true,
            "you did not opt in for auto compounding"
        );
        uint onepercent = autoCompoundPool / 100;
        uint myOnePercent = autoCompoundBal[msg.sender];
        uint remnant = staker.rewardTokenBal - myOnePercent;
        staker.BiliTokenBal = remnant * 10;
        uint interestCalc = staker.BiliTokenBal *
            (1 + (SafeMath.div(14, 1200))) ** 12; //compound interest per month
        uint exactInterestToEth = interestCalc / 10;
        uint paymsgsender = onepercent + exactInterestToEth;
        payable(msg.sender).transfer(paymsgsender);
        WrappedToken.transfer(msg.sender, exactInterestToEth);
        staker.TimeStaked = 0;
    }

    function getNotAutoCompound(address _owneraddr) public {
        Staker memory staker = mapStake[_owneraddr];
        require(staker.autocompound == true, "you opted for auto compounding");
        staker.BiliTokenBal = staker.rewardTokenBal * 10;
        uint oneyear = staker.TimeStaked + 365 days;
        uint remnant = (staker.BiliTokenBal * 14) / (100 * oneyear);
        payable(msg.sender).transfer(remnant);
        WrappedToken.transfer(msg.sender, remnant);
    }
}
