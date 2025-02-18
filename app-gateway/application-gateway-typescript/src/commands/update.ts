import { Gateway } from '@hyperledger/fabric-gateway';
// import { assertAllDefined } from '../utils';
// import { chaincodeName, channelName } from '../connect';
// import { ScientificData, ScientificDataCollection } from '../contract';

export default async function main(gateway: Gateway, args: string[]): Promise<void> {
    // const [assetId, newColor, newSize, newOwner ,newValue] = assertAllDefined([args[0], args[1], args[2], args[3], args[4]], 'Arguments: <assetId> <ownerName> <ownerMspId>');


    // const network = gateway.getNetwork(channelName);
    // const contract = network.getContract(chaincodeName);

    // const asset ={
    //     ID: assetId,
    //     Color: newColor,
    //     Size: newSize,
    //     Owner: newOwner,
    //     AppraisedValue: newValue
    // } as Asset;

    // if(!asset.ID || !asset.Color || !asset.Size || !asset.AppraisedValue || !asset.Owner) return;

    // console.log(`*** Successfully submitted transaction of update ${asset}`);
    

    // const smartContract = new ScientificDataCollection(contract);
    // console.log('*** Waiting for transaction commit');
    // const assetUpdated = await smartContract.updateAsset(asset.ID, asset.Color, asset.Size.toString(),asset.Owner ,asset.AppraisedValue.toString());
    // console.log(`*** Transaction committed successfully of ${assetUpdated}`);

    // const commit = await contract.submitAsync('TransferAsset', {
    //     arguments: [assetId, newOwner],
    // });

    //     const oldOwner = utf8Decoder.decode(commit.getResult());


    // const status = await commit.getStatus();
    // if (!status.successful) {
    //     throw new Error(`Transaction ${status.transactionId} failed to commit with status code ${String(status.code)}`);
    // }

}
