pragma solidity ^0.5.10;

// THIS IS A TEST FOR https://pool.alphaserpentis.space
// INTEGRATION IS STILL BEING DEVELOPED

contract PawPoolsTokenTest {

    // Information

    bytes32 name = "Paw Pools Token";
    bytes32 version = "v0.0.1";
    uint constant totalSupply = 1000000;
    
    // Addresses

    // Address in which Paw Pools Tokens can be minted from
    address public minter;
    // Address in which Paw Pools Tokens will be stored temporarily until burnt
    address public activeTokenHolder;
    // Address in which Paw Pools Tokens will be destroyed if sent to this address
    address public burner;

    // Balances
    mapping (address => uint) public balances;

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
        require((getBalances(activeTokenHolder) + amount) < totalSupply && amount > 0);

        balances[receiver] += amount;
        emit Minted(receiver, amount);
    }

    function activateToken(address receiver, uint amount) public {
        require(receiver == activeTokenHolder);
        require(amount < (totalSupply - getBalances(activeTokenHolder)) && amount > 0);
       
        balances[receiver] -= amount;
        balances[activeTokenHolder] += amount;
        emit ActivateTokens(msg.sender, receiver, amount);
    }

    function deactivateToken(address receiver, uint amount) public {
        require(receiver == burner);

        balances[activeTokenHolder] -= amount;
        burn(receiver, amount);
        emit DeactivateTokens(msg.sender, amount);
    }

    function burn(address receiver, uint amount) public {
        require(receiver == burner);
        require(amount < totalSupply && amount > 0);
        
        balances[receiver] -= amount;
        emit Burnt(msg.sender, amount);
    }

    function send(address receiver, uint amount) public {
        require(amount < totalSupply && amount > 0);
        
        balances[msg.sender] -= amount;
        balances[receiver] += amount;
        emit Sent(msg.sender, receiver, amount);
    }

    // Documentation suggested using external, but decided to use public... may want to check that out.
    function getBalances(address _account) public view returns (uint) {
        return balances[_account];
    }

}
