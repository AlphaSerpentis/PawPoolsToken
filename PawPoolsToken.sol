pragma solidity ^0.5.17;

// THIS IS A TEST FOR https://pool.alphaserpentis.space
// INTEGRATION IS STILL BEING DEVELOPED
// THIS IS NOT REPRESENTATIVE OF THE END PRODUCT

// v0.0.2 Update Log:
// Really just decided to rewrite the entire thing and import OpenZeppelin's v2.4.0 (https://github.com/OpenZeppelin/openzeppelin-contracts/tree/release-v2.4.0/contracts/token/ERC20)

// v0.0.3 should customize more of the token than v0.0.2. Particularly, the activated tokens.

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.4.0/contracts/token/ERC20/IERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.4.0/contracts/token/ERC20/ERC20Detailed.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.4.0/contracts/token/ERC20/ERC20Mintable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.4.0/contracts/token/ERC20/ERC20Burnable.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.4.0/contracts/access/Roles.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.4.0/contracts/GSN/Context.sol";

contract ActivatedTokenHoldersRole is Context {
    using Roles for Roles.Role;
    
    event AddedAddress(address indexed _newAddress);
    event RemovedAddress(address indexed _removedAddress);
    
    Roles.Role private _activatedTokenHolders;
    
    constructor(address _address) internal {
       
    }
    
    modifier onlyActivatedTokenHolder() {
        require(isActivatedTokenHolder(_msgSender()), "ActivatedTokenHolderRole: caller does not have the ActivatedTokenHolder role");
        _;
    }
    
    function isActivatedTokenHolder(address account) public view returns(bool) {
        
    }
    function addActivatedTokenHolder(address account) public onlyActivatedTokenHolder {
        _addActivatedTokenHolder(account);
    }

    function renounceActivatedTokenHolder() public {
        _removeActivatedTokenHolder(_msgSender());
    }

    function _addActivatedTokenHolder(address account) internal {
        _activatedTokenHolders.add(account);
        emit AddedAddress(account);
    }
    function _removeActivatedTokenHolder(address account) internal {
        _activatedTokenHolders.remove(account);
        emit RemovedAddress(account);
    }
    
}

contract PawPools_MiningFeeReduction is ERC20Detailed, ERC20Mintable, ERC20Burnable, ActivatedTokenHoldersRole {
    // Address(es)
    address private contractOwner;
    address private demolitionist;
    
    // Events
    
    // Constructor
    
    constructor(address _minter, address _activatedTokenHolder, address _demolitionist) public ERC20Detailed("Paw Pools Token", "PAW", 4) {
        addMinter(_minter);
        addActivatedTokenHolder(_activatedTokenHolder);
        addDemolitionist(_demolitionist);
        
        contractOwner = msg.sender;
    }
    
    // Functions
    // WARNING: THIS FUNCTION OVERWRITES THE PREVIOUS DEMOLITIONIST
    function addDemolitionist(address _demolitionist) public {
        require(msg.sender == contractOwner, "Cannot add/replace demolitionist! Not contract owner!");
        
        demolitionist = _demolitionist;
    }
    
    function destroyContract(address payable sendTo) public {
        require(msg.sender == demolitionist || msg.sender == contractOwner, "Cannot destroy contract! Not demolitionist or contract owner!");
        
        selfdestruct(sendTo);
    }
    
}
