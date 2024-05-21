import "@stdlib/deploy";
import "./user_bet.tact";

message InitializePredictionMarket {
    eventDescription: String;
    endTime: Int as uint64;
    creator: Address;
    numOutcomes: Int as uint8;
}

message PlaceBet {
    outcome: Int as int8;
    value: Int as uint64;
}

message ResolveMarket {
    outcome: Int as int8;
}

contract PredictionMarket with Deployable {
    creator: Address;
    eventDescription: String;
    endTime: Int as uint64;
    resolved: Bool;
    outcome: Int as int8;
    numOutcomes: Int as uint8;
    totalBets: map<Int as uint8, Int as uint64>; // Map to store bets for each outcome
    totalPool: Int as uint64;

    init(msg: InitializePredictionMarket) {
        self.creator = msg.creator;
        self.eventDescription = msg.eventDescription;
        self.endTime = msg.endTime;
        self.resolved = false;
        self.outcome = -1; // No outcome resolved yet
        self.numOutcomes = msg.numOutcomes;
        self.totalPool = 0;
    }

    receive(msg: PlaceBet) {
        require(now() < self.endTime, "Betting has ended");
        require(msg.outcome >= 0 && msg.outcome < self.numOutcomes, "Invalid outcome");

        let currentBet: Int = self.totalBets.get(msg.outcome)!!;
        self.totalBets.set(msg.outcome, currentBet + msg.value);
        self.totalPool += msg.value;

        // Deploy UserBet contract for the user
        let userBetInitState: StateInit = initOf UserBet(InitializeUserBet{
            user: sender(), 
            market: myAddress()
        });
        let userBetAddress: Address = contractAddress(userBetInitState);

        send(SendParameters{
            to: userBetAddress,
            value: ton("0.1"), // Adjust this value as needed
            mode: SendIgnoreErrors,
            code: userBetInitState.code,
            data: userBetInitState.data,
            body: "initialize".asComment()
        });
    }

    receive(msg: ResolveMarket) {
        require(now() >= self.endTime, "Event has not ended");
        require(!self.resolved, "Market already resolved");
        require(msg.outcome >= 0 && msg.outcome < self.numOutcomes, "Invalid outcome");

        self.resolved = true;
        self.outcome = msg.outcome;
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
