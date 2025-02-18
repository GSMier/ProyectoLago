
import { Gateway } from '@hyperledger/fabric-gateway';
// import { AssetTransfer } from '../contract';
// import { chaincodeName, channelName } from '../connect';

export default async function main(gateway: Gateway): Promise<void> {
    // const network = gateway.getNetwork(channelName);
    // const contract = network.getContract(chaincodeName);

    // const smartContract = new AssetTransfer(contract);
    // const assets = await smartContract.getAllAssets();

    // const assetsJson = JSON.stringify(assets, undefined, 2);
    // assetsJson.split('\n').forEach(line => console.log(line)); // Write line-by-line to avoid truncation
}