import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { UserBet } from '../wrappers/UserBet';
import { PredictionMarket } from '../wrappers/PredictionMarket';
import '@ton/test-utils';

describe('UserBet', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let userBet: SandboxContract<UserBet>;
    let predictionMarket: SandboxContract<PredictionMarket>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        deployer = await blockchain.treasury('deployer');
        predictionMarket = blockchain.openContract(await PredictionMarket.fromInit(marketFactory.address, "New Market", BigInt(Date.now() + 60), deployer.address, 2n));
        userBet = blockchain.openContract(await UserBet.fromInit(deployer.address, predictionMarket.address));

        const deployResult = await userBet.send(
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
            to: userBet.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and mainContract are ready to use 
    });
});