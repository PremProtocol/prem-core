// MarketFactory Messages
message CreateMarketResponse {
    address: Address;
}

message CreateMarket {
    eventDescription: String;
    endTime: Int as uint64;
    numOutcomes: Int as uint8;
}

// PredictionMarket Messages
message PlaceBet {
    outcome: Int as int8;
}

message ResolveMarket {
    outcome: Int as int8;
}

// UserBet Messages
message PlaceBetInternal {
    outcome: Int as int8;
}

