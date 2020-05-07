pragma solidity ^0.5.17;

// THIS IS A TEST FOR https://pool.alphaserpentis.space
// INTEGRATION IS STILL BEING DEVELOPED

// Paw Pools Token or "PAW" (name still being considered) is an ERC20-based token that relies on PoW on the Paw Pools mining pool.
// The tokens are minted based on mining activity and by random (integration sill being considered). The ability to mine a block can also determine minting.
// The tokens can be redeemed to lower the mining fee down to a minimum of 0.10% (AMOUNT MIGHT CHANGE DEPENDING ON INTEGRATION)
// The tokens are used up by "activating" them which each token will enable a miner to receive a 0.02% discount for one hour.
// After one hour, they are disposed of, in other words, burnt.

// v0.0.2 Update Log:
// Really just decided to rewrite the entire thing and import OpenZeppelin's v2.4.0 (https://github.com/OpenZeppelin/openzeppelin-contracts/tree/release-v2.4.0/contracts/token/ERC20)

// v0.0.3 should customize more of the token than v0.0.2. Particularly, the activated tokens.

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.4.0/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.4.0/contracts/token/ERC20/ERC20Detailed.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.4.0/contracts/token/ERC20/ERC20Mintable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.4.0/contracts/token/ERC20/ERC20Burnable.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.4.0/contracts/access/Roles.sol";

contract PawPools_MiningFeeReduction is ERC20Detailed, ERC20Mintable, ERC20Burnable {
    using Roles for Roles.Role;
    
    // Predefined Error Messages
    string private constant err_contractOwner = "Not contract owner!";
    string private constant err_doesNotExist = "Does not exist!";
    
    // Address(es)
    address private contractOwner;
    address private demolitionist;
    
    Roles.Role private minters;
    Roles.Role private burners;
    Roles.Role private activatedTokenHolders;
    
    // Constructor
    
    constructor(address _minter, address _burner, address _activatedTokenHolder, address _demolitionist) public ERC20Detailed("Paw Pool's Mining Fee Reduction Token", "PAWF", 4) {
        addMinter(_minter);
        addBurner(_burner);
        addActivatedTokenHolder(_activatedTokenHolder);
        addDemolitionist(_demolitionist);
    }
    
    // Functions
    
    function addMinter(address _minter) public {
        require(msg.sender == contractOwner, string(abi.encode("Cannot add minter: ", err_contractOwner)));
        
        minters.add(_minter);
    }
    function addBurner(address _burner) public {
        require(msg.sender == contractOwner, string(abi.encode("Cannot add burner: ", err_contractOwner)));
        
        burners.add(_burner);
    }
    function addActivatedTokenHolder(address _activatedTokenHolder) public {
        require(msg.sender == contractOwner, string(abi.encode("Cannot add activated token holders: ", err_contractOwner)));
        
        activatedTokenHolders.add(_activatedTokenHolder);
    }
    // WARNING: THIS FUNCTION OVERWRITES THE PREVIOUS DEMOL
    function addDemolitionist(address _demolitionist) public {
        require(msg.sender == contractOwner, string(abi.encode("Cannot add demolitionist: ", err_contractOwner)));
        
        demolitionist = _demolitionist;
    }
    
    function removeMinter(address _minter) public {
        require(msg.sender == contractOwner, string(abi.encode("Cannot remove minter: ", err_contractOwner)));
        
        minters[_minter] = false;
        
        revert(string(abi.encode("Cannot remove minter: ", err_doesNotExist)));
    }
    
}
