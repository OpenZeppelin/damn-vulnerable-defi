pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @notice A mintable ERC20 token to issue rewards
 */
contract RewardToken is ERC20, AccessControl {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() public ERC20("Reward Token", "RWT") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) external {
        require(hasRole(MINTER_ROLE, msg.sender));
        _mint(to, amount);
    }
}
