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
// Fixed... or added... ERC20 rules under contract ERC20Interface
// Switches to Solidity 0.5.17
// Changed the types for the 'Information' section under contract PawPoolsToken
// Changed parts of the 'Information' section under contract PawPoolsToken
// Changed scopes of the balances from 'public' to 'private'
// Added a nice self-destruct with specialized conditions to test updating code in the future (temporary)
// Renamed 'activeTokenHolder' to 'activatedTokenHolder' to prevent confusion between regular holders and holders who activated the tokens
// Added to the constructor for a specific minter address rather than the contract creator

contract IERC20 {
    // Token Functions
    function totalySupply() public pure returns (uint);
    function balanceOf(address _account) public view returns (uint balance);
    function allowance(address _allowance, address spender) public view returns (uint remaining);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function transfer(address to, uint amount) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    // Events
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed _account, address indexed spender, uint tokens);
}

// Paw Pools Token or "PAW" might change to "Paw Pools Mining Fee Reduction Token" or PAWMFR

contract PawPoolsToken is IERC20 {

    // Information

    string constant public symbol = "PAWMFR";
    string constant public name = "Paw Pools Mining Fee Reduction Token";
    uint8 constant public decimals = 4;
    uint constant public _totalSupply = 100000000;

    // Addresses

    // Address in which Paw Pools Tokens can be minted from
    address public minter;
    // Address in which Paw Pools Tokens will be stored temporarily until burnt
    address public activatedTokenHolder;
    // Address in which Paw Pools Tokens will be destroyed if sent to this address
    address public burner;
    // Address in which Paw Pools Token and the Smart Contract can be destroyed from. (temporary)
    address public demolitionist;

    // Balances
    mapping (address => uint) private balances;
    mapping (address => mapping(address => uint)) private allowed;

    // List of Events
    event Minted(address to, uint amount);
    event Sent(address from, address to, uint amount);
    event ActivateTokens(address from, address to, uint amount);
    event DeactivateTokens(address from, uint amount);
    event Burnt(address from, uint amount);
    event ContractDestroyed();

    // Constructor

    constructor(address _minter, address _activatedTokenHolder, address _burner, address _demolitionist) public {
        minter = _minter;
        activatedTokenHolder = _activatedTokenHolder;
        burner = _burner;
        demolitionist = _demolitionist;
    }

    // Inherited Functions
    
    function totalSupply() public pure returns (uint) {
        return _totalSupply;
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
        require(amount < _totalSupply && amount > 0);

        balances[msg.sender] -= amount;
        balances[to] += amount;
        emit Sent(msg.sender, to, amount);
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
        require((balanceOf(activatedTokenHolder) + amount) < _totalSupply && amount > 0);

        balances[receiver] += amount;
        emit Minted(receiver, amount);
    }
    
    function activateToken(address receiver, uint amount) public {
        require(receiver == activatedTokenHolder);
        require(amount < (_totalSupply - balanceOf(activatedTokenHolder)) && amount > 0);

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
        require(amount < _totalSupply && amount > 0);

        balances[receiver] -= amount;
        emit Burnt(msg.sender, amount);
    }

    function send(address receiver, uint amount) public {
        require(amount < _totalSupply && amount > 0);

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
