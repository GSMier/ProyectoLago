import { Gateway } from "@hyperledger/fabric-gateway";
import {  channelName } from '../connect';
import crypto from 'crypto';
import { Block, BlockchainInfo } from "@hyperledger/fabric-protos/lib/common";
export default async function main(gateway: Gateway): Promise<void> {
    const network = gateway.getNetwork(channelName);
    const contract = network.getContract("qscc");
    
    const chainInfo = await contract.evaluateTransaction("GetChainInfo", channelName, "");
    const blockHeight = BlockchainInfo.deserializeBinary(chainInfo).getHeight();

    
    for (let i = 0; i < blockHeight  ; i++) {
        const serializedBlock = await contract.evaluateTransaction("GetBlockByNumber", channelName, i.toString());
        const block = Block.deserializeBinary(serializedBlock);
        console.log(`Bloque ${i}`)
        const contentDataU8 = block.getData()?.getDataList_asU8();
        const contentHash = crypto.createHash("sha256").update(new Uint8Array(await new Blob([...contentDataU8!]).arrayBuffer())).digest('hex')

        const dataHash64 = block.getHeader()?.getDataHash_asB64();
        const dataHashString = Buffer.from(dataHash64!, 'base64').toString('hex');
        
        if(contentHash !== dataHashString){
            throw new Error(`There was a tampering in the block ${i} of this peer`);
        }
    }

    
}