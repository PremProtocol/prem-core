import "@stdlib/deploy";
import "./messages.tact";

contract UserBet with Deployable {
    owner: Address;
    parent: Address;
    betAmount: Int as uint64;
    outcome: Int as int8;

    init(owner: Address, parent: Address) {
        self.owner = owner;
        self.parent = parent;
        self.betAmount = 0;
        self.outcome = -1;
    }

    receive(msg: PlaceBetInternal) {
        require(sender() == self.parent, "Only the market can place a bet");
        require(self.outcome == -1, "Bet already placed");
        self.outcome = msg.outcome;

        //TODO: Think about adding more than one bet in future
        self.betAmount = context().value;

        //TODO: Gas refund if bet is not placed
    }

    // receive("claimWinnings") {
    //     require(PredictionMarket(self.parent).isResolved(), "Market not resolved");

    //     let actualOutcome = PredictionMarket(self.parent).resolvedOutcome();
    //     if (self.outcome == actualOutcome) {
    //         let totalPool = PredictionMarket(self.parent).totalPool();
    //         let userShare = (self.betAmount * totalPool) / PredictionMarket(self.market).totalBetForOutcome(self.outcome);
    //         self.user.transfer(userShare);
    //     } else {
    //         revert(1203, "No winnings to claim");
    //     }
    // }
}
