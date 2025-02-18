// import { Gateway } from "@hyperledger/fabric-gateway";
// import { chaincodeName, channelName } from "../connect";
// const utf8Decoder = new TextDecoder();
// const assetId = `asset${String(Date.now())}`;


// export default async function main(gateway: Gateway): Promise<void> {
//     const network = gateway.getNetwork(channelName);
//     const contract = network.getContract(chaincodeName);

//         console.log('\n--> Async Submit Transaction: TransferAsset, updates existing asset owner');

//     const commit = await contract.submitAsync('TransferAsset', {
//         arguments: [assetId, 'Saptha'],
//     });
//     const oldOwner = utf8Decoder.decode(commit.getResult());

//     console.log(`*** Successfully submitted transaction to transfer ownership from ${oldOwner} to Saptha`);
//     console.log('*** Waiting for transaction commit');

//     const status = await commit.getStatus();
//     if (!status.successful) {
//         throw new Error(`Transaction ${status.transactionId} failed to commit with status code ${String(status.code)}`);
//     }

//     console.log('*** Transaction committed successfully');

// }
