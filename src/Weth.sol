// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Wrappedtoken is ERC20 {
    constructor() ERC20("WrappedToken", "WETH") {
        //  _mint(msg.sender, 1_000_000_000_000e18  );
    }

    function mint(address account, uint256 value) external {
        _mint(account, value);
    }
}
