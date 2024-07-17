import "@stdlib/deploy";
import "@stdlib/ownable";
import "./prediction_market.tact";
import "./messages.tact";

contract MarketFactory with Deployable, OwnableTransferable {
    const MinTonForStorage: Int = ton("0.02");
    owner: Address;
    predictionMarketCount: Int as uint64;

    init() {
        self.owner = sender();
        self.predictionMarketCount = 0;
    }

    receive(msg: CreateMarket) {
        require(msg.eventName != "", "Event name has must be provided");
        require(msg.eventDescription != "", "Event description has must be provided");
        require(msg.endTime > now(), "End time must be in the future");
        require(msg.outcomeName1 != "", "Outcome names must be provided");
        require(msg.outcomeName2 != "", "Outcome names must be provided");
        require(msg.eventType != "", "Event type has must be provided");
        self.requireOwner();

        let initState: StateInit = initOf PredictionMarket(myAddress(), self.predictionMarketCount);
        let preMarketContractAddress: Address = contractAddress(initState);
        self.predictionMarketCount += 1;

        let messageValue: Int = context().value - ton("0.02"); // 0.02 TON is the minimum amount required for storage
        if(myBalance() < self.MinTonForStorage) {
            messageValue = messageValue - self.MinTonForStorage;
        }

        send(SendParameters{
            to: preMarketContractAddress,
            value: messageValue,
            mode: SendIgnoreErrors,
            code: initState.code,
            data: initState.data,
            body: MarketInitialize{owner: sender(),
                        eventName: msg.eventName,
                        eventDescription: msg.eventDescription, 
                        eventType: msg.eventType,
                        endTime: msg.endTime, 
                        outcomeName1: msg.outcomeName1, 
                        outcomeName2: msg.outcomeName2}.toCell()
        });
    }

    get fun childAddress(seqno: Int): Address {
        let initState: StateInit = initOf PredictionMarket(myAddress(), seqno);
        let preMarketContractAddress: Address = contractAddress(initState);
        return preMarketContractAddress;
    }

    get fun predictionMarketCount(): Int {
        return self.predictionMarketCount;
    }
}