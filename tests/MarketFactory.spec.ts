import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { MarketFactory } from '../wrappers/MarketFactory';
import '@ton/test-utils';

describe('MarketFactory', () => {
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

    it('should initialize contract correctly', async () => {
        // Check the state of the contract to ensure the market was created
        const counter = await marketFactory.getCounter();
        expect(counter).toEqual(0n);
    });
    it('should create market and increment the counter', async()=>{
        const createMarketResult = await marketFactory.send(deployer.getSender(), {
            value: toNano('0.2')
        }, {
            $$type: 'CreateMarket',
            eventDescription: "New event",
            endTime: BigInt(Date.now() + 60),
            numOutcomes: 2n,
        })

        expect(createMarketResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: marketFactory.address,
            success: true,
        });
    
        // Check the state of the contract to ensure the market was created
        const counter = await marketFactory.getCounter();
        expect(counter).toEqual(1n);
    })

    // it('should create initial state for new market', async () => {
    //     const createMarketResult = await marketFactory.send(deployer.getSender(), {
    //         value: toNano('0.2')
    //     }, {
    //         $$type: 'CreateMarket',
    //         eventDescription: "New event",
    //         endTime: BigInt(Date.now() + 60),
    //         numOutcomes: 2n,
    //     })

    //     // Check the state of the contract to ensure the market was created
    // });

    it('should handle invalid end time', async () => {
        const createMarketResult = await marketFactory.send(deployer.getSender(), {
            value: toNano('0.2')
        }, {
            $$type: 'CreateMarket',
            eventDescription: "New event",
            endTime: 0n,
            numOutcomes: 2n,
        })

        expect(createMarketResult.transactions).toHaveTransaction({
            from: deployer.address,  
            to: marketFactory.address,
            success: false
        });
    });

    // Test the handling of invalid number of outcomes
    it('should handle invalid number of outcomes', async () => {
        const createMarketResult = await marketFactory.send(deployer.getSender(), {
            value: toNano('0.2')
        }, {
            $$type: 'CreateMarket',
            eventDescription: "New event",
            endTime: BigInt(Date.now() - 60),
            numOutcomes: 1n,
        })

        expect(createMarketResult.transactions).toHaveTransaction({
            from: deployer.address,  
            to: marketFactory.address,
            success: false
        });
    });

    // Testing transaction fees
    it('should storage fees cost less than 1 TON', async () => {
        const time1 = Math.floor(Date.now() / 1000);                               // current local unix time
        const time2 = time1 + 365 * 24 * 60 * 60;                                  // offset for a year
    
        blockchain.now = time1;                                                    // set current time
        await marketFactory.send(deployer.getSender(), {
            value: toNano('0.2')
        }, {
            $$type: 'CreateMarket',
            eventDescription: "New event",
            endTime: BigInt(Date.now() + 60), //add now time
            numOutcomes: 2n,
        });   // preview of fees 
    
        blockchain.now = time2;                                                    // set current time
        const res2 = await marketFactory.send(deployer.getSender(), {
            value: toNano('0.2')
        }, {
            $$type: 'CreateMarket',
            eventDescription: "New event 2",
            endTime: BigInt(Date.now() + 60), //add now time
            numOutcomes: 2n,
        });   // preview of fees 
    
        const tx2 = res2.transactions[1];                                          // extract the transaction that executed in a year
        if (tx2.description.type !== 'generic') {
            throw new Error('Generic transaction expected');
        }
    
        // Check that the storagePhase fees are less than 1 TON over the course of a year
        expect(tx2.description.storagePhase?.storageFeesCollected).toBeLessThanOrEqual(toNano('1'));   
    });
});
