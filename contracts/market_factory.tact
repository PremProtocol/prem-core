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
        require(msg.outcomeName1 != "", "Outcome names must be provided");
        require(msg.outcomeName2 != "", "Outcome names must be provided");
        require(msg.numOutcomes == 2, "Should be only 2 outcomes");
        require(msg.eventDescription != "", "Event description has must be provided");
        //require(msg.eventDescription.length() < 100, "Eventoutcomes description must be less than 100 characters");
        self.requireOwner();

        let preMarketContractAddress: Address = self.deployPredictionMarket(msg.eventDescription, msg.endTime, msg.outcomeName1, msg.outcomeName2, msg.numOutcomes);
        
        // returning all excess
        self.reply(CreateMarketResponse{address: preMarketContractAddress}.toCell());
    }

    fun deployPredictionMarket(eventDescription: String, endTime: Int, outcomeName1: String, outcomeName2: String, numOutcomes: Int): Address {
        let initState: StateInit = initOf PredictionMarket(sender(), myAddress(), eventDescription, endTime, outcomeName1, outcomeName2, numOutcomes);
        let preMarketContractAddress: Address = contractAddress(initState);
        send(SendParameters{
            to: preMarketContractAddress,
            value: ton("0.3"),
            mode: SendIgnoreErrors,
            code: initState.code,
            data: initState.data
        });
        return preMarketContractAddress;
    }
}