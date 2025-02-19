


import { Gateway } from '@hyperledger/fabric-gateway';
import { ScientificDataCollection } from '../contract';
import { assertDefined } from '../utils';
import { chaincodeName, channelName } from '../connect';

export default async function main(gateway: Gateway, args: string[]): Promise<void> {
    const recordId = assertDefined(args[0], 'Arguments: <recordId>'); 

    const network = gateway.getNetwork(channelName);
    const contract = network.getContract(chaincodeName);

    const smartContract = new ScientificDataCollection(contract);
    const asset = await smartContract.readRecord(recordId);

    const assetsJson = JSON.stringify(asset, undefined, 2);
    console.log(assetsJson);
}
