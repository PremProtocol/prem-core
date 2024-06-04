# Project Title & Description

Prem is a prediction market on The Open Network (TON), addressing the need for a decentralized, transparent platform for betting on future events.

## Key Components

1. Market Creation: Users can create new prediction markets.
2. Betting: Users can place bets on different outcomes.
3. Resolution: The outcome is determined after the event.
4. Settlement: Winners are paid out based on the event outcome.

## Smart Contracts Architecture

### Market Factory Contract:

Testnet Address: TBD
Mainnet Address: TBD

Creates new prediction markets. (Currently only by deployer)

### Prediction Market Contract:

Handles the specific event being bet on.
Manages the bets and the total pool for each outcome.
Resolves the market based on the outcome.
Distributes the winnings.

### User Bet Contract:

Manages the bet and the total pool user bet.
Claim the user winnings.

### Token Contract (optional, if using custom tokens):

Manages the platform's native token for betting and payouts.

## Gas Cost Optimization

|      Contract     | Contract Message      | Gas Sent    | Operation Cost | Leaved for storage |
|-------------------|-----------------------|-------------|----------------|--------------------|
| MarketFactory     | CreateMarket          | 0.06        | 0.024          | 0.009              |
| PredictionMarket  | MarketInitialize      | 0.027       | 0.0036         | 0.017              |
| PredictionMarket  | PlaceBet              | 0.04        | 0.02           |                    |
| PredictionMarket  | ResolveMarket         |             |                |                    |
| PredictionMarket  | ClaimWinningsInfo     |             |                |                    |
| UserBet           | PlaceBetInternal      | 0.02        | 0.011          | 0.0066             |
| UserBet           | claimWinnings         |             |                |                    |
| UserBet           | claimWinningsInternal |             |                |                    |



## Project structure

-   `contracts` - source code of all the smart contracts of the project and their dependencies.
-   `wrappers` - wrapper classes (implementing `Contract` from ton-core) for the contracts, including any [de]serialization primitives and compilation functions.
-   `tests` - tests for the contracts.
-   `scripts` - scripts used by the project, mainly the deployment scripts.

## How to use

### Build

`npx blueprint build` or `yarn blueprint build`

### Test

`npx blueprint test` or `yarn blueprint test`

### Deploy or run another script

`npx blueprint run` or `yarn blueprint run`

### Add a new contract

`npx blueprint create ContractName` or `yarn blueprint create ContractName`
