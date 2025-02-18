// import { Gateway } from '@hyperledger/fabric-gateway';
// import { assertAllDefined } from '../utils';
// import { chaincodeName, channelName } from '../connect';
// const utf8Decoder = new TextDecoder();

// export default async function main(gateway: Gateway, args: string[]): Promise<void> {
//     const [assetId, newOwner, newOwnerOrg] = assertAllDefined([args[0], args[1], args[2]], 'Arguments: <assetId> <ownerName> <ownerMspId>');
//     if(!assetId || !newOwner || !newOwnerOrg ) return;

//     const network = gateway.getNetwork(channelName);
//     const contract = network.getContract(chaincodeName);

//     const commit = await contract.submitAsync('TransferAsset', {
//         arguments: [assetId, newOwner],
//     });

//         const oldOwner = utf8Decoder.decode(commit.getResult());

//     console.log(`*** Successfully submitted transaction to transfer ownership from ${oldOwner} to ${newOwner}`);
//     console.log('*** Waiting for transaction commit');

//     const status = await commit.getStatus();
//     if (!status.successful) {
//         throw new Error(`Transaction ${status.transactionId} failed to commit with status code ${String(status.code)}`);
//     }

//     console.log('*** Transaction committed successfully');
// }
