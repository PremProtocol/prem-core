import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { PredictionMarket } from '../wrappers/PredictionMarket';
import { MarketFactory } from '../wrappers/MarketFactory';
import '@ton/test-utils';

describe('PredictionMarket', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let marketFactory: SandboxContract<MarketFactory>;
    let predictionMarket: SandboxContract<PredictionMarket>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();
        deployer = await blockchain.treasury('deployer');
        marketFactory = blockchain.openContract(await MarketFactory.fromInit());
        predictionMarket = blockchain.openContract(await PredictionMarket.fromInit(deployer.address,
            marketFactory.address,
            "New Market", 
            BigInt(Date.now()), 
            "outcomeName 1",
            "outcomeName 2",
            2n));

        const deployResult = await predictionMarket.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            }
        );

        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: predictionMarket.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and mainContract are ready to use 
    });

    //broken because of the error: changing time
    it('should resolve market correctly', async () => {
      blockchain.now = Math.floor(Date.now() / 1000) + 2 * 24 * 60 * 60;

      const resolveMarketResult = await predictionMarket.send(deployer.getSender(), {
        value: toNano('0.2')
      }, {
          $$type: 'ResolveMarket',
          outcome: 1n,
      });

      expect(resolveMarketResult.transactions).toHaveTransaction({
          from: deployer.address,
          to: predictionMarket.address,
          success: true,
      });

    const resolvedOutcome = await predictionMarket.getResolvedOutcome();
    expect(resolvedOutcome).toEqual(1n);
    });

    it('should not resolve market before event end', async () => {
        // Set the blockchain time to before the event end time
        blockchain.now = Math.floor(Date.now() / 1000);

        const resolveMarketResult = await predictionMarket.send(deployer.getSender(), {
          value: toNano('0.2')
        }, {
            $$type: 'ResolveMarket',
            outcome: 1n,
        });

        expect(resolveMarketResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: predictionMarket.address,
            success: false,
        });
    });

    it('should not resolve market twice', async () => {
        // Resolve the market once
        await predictionMarket.send(deployer.getSender(), {
          value: toNano('0.2')
        }, {
            $$type: 'ResolveMarket',
            outcome: 1n,
        });

        // Attempt to resolve the market again
        const resolveMarketResult = await predictionMarket.send(deployer.getSender(), {
          value: toNano('0.2')
        }, {
            $$type: 'ResolveMarket',
            outcome: 2n,
        });

        expect(resolveMarketResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: predictionMarket.address,
            success: false,
        });
    });

    it('should not resolve market with invalid outcome', async () => {
        const resolveMarketResult = await predictionMarket.send(deployer.getSender(), {
          value: toNano('0.2')
        }, {
            $$type: 'ResolveMarket',
            outcome: 3n,
        });

        expect(resolveMarketResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: predictionMarket.address,
            success: false,
        });
    });

    it('should get total pool correctly', async () => {
        const totalPool = await predictionMarket.getTotalPool();
        expect(totalPool).toEqual(0n);
    });

    // TODO: try to solve TypeError: Do not know how to serialize a BigInt at stringify (<anonymous>)
    // it('should get total bet for outcome correctly', async () => {
    //     const totalBetForOutcome = await predictionMarket.getTotalBetForOutcome(1n);
    //     expect(totalBetForOutcome).toEqual(null);
    // });

    //it('should not get total bet for invalid outcome', async () => {
    //    const totalBetForOutcome = await predictionMarket.getTotalBetForOutcome(3n);
    //    expect(totalBetForOutcome).toEqual(null);
    //});
});