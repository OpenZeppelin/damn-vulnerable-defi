pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract TrusterLenderPool is ReentrancyGuard {

    IERC20 public damnValuableToken;

    constructor (address tokenAddress) public {
        damnValuableToken = IERC20(tokenAddress);
    }

    function flashLoan(
        uint256 borrowAmount,
        address borrower,
        address target,
        bytes calldata data
    )
        external
        nonReentrant
    {
        uint256 balanceBefore = damnValuableToken.balanceOf(address(this));
        require(balanceBefore >= borrowAmount, "Not enough tokens in pool");
        
        damnValuableToken.transfer(borrower, borrowAmount);
        (bool success, ) = target.call(data);
        require(success, "External call failed");

        uint256 balanceAfter = damnValuableToken.balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "Flash loan hasn't been paid back");
    }

}
