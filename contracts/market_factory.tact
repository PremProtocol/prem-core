import "@stdlib/deploy";

contract MarketFactory with Deployable {
    map<Uint, Address> markets;
    counter: Uint;

    init() {
        self.counter = 0;
    }

    receive("createMarket", eventDescription: String, endTime: Uint) {
        let newMarket = PredictionMarket(eventDescription, endTime, selfmsg.sender);
        self.markets[self.counter] = newMarket;
        self.counter += 1;
    }

    get fun getMarket(marketId: Uint): Address {
        return self.markets[marketId];
    }
}
