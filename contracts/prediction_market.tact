import "@stdlib/deploy";
import "./user_bet.tact";
import "./messages.tact";

contract PredictionMarket with Deployable {
    const numOutcomes: Int = 2;
    const MinTonForStorage: Int = ton("0.02");
    const TonForCompute: Int = ton("0.02");
    owner: Address;
    parent: Address;
    seqno: Int as uint64;
    eventName: String;
    eventDescription: String;
    eventType: String;
    endTime: Int as uint64;
    resolved: Bool;
    isRemoved: Bool;
    outcome: Int as int8;
    outcomeName1: String;
    outcomeName2: String;
    totalOutcome1Bets: Int as coins;
    totalOutcome2Bets: Int as coins;
    totalPool: Int as coins;
    totalLiquidity: Int as coins;
    reserve1: Int as coins;
    reserve2: Int as coins;
    oddsForOutcome1: Int as uint8;
    protocolFeePercentage: Int as uint8;
    protocolFees: Int as coins;

    init(parent: Address, 
            seqno: Int) {
        self.owner = newAddress(0, 0);
        self.parent = parent;
        self.seqno = seqno;
        self.eventName = "";
        self.eventDescription = "";
        self.eventType = "";
        self.endTime = 0;
        self.outcomeName1 = "";
        self.outcomeName2 = "";
        self.isRemoved = false;
        self.resolved = false;
        self.outcome = -1;
        self.totalOutcome1Bets = 0;
        self.totalOutcome2Bets = 0;
        self.totalPool = 0;
        self.totalLiquidity = 0;
        self.reserve1 = 0;
        self.reserve2 = 0;
        self.oddsForOutcome1 = 0;
        self.protocolFeePercentage = 10; // 1% fee for the protocol owner
        self.protocolFees = 0;
    }

    receive(msg: MarketInitialize) {
        require(sender() == self.parent, "Only parent contract can init the market");
        require(msg.endTime > now(), "End time must be in the future");
        
        self.owner = msg.owner;
        self.eventName = msg.eventName;
        self.eventDescription = msg.eventDescription;
        self.eventType = msg.eventType;
        self.endTime = msg.endTime;
        self.outcomeName1 = msg.outcomeName1;
        self.outcomeName2 = msg.outcomeName2;

        // pay-back remaining gas
        send(SendParameters{
            to: self.owner,
            value: context().value - self.MinTonForStorage,
            mode: SendIgnoreErrors,
            body: "gas excesses".asComment()
        });
    }

    receive(msg: AddLiquidity) {
        require(msg.amount > 0 && msg.amount < context().value + self.TonForCompute, "Amount must be positive and less than the value sent");
        require(sender() == self.owner, "Only owner contract can provire liquidity for the market");
        
        self.setLiquidity(msg.amount, msg.oddsForOutcome1);

        // pay-back remaining gas
        send(SendParameters{
            to: self.owner,
            value: context().value - msg.amount - self.TonForCompute,
            mode: SendIgnoreErrors,
            body: "gas excesses".asComment()
        });
    }

    receive(msg: RemoveLiquidity) {
        require(msg.amount > 0, "Amount must be positive");
        require(sender() == self.owner, "Only owner contract can provire liquidity for the market");
        
        self.removeLiquidity(msg.amount);
    }

    receive(msg: PlaceBet) {
        require(msg.amount > 0 && msg.amount < context().value + self.TonForCompute, "Amount must be positive and less than the value sent");
        require(now() < self.endTime, "Betting has ended");
        require(msg.outcome >= 0 && msg.outcome < self.numOutcomes, "Invalid outcome");

        let commission: Int = (msg.amount * self.protocolFeePercentage) / 1000;
        self.protocolFees += commission;
        
        let newBetAmount: Int = msg.amount - commission;
        if(msg.outcome == 0) {
            self.totalOutcome1Bets += newBetAmount;
        } else if(msg.outcome == 1) {
            self.totalOutcome2Bets += newBetAmount;
        }

        // Calculate the win percentage for the selected outcome
        self.totalPool += newBetAmount;
        let winPercentage: Int = (msg.outcome == 0 ? self.totalOutcome1Bets : self.totalOutcome2Bets) * 100 / self.totalPool;
        
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
        self.reply("gas excesses".asComment());
    }

    receive(msg: ClaimWinningsInfo) {
        require(self.resolved, "Market should be resolved to claim winnings");
        require(self.outcome == msg.outcome, "Outcome does not match the bet outcome");
        let userBetInitState: StateInit = initOf UserBet(msg.walletAddress, myAddress());
        let userBetAddress: Address = contractAddress(userBetInitState);
        require(sender() == userBetAddress, "Only owner can claim winnings");
        
        let currentBets: Int = msg.outcome == 0 ? self.totalOutcome1Bets : self.totalOutcome2Bets;
        let userShare: Int = (msg.betAmount * self.totalPool) / currentBets;
        send(SendParameters{
            to: sender(),
            value: userShare,
            mode: SendRemainingValue + SendIgnoreErrors,
            body: "claimWinningsInternal".asComment()
        });
    }

    receive("collectFees") {
        require(sender() == self.owner, "Only owner contract can collect fees");
        
        let protocolFeesToCollect: Int = self.protocolFees;
        self.protocolFees = 0;

        send(SendParameters{
            to: self.owner,
            value: protocolFeesToCollect,
            mode: SendRemainingValue + SendIgnoreErrors,
            body: "collectFees".asComment()
        });
    }

    receive("remove") {
        require(sender() == self.owner, "Only owner contract can collect fees");
        require(self.resolved, "Market may be removed to before delete");
        require(now() < self.endTime + (14 * 86400), "Market may be removed to after 2 weeks"); // end time + 2 weeks
        require(self.totalLiquidity == 0, "Market may be removed to after liquidity is removed");
        require(self.protocolFees == 0, "Market may be removed to after protocol fees are collected");
        
        self.isRemoved = true;

        send(SendParameters{
            to: self.owner,
            value: 0,
            mode: SendRemainingValue + SendIgnoreErrors,
            body: "gas excesses".asComment()
        });
    }

    bounced(src: Slice) {
        // ...
    }

    fun setLiquidity(amountLiquidity: Int, oddsForOutcome1: Int) {
        self.oddsForOutcome1 = oddsForOutcome1;

        let liquidityForOutcome1: Int = (amountLiquidity * oddsForOutcome1) / 100;
        let liquidityForOutcome2: Int = amountLiquidity - liquidityForOutcome1;

        self.totalLiquidity += amountLiquidity;
        self.reserve1 = liquidityForOutcome1;
        self.reserve2 = liquidityForOutcome2;

        self.totalPool += amountLiquidity;
        self.totalOutcome1Bets += liquidityForOutcome1;
        self.totalOutcome2Bets += liquidityForOutcome2;
    }

    fun removeLiquidity(withdrawLiquidity: Int) {
        let liquidityForOutcome1: Int = (withdrawLiquidity * self.oddsForOutcome1) / 100;
        let liquidityForOutcome2: Int = withdrawLiquidity - liquidityForOutcome1;

        self.totalLiquidity -= withdrawLiquidity;
        self.reserve1 -= liquidityForOutcome1;
        self.reserve2 -= liquidityForOutcome2;

        self.totalPool -= withdrawLiquidity;
        self.totalOutcome1Bets -= liquidityForOutcome1;
        self.totalOutcome2Bets -= liquidityForOutcome2;

        let amount: Int = min(withdrawLiquidity, myBalance() - context().value - self.MinTonForStorage);
        
        send(SendParameters{
            to: sender(),
            value: amount,
            mode: SendRemainingValue + SendIgnoreErrors,
            body: "removeLiquidity".asComment()
        });
    }

    fun placeUserBet(owner: Address, parent: Address, betAmount: Int, outcome: Int) {
        let userBetInitState: StateInit = initOf UserBet(owner, parent);
        let userBetAddress: Address = contractAddress(userBetInitState);
        send(SendParameters{
            to: userBetAddress,
            value: context().value - betAmount,
            mode: SendIgnoreErrors,
            code: userBetInitState.code,
            data: userBetInitState.data,
            body: PlaceBetInternal{outcome: outcome, betAmount: betAmount}.toCell()
        });
    }

    get fun predictionMarketDetails(): PredictionMarketDetails {
        return PredictionMarketDetails{owner: self.owner,
            parent: self.parent,
            seqno: self.seqno,
            eventName: self.eventName,
            eventDescription: self.eventDescription,
            eventType: self.eventType,
            endTime: self.endTime,
            outcomeName1: self.outcomeName1,
            outcomeName2: self.outcomeName2,
            totalOutcome1Bets: self.totalOutcome1Bets,
            totalOutcome2Bets: self.totalOutcome2Bets,
            totalPool: self.totalPool,
            totalLiquidity: self.totalLiquidity,
            reserve1: self.reserve1,
            reserve2: self.reserve2,
            oddsForOutcome1: self.oddsForOutcome1,
            protocolFeePercentage: self.protocolFeePercentage,
            resolved: self.resolved,
            outcome: self.outcome,
            protocolFees: self.protocolFees,
            isRemoved: self.isRemoved
        };
    }

    get fun totalPool(): Int {
        return self.totalPool;
    }

    get fun totalBetForOutcome(outcome: Int): Int {
        require(outcome >= 0 && outcome < self.numOutcomes, "Invalid outcome");
        return outcome == 0 ? self.totalOutcome1Bets : self.totalOutcome2Bets;
    }

    get fun resolvedOutcome(): Int {
        return self.outcome;
    }

    get fun isResolved(): Bool {
        return self.resolved;
    }
}
