import "@stdlib/deploy";
import "@stdlib/ownable";
import "./prediction_market.tact";
import "./messages.tact";

// FactoryDeployable for cashback???
// https://github.com/tact-lang/tact/blob/main/stdlib/libs/deploy.tact
contract MarketFactory with Deployable, OwnableTransferable {
    owner: Address;

    init() {
        self.owner = sender();
    }

    receive(msg: CreateMarket) {
        require(msg.endTime > now(), "End time must be in the future");
        require(!msg.outcomes.isEmpty(), "Should be more tham 1 outcomes");
        require(msg.numOutcomes >= 0, "Should be more tham 1 outcomes");
        require(msg.eventDescription != "", "Event description has must be provided");
        //require(msg.eventDescription.length() < 100, "Event description must be less than 100 characters");
        self.requireOwner();

        let preMarketContractAddress: Address = self.deployPredictionMarket(msg.eventDescription, msg.endTime, msg.outcomes, msg.numOutcomes);
        
        // pay-back remaining gas
        self.reply(CreateMarketResponse{address: preMarketContractAddress}.toCell());
    }

    fun deployPredictionMarket(eventDescription: String, endTime: Int, outcomes: map<Int as uint8, Outcomes>, numOutcomes: Int): Address {
        let initState: StateInit = initOf PredictionMarket(myAddress(), sender(), eventDescription, endTime, outcomes, numOutcomes);
        let preMarketContractAddress: Address = contractAddress(initState);
        send(SendParameters{
            to: preMarketContractAddress,
            value: ton("0.3"),
            mode: SendIgnoreErrors,
            code: initState.code,
            data: initState.data,
            body: "deploy".asComment()
        });
        return preMarketContractAddress;
    }
}