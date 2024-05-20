import "@stdlib/deploy";

contract PredictionMarket with Deployable {
    creator: Address;
    eventDescription: String;
    endTime: Uint;
    resolved: Bool;
    outcome: Uint;
    map<Address, Uint> betsForOutcome1;
    map<Address, Uint> betsForOutcome2;
    totalBetsOutcome1: Uint;
    totalBetsOutcome2: Uint;

    init(eventDescription: String, endTime: Uint, creator: Address) {
        self.creator = creator;
        self.eventDescription = eventDescription;
        self.endTime = endTime;
        self.resolved = false;
        self.outcome = 0;
        self.totalBetsOutcome1 = 0;
        self.totalBetsOutcome2 = 0;
    }

    receive("placeBet", outcome: Uint) payable {
        require(self.now() < self.endTime, 1001, "Betting has ended");

        if (outcome == 1) {
            self.betsForOutcome1[selfmsg.sender] += selfmsg.value;
            self.totalBetsOutcome1 += selfmsg.value;
        } else {
            self.betsForOutcome2[selfmsg.sender] += selfmsg.value;
            self.totalBetsOutcome2 += selfmsg.value;
        }
    }

    receive("resolveMarket", outcome: Uint) {
        require(self.now() >= self.endTime, 1002, "Event has not ended");
        require(!self.resolved, 1003, "Market already resolved");
        
        self.resolved = true;
        self.outcome = outcome;
    }

    receive("claimWinnings") {
        require(self.resolved, 1004, "Market not resolved");

        let winnings: Uint;
        if (self.outcome == 1) {
            winnings = self.betsForOutcome1[selfmsg.sender] * (self.totalBetsOutcome1 + self.totalBetsOutcome2) / self.totalBetsOutcome1;
        } else {
            winnings = self.betsForOutcome2[selfmsg.sender] * (self.totalBetsOutcome1 + self.totalBetsOutcome2) / self.totalBetsOutcome2;
        }

        require(winnings > 0, 1005, "No winnings to claim");

        selfmsg.sender.transfer(winnings);
    }
}
