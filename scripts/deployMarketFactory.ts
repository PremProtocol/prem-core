import { toNano } from '@ton/core';
import { MarketFactory } from '../wrappers/MarketFactory';
import { NetworkProvider } from '@ton/blueprint';

export async function run(provider: NetworkProvider) {
    const marketFactory = provider.open(await MarketFactory.fromInit());

    await marketFactory.send(
        provider.sender(),
        {
            value: toNano('0.05'),
        },
        {
            $$type: 'Deploy',
            queryId: 0n,
        }
    );

    await provider.waitForDeploy(marketFactory.address);

    // run methods on `marketFactory`
}
