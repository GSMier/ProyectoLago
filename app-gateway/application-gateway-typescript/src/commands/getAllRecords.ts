
import { Gateway } from '@hyperledger/fabric-gateway';
import { ScientificDataCollection } from '../contract';
import { chaincodeName, channelName } from '../connect';

export default async function main(gateway: Gateway): Promise<void> {
    const network = gateway.getNetwork(channelName);
    const contract = network.getContract(chaincodeName);

    const smartContract = new ScientificDataCollection(contract);
    const records = await smartContract.getAllRecords();

    const recordsJson = JSON.stringify(records, undefined, 2);
    recordsJson.split('\n').forEach(line => console.log(line)); // Write line-by-line to avoid truncation
}