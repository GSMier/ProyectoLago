
import { Gateway } from '@hyperledger/fabric-gateway';
import { assertDefined } from '../utils';
import { chaincodeName, channelName } from '../connect';
import { ScientificDataCollection } from '../contract';

export default async function main(gateway: Gateway, args: string[]): Promise<void> {
    const recordId = assertDefined(args[0], 'Arguments: <recordId>');

    const network = gateway.getNetwork(channelName);
    const contract = network.getContract(chaincodeName);

    const smartContract = new ScientificDataCollection(contract);
    await smartContract.deleteRecord(recordId);

    console.log(`*** Successfully submitted transaction of record delete with  ID: ${recordId}}`);

}