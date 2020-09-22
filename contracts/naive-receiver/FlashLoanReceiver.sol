pragma solidity ^0.6.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract FlashLoanReceiver {
    using SafeMath for uint256;
    using Address for address payable;

    address payable private pool;

    constructor(address payable poolAddress) public {
        pool = poolAddress;
    }

    // Function called by the pool during flash loan
    function receiveEther(uint256 fee) public payable {
        require(msg.sender == pool, "Sender must be pool");

        uint256 amountToBeRepaid = msg.value.add(fee);

        require(address(this).balance >= amountToBeRepaid, "Cannot borrow that much");
        
        _executeActionDuringFlashLoan();
        
        // Return funds to pool
        pool.sendValue(amountToBeRepaid);
    }

    // Internal function where the funds received are used
    function _executeActionDuringFlashLoan() internal { }

    // Allow deposits of ETH
    receive () external payable {}
}