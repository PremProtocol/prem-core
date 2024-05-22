import "@stdlib/deploy";
import "./user_bet.tact";
import "./messages.tact";

contract PredictionMarket with Deployable {
    creator: Address;
    eventDescription: String;
    endTime: Int as uint64;
    resolved: Bool;
    outcome: Int as uint8;
    outcomes: map<Int as uint8, Outcomes>;
    numOutcomes: Int as uint8;
    totalBets: map<Int as uint8, Int as uint64>; // Map to store bets for each outcome
    totalPool: Int as uint64;

    init(parent: Address, 
            creator: Address,
            eventDescription: String, 
            endTime: Int, 
            outcomes: map<Int as uint8, Outcomes>,
            numOutcomes: Int) {
        self.creator = creator;
        self.eventDescription = eventDescription;
        self.endTime = endTime;
        self.outcomes = outcomes;
        self.numOutcomes = numOutcomes;
        self.resolved = false;
        self.outcome = -1; // No outcome resolved yet
        self.totalPool = 0;
    }

    receive(msg: PlaceBet) {
        require(now() < self.endTime, "Betting has ended");
        require(msg.outcome >= 0 && msg.outcome < self.numOutcomes, "Invalid outcome");

        let currentBet: Int = self.totalBets.get(msg.outcome)!!;

        let newBetAmount: Int = context().value - ton("0.02"); // left some coins for gas cost
        self.totalBets.set(msg.outcome, currentBet + newBetAmount);
        self.totalPool += newBetAmount;

        // TODO: move to separate function
        self.deployUserBet(sender(), myAddress(), newBetAmount, msg.outcome);

        // TODO: reply to return gas cost???
    }

    receive(msg: ResolveMarket) {
        require(sender() == self.creator, "Only creator can resolve market");
        require(now() >= self.endTime, "Event has not ended");
        require(!self.resolved, "Market already resolved");
        require(msg.outcome >= 0 && msg.outcome < self.numOutcomes, "Invalid outcome");

        self.resolved = true;
        self.outcome = msg.outcome;

        // pay-back remaining gas
        self.reply("gas returned".asComment());
    }

    bounced(src: Slice) {
        // ...
    }

    fun deployUserBet(owner: Address, parent: Address, betAmount: Int, outcome: Int) {
        let userBetInitState: StateInit = initOf UserBet(owner, parent);
        let userBetAddress: Address = contractAddress(userBetInitState);
        send(SendParameters{
            to: userBetAddress,
            value: betAmount,
            mode: SendIgnoreErrors,
            code: userBetInitState.code,
            data: userBetInitState.data,
            body: PlaceBetInternal{outcome: outcome}.toCell()
        });
    }

    get fun totalPool(): Int {
        return self.totalPool;
    }

    get fun totalBetForOutcome(outcome: Int): Int {
        require(outcome >= 0 && outcome < self.numOutcomes, "Invalid outcome");
        return self.totalBets.get(outcome)!!;
    }

    get fun resolvedOutcome(): Int {
        return self.outcome;
    }

    get fun isResolved(): Bool {
        return self.resolved;
    }
}
