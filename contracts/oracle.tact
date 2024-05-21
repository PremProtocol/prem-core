import "@stdlib/deploy";

message SetOutcome {
    market: Address;
    outcome: Int as int8;
}

contract Oracle with Deployable {
    owner: Address;

    init(owner: Address) {
        self.owner = owner;
    }

    receive(msg: SetOutcome) {
        require(sender() == self.owner, 1301, "Only owner can set outcome");
        PredictionMarket(msg.market).receive(ResolveMarket(msg.outcome));
    }
}
