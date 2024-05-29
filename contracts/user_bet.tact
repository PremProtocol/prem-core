import "@stdlib/deploy";
import "./messages.tact";

contract UserBet with Deployable {
    const MinTonForStorage: Int = ton("0.01");
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
        //require(sender() == self.parent, "Only the market can place a bet");
        require(self.outcome == -1, "Bet already placed");
        self.outcome = msg.outcome;
        //TODO: Think about adding more than one bet in future
        self.betAmount = msg.betAmount;

        // Transfer the bet amount to the contract
        send(SendParameters{
            to: self.owner,
            value: context().value - self.MinTonForStorage,
            mode: SendIgnoreErrors,
            body: "refund".asComment()
        });
    }

    receive("claimWinnings") {
        require(sender() == self.owner, "Only the owner can claim winnings");

        send(SendParameters{
            to: self.parent,
            value: ton("0.04"),
            mode: SendIgnoreErrors,
            body: ClaimWinningsInfo{
                outcome: self.outcome,
                betAmount: self.betAmount,
                userBet: myAddress()}.toCell()
        });
    }

    receive("claimWinningsInternal") {
        require(sender() == self.parent, "Only the market can call this function");
        
        send(SendParameters{
            to: self.owner,
            value: 0,
            mode: SendRemainingBalance | SendRemainingValue | SendDestroyIfZero | SendIgnoreErrors,
        });
    }

    bounced(src: Slice) {
        // ...
    }

    get fun userBet(): UserBetInfo {
        return UserBetInfo{
            betAmount: self.betAmount,
            outcome: self.outcome};
    }
}
