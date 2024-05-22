struct Outcomes {
    name: String;
}

// MarketFactory Messages
message CreateMarketResponse {
    address: Address;
}

message CreateMarket {
    eventDescription: String;
    endTime: Int as uint64;
    outcomes: map<Int as uint8, Outcomes>;
    numOutcomes: Int as uint8;
}

// PredictionMarket Messages
message PlaceBet {
    outcome: Int as uint8;
}

message ResolveMarket {
    outcome: Int as uint8;
}

// UserBet Messages
message PlaceBetInternal {
    outcome: Int as uint8;
}

