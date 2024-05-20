# prem

## Project Overview
Prediction Market: A platform where users can bet on the outcomes of future events. If the predicted event occurs, those who bet on that outcome receive rewards.

## Key Components

1. Market Creation: Users can create new prediction markets.
2. Betting: Users can place bets on different outcomes.
3. Resolution: The outcome is determined after the event.
4. Settlement: Winners are paid out based on the event outcome.

## Smart Contracts Architecture

### Market Factory Contract:

Creates new prediction markets.
Keeps a registry of all active and past markets.

### Prediction Market Contract:

Handles the specific event being bet on.
Manages the bets and the total pool for each outcome.
Resolves the market based on the outcome.
Distributes the winnings.

### Token Contract (optional, if using custom tokens):

Manages the platform's native token for betting and payouts.

### Oracle Contract:

Feeds the result of the events into the Prediction Market Contract.
Needs to be trusted and accurate to avoid manipulation.

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
