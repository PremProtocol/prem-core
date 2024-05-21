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
        require(msg.numOutcomes > 1, "Number of outcomes must be greater than 1");
        require(msg.eventDescription != "", "Event description has must be provided");
        //require(msg.eventDescription.length() < 100, "Event description must be less than 100 characters");
        //requireOwner();

        // TODO: move to separate function
        let initState: StateInit = initOf PredictionMarket(myAddress(), msg.eventDescription, msg.endTime, sender(), msg.numOutcomes);
        let preMarketContractAddress: Address = contractAddress(initState);
        send(SendParameters{
            to: preMarketContractAddress,
            value: ton("0.3"),
            mode: SendIgnoreErrors,
            code: initState.code,
            data: initState.data,
            body: "deploy".asComment()
        });

        // pay-back remaining gas
        self.reply(CreateMarketResponse{address: preMarketContractAddress}.toCell());
    }
}