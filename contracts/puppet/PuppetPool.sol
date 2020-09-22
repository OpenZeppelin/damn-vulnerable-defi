pragma solidity ^0.6.0;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "../DamnValuableToken.sol";

contract PuppetPool is ReentrancyGuard {

    using SafeMath for uint256;
    using Address for address payable;

    address public uniswapOracle;
    mapping(address => uint256) public deposits;
    DamnValuableToken public token;
    
    constructor (address tokenAddress, address uniswapOracleAddress) public {
        token = DamnValuableToken(tokenAddress);
        uniswapOracle = uniswapOracleAddress;
    }

    // Allows borrowing `borrowAmount` of tokens by first depositing two times their value in ETH
    function borrow(uint256 borrowAmount) public payable nonReentrant {
        uint256 amountToDeposit = msg.value;

        uint256 tokenPriceInWei = computeOraclePrice();
        uint256 depositRequired = borrowAmount.mul(tokenPriceInWei) * 2;
        
        require(amountToDeposit >= depositRequired, "Not depositing enough collateral");
        if (amountToDeposit > depositRequired) {
            uint256 amountToReturn = amountToDeposit - depositRequired;
            amountToDeposit -= amountToReturn;
            msg.sender.sendValue(amountToReturn);
        }        

        deposits[msg.sender] += amountToDeposit;

        // Fails if the pool doesn't have enough tokens in liquidity
        require(token.transfer(msg.sender, borrowAmount), "Transfer failed");
    }

    function computeOraclePrice() public view returns (uint256) {
        return uniswapOracle.balance.div(token.balanceOf(uniswapOracle));
    }

     /**
     ... functions to deposit, redeem, repay, calculate interest, and so on ...
     */

}