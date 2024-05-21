import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
import { toNano } from '@ton/core';
import { MainContract } from '../wrappers/MarketFactory';
import '@ton/test-utils';

describe('MainContract', () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let mainContract: SandboxContract<MainContract>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();

        mainContract = blockchain.openContract(await MainContract.fromInit());

        deployer = await blockchain.treasury('deployer');

        const deployResult = await mainContract.send(
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
            to: mainContract.address,
            deploy: true,
            success: true,
        });
    });

    it('should deploy', async () => {
        // the check is done inside beforeEach
        // blockchain and mainContract are ready to use
    });
});
