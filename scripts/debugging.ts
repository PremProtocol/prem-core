import { ContractSystem } from '@tact-lang/emulator';
import { MarketFactory } from '../wrappers/MarketFactory';
import { PredictionMarket } from '../wrappers/PredictionMarket';
import { toNano } from '@ton/core';
 
//
// Init System
//
export async function run() {
    // Contract System is a virtual environment that emulates the TON blockchain
  const system = await ContractSystem.create();
  
  // Treasure is a contract that has 1m of TONs and is a handy entry point for your smart contracts
  let treasure = await system.treasure('name of treasure');
  
  //
  // Open contract
  //
  
  // Contract itself
  let contract = system.open(await MarketFactory.fromInit());
  const time = BigInt(1747989580);
  const predictionMarket = system.open(await PredictionMarket.fromInit(treasure.address, treasure.address, "New event", time, "outcomeName1", "outcomeName2", 2n));



  // This object would track all transactions in this contract
  let tracker = system.track(contract.address);
  
  // This object would track all logs
  let logger = system.log(contract.address);
  
  //
  // Sending a message
  //
  
  // First we enqueue messages. NOTE: You can enqueue multiple messages in a row
  await contract.send(treasure, { value: toNano(1) }, { $$type: "Deploy", queryId: 0n });
  await predictionMarket.send(
    treasure,
      {
          value: toNano(1),
      },
      {
          $$type: 'Deploy',
          queryId: 0n,
      }
  );
  await contract.send(treasure, { value: toNano(2) }, { $$type: 'CreateMarket', eventDescription: "New event", endTime: time, outcomeName1: "outcomeName1", outcomeName2: "outcomeName2", numOutcomes: 2n });
  
  console.log(contract.address);
  console.log(predictionMarket.address);
  // Run the system until there are no more messages
  await system.run();
  
  //
  // Collecting results
  //
  
  console.log(tracker.collect()); // Prints out all transactions in contract
  //console.log(logger.collect()); // Prints out all logs for each transaction
  
  //
  // Invoking get methods
  //
  
  let getChildAddress = await contract.getChildAddress(treasure.address, "New event", time, "outcomeName1", "outcomeName2", 2n);
  console.log(getChildAddress); // Prints out counter value

  let getChildAddressTemp = await contract.getChildAddressTemp();
  console.log(getChildAddressTemp); // Prints out counter value

}