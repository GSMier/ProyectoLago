import { Gateway } from "@hyperledger/fabric-gateway";
import {  channelName, envOrDefault } from '../connect';
import crypto from 'crypto';
import { Block, BlockchainInfo, BlockData, ChannelHeader, Envelope, Header, Payload, SignatureHeader } from "@hyperledger/fabric-protos/lib/common";
import { ChaincodeActionPayload, ChaincodeEndorsedAction, ChaincodeProposalPayload, ProposalResponsePayload, Transaction, TransactionAction } from "@hyperledger/fabric-protos/lib/peer";
import path from "path";
import * as fs from 'fs';
import { msp } from "@hyperledger/fabric-protos";
import { Certificate } from "@fidm/x509";
export default async function main(gateway: Gateway): Promise<void> {
    const network = gateway.getNetwork(channelName);
    const contract = network.getContract("qscc");
    

    // const chainInfo = await contract.evaluateTransaction("GetChainInfo", channelName, "");
    // const transactionSerialized = await contract.evaluateTransaction("GetTransactionByID", channelName, "40ce1966633557d6a1a42579295578e2ce9e8929c41b7ff6306217e6b01e6597")
    // const transaction=  Transaction.deserializeBinary(transactionSerialized);
    // const transactionActions: TransactionAction[] = transaction.getActionsList();  

    const certDirectoryPath = envOrDefault('CERT_DIRECTORY_PATH', 'signcerts');
    const keyDirectoryPath = envOrDefault('KEY_DIRECTORY_PATH', 'signcerts');
    async function getFirstDirFileName(dirPath: string): Promise<string> {
        const files = await fs.promises.readdir(dirPath);
        const file = files[0];
        if (!file) {
            throw new Error(`No files in directory: ${dirPath}`);
        }
        return path.join(dirPath, file);
    }

    const certPath = await getFirstDirFileName(certDirectoryPath)
    const privatePath = await getFirstDirFileName(keyDirectoryPath)
    const publicKey = fs.readFileSync(certPath) ;
    const privateKey = fs.readFileSync(privatePath);



    // Verify the signature




    const serializedBlock = await contract.evaluateTransaction("GetBlockByNumber", channelName, "4");
    const block = Block.deserializeBinary(serializedBlock);
    const blockData: BlockData = block.getData()!;
  
    const blockDataList = blockData.getDataList_asU8();
    console.log(`### Envelope quantity (number of transactions): ${blockDataList.length} ###`);
    if (blockDataList.length > 0) {
      for (const bl of blockDataList) {
        if (bl.length > 0) {
          const envelope = Envelope.deserializeBinary(bl);
          const signature = envelope.getSignature_asU8();
          const envPayload: Payload = Payload.deserializeBinary(envelope.getPayload_asU8());
          const headerPayload: Header = envPayload.getHeader()!;
          const channelHeader: ChannelHeader = ChannelHeader.deserializeBinary(headerPayload.getChannelHeader_asU8());
          const channelId: string = channelHeader.getChannelId();
          const getTxId = channelHeader.getTxId();
          const headerType = channelHeader.getType();
          console.log(`Envelope channelId: ${channelId} - txId: ${getTxId} - headerType: ${headerType} `);
          if (headerType === 3) {
            const transaction: Transaction = Transaction.deserializeBinary(envPayload.getData_asU8());
            const transactionActions: TransactionAction[] = transaction.getActionsList();
            for (const transactionAction of transactionActions) {
                
        
                const chaincodeActionPayload = ChaincodeActionPayload.deserializeBinary(transactionAction.getPayload_asU8());
                const chaincodeProposalPayload = ChaincodeProposalPayload.deserializeBinary(chaincodeActionPayload.getChaincodeProposalPayload_asU8())
                const chaincodeEndorseAction = chaincodeActionPayload.getAction()!;
                const proposalResponsePayload: ProposalResponsePayload = ProposalResponsePayload.deserializeBinary(chaincodeEndorseAction.getProposalResponsePayload_asU8());
                const proposalResponseHash = Buffer.from(proposalResponsePayload.getProposalHash_asB64(), 'base64').toString('hex');

                const creatorBytes = SignatureHeader.deserializeBinary(envPayload.getHeader()?.getSignatureHeader_asU8()!).getCreator_asU8();
                const creator = msp.SerializedIdentity.deserializeBinary(creatorBytes);
                
                const proposalBytes = envelope.getPayload_asU8()
                const computedProposalHash = crypto.createHash("sha256").update(proposalBytes).digest("hex");
                console.log("Computed Proposal Hash:", computedProposalHash, proposalResponseHash, computedProposalHash === proposalResponseHash );
                const verifier = crypto.createVerify("sha256");
                verifier.update(Buffer.from(envelope.getPayload_asU8()));
                verifier.end();

                const isValid = verifier.verify(Buffer.from(creator.getIdBytes()), Buffer.from(signature));

                console.log( isValid);
       
        
        
            }
          }
        //   const decodedBlockDataEnvelope = decodeBlockDataEnvelope(envelope);
        //   decodedBlock.decodedBlockDataEnvelopes.push(decodedBlockDataEnvelope);
        } else {
          console.log('There is no transaction data in the block event.');
        }
      }
    }




    // transaction.getActionsList()
    // const blockHeight = BlockchainInfo.deserializeBinary(chainInfo).getHeight();

    
    // for (let i = 0; i < blockHeight  ; i++) {
    //     const serializedBlock = await contract.evaluateTransaction("GetBlockByNumber", channelName, i.toString());
    //     const block = Block.deserializeBinary(serializedBlock);
    //     const contentDataU8 = block.getData()?.getDataList_asU8();
    //     const contentHash = crypto.createHash("sha256").update(new Uint8Array(await new Blob([...contentDataU8!]).arrayBuffer())).digest('hex')

    //     const dataHash64 = block.getHeader()?.getDataHash_asB64();
    //     const dataHashString = Buffer.from(dataHash64!, 'base64').toString('hex');
        
    //     if(contentHash !== dataHashString){
    //         throw new Error(`There was a tampering in the block ${i} of this peer`);
    //     }
    // }

    
}