// MarketFactory Messages
message CreateMarketResponse {
    address: Address;
}

message CreateMarket {
    eventName: String;
    eventDescription: String;
    eventType: String;
    endTime: Int as uint64;
    // need to rewrite it to map, but luck of examples/tools
    outcomeName1: String;
    outcomeName2: String;
    liquidityAmount: Int as coins;
    initialOddsForOutcome1: Int as uint8;
}

// PredictionMarket Messages
message MarketInitialize {
    owner: Address;
    protocolOwner: Address;
    eventName: String;
    eventDescription: String;
    eventType: String;
    endTime: Int as uint64;
    // need to rewrite it to map, but luck of examples/tools
    outcomeName1: String;
    outcomeName2: String;
    liquidityAmount: Int as coins;
    initialOddsForOutcome1: Int as uint8;
}

message AddLiquidity {
    amount: Int as coins;
}

message RemoveLiquidity {
    amount: Int as coins;
}

message PlaceBet {
    amount: Int as coins;
    outcome: Int as int8;
}

message ResolveMarket {
    outcome: Int as int8;
}

message ClaimWinningsInfo {
    betAmount: Int as coins;
    walletAddress: Address;
    outcome: Int as int8;
}

message PredictionMarketDetails {
    owner: Address;
    parent: Address;
    seqno: Int as uint64;
    eventName: String;
    eventDescription: String;
    eventType: String;
    endTime: Int as uint64;
    outcomeName1: String;
    outcomeName2: String;
    totalOutcome1Bets: Int as coins;
    totalOutcome2Bets: Int as coins;
    totalPool: Int as coins;
    totalLiquidity: Int as coins;
    reserve1: Int as coins;
    reserve2: Int as coins;
    oddsForOutcome1: Int as uint8;
    protocolFeePercentage: Int as uint8;
    outcome: Int as int8;
    resolved: Bool;
    protocolFees: Int as coins;
    isRemoved: Bool;
}

// UserBet Messages
message PlaceBetInternal {
    outcome: Int as int8;
    betAmount: Int as coins;
}

message UserBetInfo{
    outcome: Int as int8;
    betAmount: Int as coins;
    isClaimed: Bool;
}

