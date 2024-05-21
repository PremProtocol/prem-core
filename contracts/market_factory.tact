import "@stdlib/deploy";
import "./prediction_market.tact";

message CreateMarketResponse {
    address: Address;
}

message CreateMarket {
    eventDescription: String;
    endTime: Int as uint64;
    numOutcomes: Int as uint8;
}

contract MarketFactory with Deployable {
    counter: Int as uint64;

    init() {
        self.counter = 0;
    }

    receive(msg: CreateMarket) {
        require(msg.endTime > now(), "End time must be in the future");
        require(msg.numOutcomes > 1, "Number of outcomes must be greater than 1");

        // Increment the counter to ensure unique deployment
        self.counter += 1;

        // Define the initial state for the new market

        let initState: StateInit = initOf PredictionMarket(myAddress(), msg.eventDescription, msg.endTime, sender(), msg.numOutcomes);

        let preMarketContractAddress: Address = contractAddress(initState);

        // Deploy the new market contract with an initial balance of 1 ton
        send(SendParameters{
            to: preMarketContractAddress,
            value: ton("0.2"),               // pay for the message, the deployment, and give some TON for storage
            mode: SendIgnoreErrors,
            code: initState.code,          // attaching the state init will cause the message to deploy
            data: initState.data,
            body: "initialize".asComment() // we must piggyback the deployment on another message
        });

        // pay-back remaining gas
        self.reply(CreateMarketResponse{address: preMarketContractAddress}.toCell());
    }

    get fun counter(): Int {
        return self.counter;
    }
}