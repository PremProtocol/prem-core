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
        //require(sender() == self.parent, "Only the market can place a bet");
        require(self.outcome == -1, "Bet already placed");
        self.outcome = msg.outcome;
        //TODO: Think about adding more than one bet in future
        self.betAmount = msg.betAmount;

        //TODO: Gas refund if bet is not placed
        //self.reply("gas returned".asComment());
    }

    receive("claimWinnings") {
        require(sender() == self.owner, "Only the owner can claim winnings");

        send(SendParameters{
            to: self.parent,
            value: ton("0.02"),
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
            mode: SendRemainingBalance | SendDestroyIfZero | SendIgnoreErrors,
        });
    }

    get fun userBet(): UserBetInfo {
        return UserBetInfo{
            betAmount: self.betAmount,
            outcome: self.outcome};
    }
}
