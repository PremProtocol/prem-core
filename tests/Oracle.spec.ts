// import { Blockchain, SandboxContract, TreasuryContract } from '@ton/sandbox';
// import { toNano } from '@ton/core';
// import { Oracle } from '../wrappers/Oracle';
// import '@ton/test-utils';

// describe('Oracle', () => {
//     let blockchain: Blockchain;
//     let deployer: SandboxContract<TreasuryContract>;
//     let oracle: SandboxContract<Oracle>;

//     beforeEach(async () => {
//         blockchain = await Blockchain.create();

//         oracle = blockchain.openContract(await Oracle.fromInit());

//         deployer = await blockchain.treasury('deployer');

//         const deployResult = await oracle.send(
//             deployer.getSender(),
//             {
//                 value: toNano('0.05'),
//             },
//             {
//                 $$type: 'Deploy',
//                 queryId: 0n,
//             }
//         );

//         expect(deployResult.transactions).toHaveTransaction({
//             from: deployer.address,
//             to: oracle.address,
//             deploy: true,
//             success: true,
//         });
//     });

//     it('should deploy', async () => {
//         // the check is done inside beforeEach
//         // blockchain and mainContract are ready to use 
//     });

//     it('should set outcome correctly', async () => {
//         const setOutcomeResult = await oracle.send(deployer.getSender(), {}, {
//             $$type: 'SetOutcome',
//             market: predictionMarket.address,
//             outcome: 1n,
//         });

//         expect(setOutcomeResult.transactions).toHaveTransaction({
//             from: deployer.address,
//             to: oracle.address,
//             success: true,
//         });
//     });

//     it('should not set outcome if not owner', async () => {
//         const nonOwner = await blockchain.treasury('nonOwner');

//         const setOutcomeResult = await oracle.send(nonOwner.getSender(), {}, {
//             $$type: 'SetOutcome',
//             market: predictionMarket.address,
//             outcome: 1n,
//         });

//         expect(setOutcomeResult.transactions).toHaveTransaction({
//             from: nonOwner.address,
//             to: oracle.address,
//             success: false,
//         });
//     });
// });