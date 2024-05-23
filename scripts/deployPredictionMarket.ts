import { toNano } from '@ton/core';
import { MarketFactory } from '../wrappers/MarketFactory';
import { NetworkProvider } from '@ton/blueprint';
import { PredictionMarket } from '../wrappers/PredictionMarket';

export async function run(provider: NetworkProvider) {
    const time = BigInt(1747989580);
    const predictionMarket = provider.open(await PredictionMarket.fromInit(provider.sender().address!!, provider.sender().address!!, "New event", time, "outcomeName1", "outcomeName2", 2n));

    await predictionMarket.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(predictionMarket.address);

    // run methods on `marketFactory`
}
