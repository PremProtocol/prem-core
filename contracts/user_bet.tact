import "@stdlib/deploy";
import "./messages.tact";

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

    receive(msg: PlaceBetInternal) {
        receive(sender() == self.market, "Only the market can place a bet")
        require(self.outcome == -1, "Bet already placed");
        self.outcome = msg.outcome;

        //TODO: Think about adding more than one bet in future
        self.betAmount = context().value;

        //TODO: Gas refund if bet is not placed
    }

    // receive("claimWinnings") {
    //     require(PredictionMarket(self.market).isResolved(), "Market not resolved");

    //     let actualOutcome = PredictionMarket(self.market).resolvedOutcome();
    //     if (self.outcome == actualOutcome) {
    //         let totalPool = PredictionMarket(self.market).totalPool();
    //         let userShare = (self.betAmount * totalPool) / PredictionMarket(self.market).totalBetForOutcome(self.outcome);
    //         self.user.transfer(userShare);
    //     } else {
    //         revert(1203, "No winnings to claim");
    //     }
    // }
}
