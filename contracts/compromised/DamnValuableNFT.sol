pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DamnValuableNFT is ERC721, AccessControl {

    using Counters for Counters.Counter;
    
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    Counters.Counter nonce; // acts as unique identifier for minted NFTs

    constructor() public ERC721("DamnValuableNFT", "DVNFT") {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
        _setupRole(BURNER_ROLE, msg.sender);
    }

    function mint(address to) external returns (uint256) {
        require(hasRole(MINTER_ROLE, msg.sender), "Forbidden");
        
        // Increment ID and issue new NFT. Note that ID starts at 1.
        nonce.increment();

        uint256 tokenId = nonce.current();
        _safeMint(to, tokenId);
        
        return tokenId;
    }

    function burn(uint256 tokenId) external {
        require(hasRole(BURNER_ROLE, msg.sender), "Forbidden");
        _burn(tokenId);
    }
}
