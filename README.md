# v0.0.2 - Paw Pools Token ($PAW)

# Notice

Any of the information listed on this **README** document is subject to change, not final, nor finished. Anything stated here is not a guarantee of the actual end-product.

# Description

$PAW is an ERC20-based token, using OpenZeppelin's method, that will use mining activity on the Paw Pools mining pool. 

$PAW tokens are minted based on randomness, dependent on the activity of the mining pool itself. If there's no activity, little to none tokens will be minted, otherwise tokens will be minted. Mining blocks will also give miners a possible bonus.

The tokens can be "redeemed," or in other words **activated**. The $PAW tokens can be used in any way the token holder wishes to do as to not confuse that these tokens are "locked" like some other tokens. When these tokens are activated, they'll be deducted against your address, but reward the miner with a mining fee deduction of **0.01%** each token (must be whole tokens).

# How Miners Are Added

Miners would have to provide an Ethereum address in the mining options to allow for minting to occur. When an address is provided, it'll be sent to the contract and put into a list of currently active miners. If a miner drops out, they have roughly 30 minutes to get back in, otherwise they'll be removed from the list of active miners and rewards may be lower/nil. Rewards queued will not be nulled, and be paid as appropriate.

# Specifications

**Name**: Paw Pools Token

**Symbol**: $PAW

**Decimals**: 4

**Minting Possibilities (?)**:

- Mining Activity: Rewards each user with 0.50 - 2.5 tokens
- Block Mined: Rewards the miner(s) with 0.1225 tokens per block (higher hashing does not mean you will get a larger cut!)

# Contract Deployed

*The contract at this stage is **SELF-DESTRUCTIBLE**, but is planned to be removed when the actual contract is deployed on the network. The self-destruct method is only there to clean up the mess.*

**CURRENTLY TESTING ON THE ROPSTEN NETWORK - NO TANGIBLE VALUE!**

Deployed under ... (attempting to deploy)
