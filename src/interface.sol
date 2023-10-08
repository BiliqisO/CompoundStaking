// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IStaking {
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function transfer(
        address _to,
        uint256 _value
    ) external returns (bool success);

    function mint(address account, uint256 value) external;

    function approve(address owner, address spender, uint256 value) external;
}
