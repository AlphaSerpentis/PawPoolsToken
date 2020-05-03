pragma solidity ^0.5.17;

// THIS IS A TEST FOR https://pool.alphaserpentis.space
// INTEGRATION IS STILL BEING DEVELOPED

// v0.0.2 Update Log:
// Separates the ERC20 standards into its own
// Fixed... or added... ERC20 rules under contract ERC20Interface
// Switches to Solidity 0.5.17
// Changed the types for the 'Information' section under contract PawPoolsToken
// Changed parts of the 'Information' section under contract PawPoolsToken
// Changed scopes of the balances from 'public' to 'private'
// Added a nice self-destruct with specialized conditions to test updating code in the future (temporary)

contract ERC20Interface {
    // Token Functions
    function totalySupply() public view returns (uint);
    function balanceOf(address _account) public view returns (uint balance);
    function allowance(address _allowance, address spender) public view returns (uint remaining);
    function transfer(address to, uint amount) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    // Events
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed _account, address indexed spender, uint tokens);
}

// Paw Pools Token or "PAW" might change to "Paw Pools Mining Fee Reduction Token" or PAWMFR

contract PawPoolsToken is ERC20Interface {

    // Information

    string constant public symbol = "PAWMFR";
    string constant public name = "Paw Pools Mining Fee Reduction Token";
    uint8 constant public decimals = 4;
    uint constant public _totalSupply = 100000000;

    // Addresses

    // Address in which Paw Pools Tokens can be minted from
    address public minter;
    // Address in which Paw Pools Tokens will be stored temporarily until burnt
    address public activeTokenHolder;
    // Address in which Paw Pools Tokens will be destroyed if sent to this address
    address public burner;

    // Balances
    mapping (address => uint) private balances;
    mapping (address => mapping(address => uint)) private allowed;

    // List of Events
    event Minted(address to, uint amount);
    event Sent(address from, address to, uint amount);
    event ActivateTokens(address from, address to, uint amount);
    event DeactivateTokens(address from, uint amount);
    event Burnt(address from, uint amount);

    // Constructor

    constructor(address _activeTokenHolder, address _burner) public {
        minter = msg.sender;
        activeTokenHolder = _activeTokenHolder;
        burner = _burner;
    }

    // Functions

    function mint(address receiver, uint amount) public {
        require(msg.sender == minter);
        require((balanceOf(activeTokenHolder) + amount) < _totalSupply && amount > 0);

        balances[receiver] += amount;
        emit Minted(receiver, amount);
    }

    function activateToken(address receiver, uint amount) public {
        require(receiver == activeTokenHolder);
        require(amount < (_totalSupply - balanceOf(activeTokenHolder)) && amount > 0);

        balances[msg.sender] -= amount;
        balances[activeTokenHolder] += amount;
        emit ActivateTokens(msg.sender, receiver, amount);
    }

    function deactivateToken(address receiver, uint amount) public {
        require(receiver == burner);

        balances[activeTokenHolder] -= amount;
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

}
