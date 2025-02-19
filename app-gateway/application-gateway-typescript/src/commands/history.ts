
import { Gateway } from '@hyperledger/fabric-gateway';
import { ScientificDataCollection } from '../contract';
import { chaincodeName, channelName } from '../connect';
import { assertDefined } from '../utils';

export default async function main(gateway: Gateway, args: string[]): Promise<void> {
    const recordId = assertDefined(args[0], 'Arguments: <recordId>'); 
    
    const network = gateway.getNetwork(channelName);
    const contract = network.getContract(chaincodeName);

    const smartContract = new ScientificDataCollection(contract);
    const records = await smartContract.getHistoryForRecord(recordId);

    const recordsJson = JSON.stringify(records, undefined, 2);
    recordsJson.split('\n').forEach(line => console.log(line)); // Write line-by-line to avoid truncation
}