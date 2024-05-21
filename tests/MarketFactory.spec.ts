import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { MarketFactory } from '../wrappers/MarketFactory';
import '@ton/test-utils';

describe('MainContract', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let marketFactory: SandboxContract<MarketFactory>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        marketFactory = blockchain.openContract(await MarketFactory.fromInit());

        deployer = await blockchain.treasury('deployer');

        const deployResult = await marketFactory.send(
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
            to: marketFactory.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and mainContract are ready to use 
    });

    it('should create market', async()=>{
        const createMarketResult = await marketFactory.send(deployer.getSender(), {
            value: toNano('0.2')
        }, {
            $$type: 'CreateMarket',
            eventDescription: "New event",
            endTime: 100n, //now + 1 day
            numOutcomes: 2n,
        })

        expect(createMarketResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: marketFactory.address,
            success: true,
        });
    
        // Check the state of the contract to ensure the market was created
        const counter = await marketFactory.getCounter();
        expect(counter).toEqual(1);
    })

    it('should initialize contract correctly', async () => {
        // TODO: Implement test
    });

    // Test the increment of the counter
    it('should increment the counter', async () => {
        // TODO: Implement test
    });

    // Test the creation of the initial state for a new market
    it('should create initial state for new market', async () => {
        // TODO: Implement test
    });

    // Test the calculation of the future address of the contract
    it('should calculate future address of the contract', async () => {
        // TODO: Implement test
    });

    // Test the handling of invalid end time
    it('should handle invalid end time', async () => {
        // TODO: Implement test
    });

    // Test the handling of invalid number of outcomes
    it('should handle invalid number of outcomes', async () => {
        // TODO: Implement test
    });
});
