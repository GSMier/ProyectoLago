import { Gateway } from "@hyperledger/fabric-gateway";
import {  channelName } from '../connect';
import crypto from 'crypto';
import { Block, BlockchainInfo, BlockData, ChannelHeader, Envelope, Header, Payload, SignatureHeader } from "@hyperledger/fabric-protos/lib/common";
import { msp } from "@hyperledger/fabric-protos";
export default async function main(gateway: Gateway): Promise<void> {
    const network = gateway.getNetwork(channelName);
    const contract = network.getContract("qscc");
    

    const chainInfo = await contract.evaluateTransaction("GetChainInfo", channelName, "");

    const blockHeight = BlockchainInfo.deserializeBinary(chainInfo).getHeight();

    
    for (let i = 0; i < blockHeight  ; i++) {
        const serializedBlock = await contract.evaluateTransaction("GetBlockByNumber", channelName, i.toString());
        const block = Block.deserializeBinary(serializedBlock);
        const contentDataU8 = block.getData()?.getDataList_asU8();
        const contentHash = crypto.createHash("sha256").update(new Uint8Array(await new Blob([...contentDataU8!]).arrayBuffer())).digest('hex')

        const dataHash64 = block.getHeader()?.getDataHash_asB64();
        const dataHashString = Buffer.from(dataHash64!, 'base64').toString('hex');
        if(contentHash !== dataHashString){

            const blockData: BlockData = block.getData()!;
            const blockDataList = blockData.getDataList_asU8();
            if (blockDataList.length > 0) {
              for (const bl of blockDataList) {
                if (bl.length > 0) {
                  const envelope = Envelope.deserializeBinary(bl);
                  const signature = envelope.getSignature_asU8();
                  const envPayload: Payload = Payload.deserializeBinary(envelope.getPayload_asU8());
                  const headerPayload: Header = envPayload.getHeader()!;
                  const channelHeader: ChannelHeader = ChannelHeader.deserializeBinary(headerPayload.getChannelHeader_asU8());
                  const getTxId = channelHeader.getTxId();
                  const headerType = channelHeader.getType();
                  if (headerType === 3) {
                        const creatorBytes = SignatureHeader.deserializeBinary(envPayload.getHeader()?.getSignatureHeader_asU8()!).getCreator_asU8();
                        const creator = msp.SerializedIdentity.deserializeBinary(creatorBytes);
                        
                        const verifier = crypto.createVerify("sha256");
                        verifier.update(Buffer.from(envelope.getPayload_asU8()));
                        verifier.end();
        

                        const isValid = verifier.verify(Buffer.from(creator.getIdBytes() as Uint8Array), Buffer.from(signature));
        
                        if(!isValid) {
                          throw new Error(`There was a tampering in the block ${i} of this peer at the transaction txId: ${getTxId}`);
                        }
                  } else {
                    console.log('There is no transaction data in the block event.');
                  }
                } else {
                  console.log('There is no transaction data in the block event.');
                }
              }
            }
        

            throw new Error(`There was a tampering in the block ${i} of this peer`);
        }
    }

    
}