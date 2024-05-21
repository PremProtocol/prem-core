import "@stdlib/deploy";

message Initialize {
    user: Address;
    market: Address;
}

contract UserBet with Deployable {
    user: Address;
    market: Address;
    betAmount: Int as uint64;
    outcome: Int as int8;

    init(user: Address, market: Address) {
        self.user = user;
        self.market = market;
        self.betAmount = 0;
        self.outcome = -1; // Default to no outcome
    }

    receive(msg: Initialize) {
        self.user = msg.user;
        self.market = msg.market;
    }

    receive(msg: PlaceBet) {
        require(self.outcome == -1, 1201, "Bet already placed");
        self.outcome = msg.outcome;
        self.betAmount = msg.value;
    }

    receive("claimWinnings") {
        require(PredictionMarket(self.market).isResolved(), 1202, "Market not resolved");

        let actualOutcome = PredictionMarket(self.market).resolvedOutcome();
        if (self.outcome == actualOutcome) {
            let totalPool = PredictionMarket(self.market).totalPool();
            let userShare = (self.betAmount * totalPool) / PredictionMarket(self.market).totalBetForOutcome(self.outcome);
            self.user.transfer(userShare);
        } else {
            revert(1203, "No winnings to claim");
        }
    }
}
