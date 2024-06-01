import "@stdlib/deploy";
import "./user_bet.tact";
import "./messages.tact";

contract PredictionMarket with Deployable {
    const MinTonForStorage: Int = ton("0.02");
    owner: Address;
    parent: Address;
    seqno: Int as uint64;
    eventDescription: String;
    eventType: String;
    endTime: Int as uint64;
    resolved: Bool;
    outcome: Int as int8;
    outcomeName1: String;
    outcomeName2: String;
    numOutcomes: Int as uint8;
    totalOutcomeBets: map<Int as uint8, Int as uint64>;
    totalPool: Int as uint64;

    init(parent: Address, 
            seqno: Int) {
        self.owner = newAddress(0, 0);
        self.parent = parent;
        self.seqno = seqno;
        self.eventDescription = "";
        self.eventType = "";
        self.endTime = 0;
        self.outcomeName1 = "";
        self.outcomeName2 = "";
        self.numOutcomes = 0;
        self.resolved = false;
        self.outcome = -1;
        self.totalPool = 0;
    }

    receive(msg: MarketInitialize) {
        require(sender() == self.parent, "Only parent contract can init the market");
        require(msg.endTime > now(), "End time must be in the future");
        require(msg.outcomeName1 != "", "Outcome names must be provided");
        require(msg.outcomeName2 != "", "Outcome names must be provided");
        require(msg.numOutcomes == 2, "Should be only 2 outcomes");
        require(msg.eventDescription != "", "Event description has must be provided");
        require(msg.eventType != "", "Event type has must be provided");
        
        self.owner = msg.owner;
        self.eventDescription = msg.eventDescription;
        self.eventType = msg.eventType;
        self.endTime = msg.endTime;
        self.outcomeName1 = msg.outcomeName1;
        self.outcomeName2 = msg.outcomeName2;
        self.numOutcomes = msg.numOutcomes;
        self.totalOutcomeBets.set(0, 0);
        self.totalOutcomeBets.set(1, 0);

        // pay-back remaining gas
        if (context().value > self.MinTonForStorage) {
            send(SendParameters{
                to: self.owner,
                value: context().value - self.MinTonForStorage,
                mode: SendIgnoreErrors,
                body: "refund".asComment()
            });
        }
    }

    receive(msg: PlaceBet) {
        require(now() < self.endTime, "Betting has ended");
        require(msg.outcome >= 0 && msg.outcome < self.numOutcomes, "Invalid outcome");

        let currentBet: Int = self.totalOutcomeBets.get(msg.outcome)!!;
        let newBetAmount: Int = context().value - ton("0.03"); // left some coins for gas cost
        self.totalOutcomeBets.set(msg.outcome, 0 + newBetAmount);
        self.totalPool += newBetAmount;

        self.placeUserBet(sender(), myAddress(), newBetAmount, msg.outcome);
    }

    receive(msg: ResolveMarket) {
        require(sender() == self.owner, "Only owner can resolve market");
        require(now() >= self.endTime, "Event has not ended");
        require(!self.resolved, "Market already resolved");
        require(msg.outcome >= 0 && msg.outcome < self.numOutcomes, "Invalid outcome");

        self.resolved = true;
        self.outcome = msg.outcome;

        // pay-back remaining gas
        self.reply("gas returned".asComment());
    }

    receive(msg: ClaimWinningsInfo) {
        require(self.resolved, "Market should be resolved to claim winnings");
        require(self.outcome == msg.outcome, "Outcome does not match the bet outcome");
        let userBetInitState: StateInit = initOf UserBet(msg.walletAddress, myAddress());
        let userBetAddress: Address = contractAddress(userBetInitState);
        require(sender() == userBetAddress, "Only owner can claim winnings");
        
        let userShare: Int = (msg.betAmount * self.totalPool) / self.totalOutcomeBets.get(msg.outcome)!!;
        send(SendParameters{
            to: sender(),
            value: userShare,
            mode: SendRemainingValue + SendIgnoreErrors,
            body: "claimWinningsInternal".asComment()
        });
    }

    bounced(src: Slice) {
        // ...
    }

    fun placeUserBet(owner: Address, parent: Address, betAmount: Int, outcome: Int) {
        let userBetInitState: StateInit = initOf UserBet(owner, parent);
        let userBetAddress: Address = contractAddress(userBetInitState);
        send(SendParameters{
            to: userBetAddress,
            value: ton("0.025"),
            mode: SendIgnoreErrors,
            code: userBetInitState.code,
            data: userBetInitState.data,
            body: PlaceBetInternal{outcome: outcome, betAmount: betAmount}.toCell()
        });
    }

    get fun predictionMarketDetails(): PredictionMarketDetails {
        return PredictionMarketDetails{owner: self.owner,
            eventDescription: self.eventDescription,
            eventType: self.eventType,
            endTime: self.endTime,
            outcomeName1: self.outcomeName1,
            outcomeName2: self.outcomeName2,
            numOutcomes: self.numOutcomes,
            totalOutcomeBets: self.totalOutcomeBets,
            totalPool: self.totalPool,
            resolved: self.resolved,
            outcome: self.outcome
        };
    }

    get fun totalPool(): Int {
        return self.totalPool;
    }

    get fun totalBetForOutcome(outcome: Int): Int {
        require(outcome >= 0 && outcome < self.numOutcomes, "Invalid outcome");
        return self.totalOutcomeBets.get(outcome)!!;
    }

    get fun resolvedOutcome(): Int {
        return self.outcome;
    }

    get fun isResolved(): Bool {
        return self.resolved;
    }
}
