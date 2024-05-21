import "@stdlib/deploy";
import "./user_bet.tact";

message Initialize {
    eventDescription: String;
    endTime: Int as uint64;
    creator: Address;
    numOutcomes: Int as uint8;
}

message PlaceBet {
    outcome: Int as int8;
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
    totalBets: Int as uint64[];

    init(eventDescription: String, endTime: Int as uint64, creator: Address, numOutcomes: Int as uint8) {
        self.creator = creator;
        self.eventDescription = eventDescription;
        self.endTime = endTime;
        self.resolved = false;
        self.outcome = -1; // No outcome resolved yet
        self.numOutcomes = numOutcomes;
        self.totalBets = new Int as uint64[self.numOutcomes];
        for (let i = 0; i < self.numOutcomes; i++) {
            self.totalBets[i] = 0;
        }
    }

    receive(msg: PlaceBet) {
        require(now() < self.endTime, 1101, "Betting has ended");
        require(msg.outcome >= 0 && msg.outcome < self.numOutcomes, 1102, "Invalid outcome");

        // Deploy UserBet contract for the user
        let userBetInitState: StateInit = initOf UserBet(sender(), self);
        let userBetAddress: Address = contractAddress(userBetInitState);

        send(SendParameters{
            to: userBetAddress,
            value: ton("0.1"), // Adjust this value as needed
            mode: SendIgnoreErrors,
            code: userBetInitState.code,
            data: userBetInitState.data,
            body: "initialize".asComment()
        });

        self.totalBets[msg.outcome] += msg.value;
    }

    receive(msg: ResolveMarket) {
        require(now() >= self.endTime, 1103, "Event has not ended");
        require(!self.resolved, 1104, "Market already resolved");
        require(msg.outcome >= 0 && msg.outcome < self.numOutcomes, 1105, "Invalid outcome");

        self.resolved = true;
        self.outcome = msg.outcome;
    }

    get fun totalPool(): Int as uint64 {
        let total: Int as uint64 = 0;
        for (let i = 0; i < self.numOutcomes; i++) {
            total += self.totalBets[i];
        }
        return total;
    }

    get fun totalBetForOutcome(outcome: Int as int8): Int as uint64 {
        require(outcome >= 0 && outcome < self.numOutcomes, 1106, "Invalid outcome");
        return self.totalBets[outcome];
    }

    get fun resolvedOutcome(): Int as int8 {
        return self.outcome;
    }

    get fun isResolved(): Bool {
        return self.resolved;
    }
}