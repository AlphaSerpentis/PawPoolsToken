pragma solidity ^0.5.17;

// THIS IS A TEST FOR https://pool.alphaserpentis.space
// INTEGRATION IS STILL BEING DEVELOPED

// Paw Pools Token or "PAW" (name still being considered) is an ERC20-based token that relies on PoW on the Paw Pools mining pool.
// The tokens are minted based on mining activity and by random (integration sill being considered). The ability to mine a block can also determine minting.
// The tokens can be redeemed to lower the mining fee down to a minimum of 0.10% (AMOUNT MIGHT CHANGE DEPENDING ON INTEGRATION)
// The tokens are used up by "activating" them which each token will enable a miner to receive a 0.02% discount for one hour.
// After one hour, they are disposed of, in other words, burnt.

// v0.0.2 Update Log:
// Separates the ERC20 standards into its own
// Fixed... or REALLY added... ERC20 rules under contract IERC20 
// Switches to Solidity 0.5.17
// Changed the types for the 'Information' section under contract PawPoolsToken
// Changed parts of the 'Information' section under contract PawPoolsToken
// Changed scopes of the balances from 'public' to 'private'
// Added a nice self-destruct with specialized conditions to test updating code in the future (temporary) and to destroy broken contracts!
// Renamed 'activeTokenHolder' to 'activatedTokenHolder' to prevent confusion between regular holders and holders who activated the tokens
// Added to the constructor for a specific minter address rather than the contract creator

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract PawPoolsFunctionality {
    // Addresses
    // Address in which Paw Pools Tokens can be minted from
    address public minter;
    // Address in which Paw Pools Tokens will be stored temporarily until burnt
    address public activatedTokenHolder;
    // Address in which Paw Pools Tokens will be destroyed if sent to this address
    address public burner;
    // Address in which Paw Pools Token and the Smart Contract can be destroyed from. (temporary)
    address public demolitionist;
    
    // List of Events
    event Minted(address to, uint amount);
    event Sent(address from, address to, uint amount);
    event ActivateTokens(address from, address to, uint amount);
    event DeactivateTokens(address from, uint amount);
    event Burnt(address from, uint amount);
    event ContractDestroyed();
    
    // Functions
    function mint(address receiver, uint amount) public;
    function activateToken(address receiver, uint amount) public;
    function deactivateToken(address receiver, uint amount) public;
    function burn(address receiver, uint amount) public;
    function destroyContract(address payable receiver) public;
}

// Paw Pools Token or "PAW" might change to "Paw Pools Mining Fee Reduction Token" or PAWMFR

contract ERC20 is IERC20, PawPoolsFunctionality {

    // Information
    string private version;

    string private symbol;
    string private name;
    uint8 private decimals;
    
    uint256 private totalSupply_;

    // Balances
    mapping (address => uint) private balances;
    mapping (address => mapping(address => uint)) private allowed;

    // Constructor

    constructor(address _minter, address _activatedTokenHolder, address _burner, address _demolitionist) public {
        symbol = "PAWMFR";
        name = "Paw Pools Mining Fee Reduction Token - Did I Get This Right?";
        version = "v0.0.2";
        decimals = 4;
        totalSupply_ = 100000000;
        
        minter = _minter;
        activatedTokenHolder = _activatedTokenHolder;
        burner = _burner;
        demolitionist = _demolitionist;
    }

    // Inherited Functions
    function totalySupply() public view returns (uint supply) {
        return totalSupply_;
    }
    function balanceOf(address _account) public view returns (uint balance) {
        return balances[_account];
    }
    function allowance(address _allowance, address spender) public view returns (uint remaining) {
        return allowed[_allowance][spender];
    }
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(balances[_spender] >= _value);
        
        emit Approval(msg.sender, _spender, _value);
        
        return true;
    }
    function transfer(address to, uint amount) public returns (bool success) {
        require(amount <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender] - amount;
        balances[to] = balances[to] + amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require(tokens <= balances[from]);
        
        balances[from] -= tokens;
        balances[to] += tokens;
        emit Transfer(from, to, tokens);
        
        return true;
    }

    // Functions

    function mint(address receiver, uint amount) public {
        require(msg.sender == minter);
        require((balances[activatedTokenHolder] + amount) < totalSupply_ && amount > 0);

        balances[receiver] += amount;
        emit Minted(receiver, amount);
    }
    
    function activateToken(address receiver, uint amount) public {
        require(receiver == activatedTokenHolder);
        require(amount < (totalSupply_ - balances[activatedTokenHolder]) && amount > 0);

        balances[msg.sender] -= amount;
        balances[activatedTokenHolder] += amount;
        emit ActivateTokens(msg.sender, receiver, amount);
    }

    function deactivateToken(address receiver, uint amount) public {
        require(receiver == burner);

        balances[activatedTokenHolder] -= amount;
        burn(msg.sender, amount);
        emit DeactivateTokens(msg.sender, amount);
    }

    function burn(address receiver, uint amount) public {
        require(receiver == burner);
        require(amount < totalSupply_ && amount > 0);

        balances[receiver] -= amount;
        emit Burnt(msg.sender, amount);
    }

    function send(address receiver, uint amount) public {
        require(amount < totalSupply_ && amount > 0);

        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
    }
    
    function destroyContract(address payable receiver) public {
        require(msg.sender == demolitionist);
        require(balances[activatedTokenHolder] == 0);
        
        emit ContractDestroyed();
        
        selfdestruct(receiver);
    }

}
