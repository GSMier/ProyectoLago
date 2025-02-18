import { Gateway } from "@hyperledger/fabric-gateway";
// import { assertAllDefined } from "../utils";
// import { chaincodeName, channelName } from "../connect";



export default async function main(gateway: Gateway, args: string[]): Promise<void> {
    // const [assetId, owner, color] = assertAllDefined([args[0], args[1], args[2]], 'Arguments: <assetId> <ownerName> <color>');

    // if(!assetId || !owner || !color) return;

    // const network = gateway.getNetwork(channelName);
    // const contract = network.getContract(chaincodeName);

    // await contract.submitTransaction(
    //     'CreateAsset',
    //     assetId,
    //     color,
    //     '5',
    //     owner,
    //     '1300',
    // );
}
