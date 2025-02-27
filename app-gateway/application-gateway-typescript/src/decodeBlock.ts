import { Block, BlockData, BlockHeader, BlockMetadata, ChannelHeader, Envelope, Header, Payload, SignatureHeader, Metadata } from '@hyperledger/fabric-protos/lib/common';
import {
  ChaincodeAction,
  ChaincodeActionPayload,
  ChaincodeID,
  ChaincodeInvocationSpec,
  ChaincodeProposalPayload,
  Endorsement,
  ProcessedTransaction,
  ProposalResponsePayload,
  Transaction,
  TransactionAction,
} from '@hyperledger/fabric-protos/lib/peer';
import { SerializedIdentity } from '@hyperledger/fabric-protos/lib/msp';
import { X509 } from 'jsrsasign';
import { ChaincodeEndorsedAction } from '@hyperledger/fabric-protos/lib/peer/transaction_pb';
import { ChaincodeSpec } from '@hyperledger/fabric-protos/lib/peer/chaincode_pb';
import { TxReadWriteSet } from '@hyperledger/fabric-protos/lib/ledger/rwset';
import { NsReadWriteSet } from '@hyperledger/fabric-protos/lib/ledger/rwset/rwset_pb';
import { KVRWSet } from '@hyperledger/fabric-protos/lib/ledger/rwset/kvrwset';
import { KVMetadataEntry, KVMetadataWrite, KVRead, KVWrite, RangeQueryInfo } from '@hyperledger/fabric-protos/lib/ledger/rwset/kvrwset/kv_rwset_pb';
// import { console } from '@nestjs/common';
import { MetadataSignature } from '@hyperledger/fabric-protos/lib/common/common_pb';

/**
 * Decode de processed transaction protobuff
 * @param data
 */
export const decodeProcessedTransaction = (data: Buffer): { validationCode: number; decodedTransactionEnvelope: any } => {
//   const console = new console(decodeProcessedTransaction.name);
  const decodedProcessedTransaction = { validationCode: {} as number, decodedTransactionEnvelope: {} };
  const processedTransaction: ProcessedTransaction = ProcessedTransaction.deserializeBinary(data);
  const validationCode = processedTransaction.getValidationcode();
  decodedProcessedTransaction.validationCode = validationCode;
  console.log(`==> Transaction validation code: ${validationCode}`);
  const transactionEnvelope: Envelope = processedTransaction.getTransactionenvelope()!;
  decodedProcessedTransaction.decodedTransactionEnvelope = decodeBlockDataEnvelope(transactionEnvelope);
  return decodedProcessedTransaction;
};

/**
 * Decode the block data envelope or the Processed Transaction Envelope.
 * @param envelope
 */
export const decodeBlockDataEnvelope = (envelope: Envelope): any => {
//   const console = new console(decodeBlockDataEnvelope.name);
  const decodedBlockDataEnvelope = {
    channelId: {},
    transactionId: {},
    headerType: {},
    payloadHeaderSignature: {},
    creatorMsp: {},
    creatorId: {},
    creatorIdX509Info: {},
    creatorIdX509Subject: {},
    endorsements: {},
    chaincodeSpecs: {},
    proposalResponseHash: {},
    txReadWriteSet: [],
  };
  const envPayload: Payload = Payload.deserializeBinary(envelope.getPayload_asU8());
  const headerPayload: Header = envPayload.getHeader()!;
  decodedBlockDataEnvelope.payloadHeaderSignature = headerPayload.getSignatureHeader_asB64();
  const channelHeader: ChannelHeader = ChannelHeader.deserializeBinary(headerPayload.getChannelHeader_asU8());
  const channelId: string = channelHeader.getChannelId();
  decodedBlockDataEnvelope.channelId = channelId;
  const getTxId = channelHeader.getTxId();
  decodedBlockDataEnvelope.transactionId = channelHeader.getTxId();
  const headerType = channelHeader.getType();
  decodedBlockDataEnvelope.headerType = headerType;
  console.log(`Envelope channelId: ${channelId} - txId: ${getTxId} - headerType: ${headerType} `);
  if (headerType === 3) {
    const transaction: Transaction = Transaction.deserializeBinary(envPayload.getData_asU8());
    const transactionActions: TransactionAction[] = transaction.getActionsList();
    for (const transactionAction of transactionActions) {
      console.log('======***** PROPOSAL CREATOR INFO ****======');
      const signatureActionHeader = SignatureHeader.deserializeBinary(transactionAction.getHeader_asU8());
      const creator = SerializedIdentity.deserializeBinary(signatureActionHeader.getCreator_asU8());
      const msp = creator.getMspid();
      decodedBlockDataEnvelope.creatorMsp = msp;
      console.log(`Creator MSP: ${msp} `);
      const creatorId = Buffer.from(creator.getIdBytes_asB64(), 'base64');
      decodedBlockDataEnvelope.creatorId = creatorId.toString();
      const certX509 = new X509();
      certX509.readCertPEM(creatorId.toString());
      console.log(`==> Creator.getInfo(): \n ${certX509.getInfo()}`);
      decodedBlockDataEnvelope.creatorIdX509Info = certX509.getInfo();
      console.log(`==> Creator.getSubject(): ${JSON.stringify(certX509.getSubject())}`);
      decodedBlockDataEnvelope.creatorIdX509Subject = certX509.getSubject();
      console.log(`Creator Id Bytes: \n${creatorId.toString()}\n `);
      console.log('======***** CHAINCODE ACTION PAYLOAD ****======');
      const chaincodeActionPayload = ChaincodeActionPayload.deserializeBinary(transactionAction.getPayload_asU8());
      const chaincodeEndorseAction: ChaincodeEndorsedAction = chaincodeActionPayload.getAction()!;
      if (chaincodeEndorseAction) {
        console.log('======***** ENDORSEMENTS PAYLOAD ****======');
        const endorsements: Array<Endorsement> = chaincodeEndorseAction.getEndorsementsList();
        const endorsementList = [];
        for (const endorsement of endorsements) {
          const endorsementInfo = { endorserId: {}, endorserIdX509Info: {}, endorserIdX509Subject: {}, endorserMsp: {}, endorserSignature: {} };
          console.log(`======***** ENDORSEMENTS PAYLOAD ****======`);
          const endorserIdentity = SerializedIdentity.deserializeBinary(endorsement.getEndorser_asU8());
          endorsementInfo.endorserSignature = endorsement.getSignature_asB64();
          const endorserId = Buffer.from(endorserIdentity.getIdBytes_asB64(), 'base64');
          endorsementInfo.endorserId = endorserId.toString();
          certX509.readCertPEM(endorserId.toString());
          console.log(`==> Endorser.getInfo(): \n ${certX509.getInfo()}`);
          endorsementInfo.endorserIdX509Info = certX509.getInfo();
          console.log(`==> Endorser.getSubject(): ${JSON.stringify(certX509.getSubject())}`);
          endorsementInfo.endorserIdX509Subject = certX509.getSubject();
          console.log(`==> endorserIdentity.getMspid(): ${endorserIdentity.getMspid()}`);
          endorsementInfo.endorserMsp = endorserIdentity.getMspid();

          endorsementList.push(endorsementInfo);
        }
        decodedBlockDataEnvelope.endorsements = endorsementList;
      }
      const chaincodeProposalPayload = ChaincodeProposalPayload.deserializeBinary(chaincodeActionPayload.getChaincodeProposalPayload_asU8());
      const chaincodeInocationSpec = ChaincodeInvocationSpec.deserializeBinary(chaincodeProposalPayload.getInput_asU8());
      const chaincodeSpec: ChaincodeSpec = chaincodeInocationSpec.getChaincodeSpec()!;
      const chaincodeId: ChaincodeID = chaincodeSpec.getChaincodeId()!;
      console.log(`======***** CHAINCODE ID INFO ****======`);
      const chaincodeSpecs = { chaincodeID: {}, chaincodeArguments: [] };
      const chaincodeID = { name: {}, path: {}, version: {} };
      console.log(`chaincodeId.getName(): ${chaincodeId.getName()}`);
      chaincodeID.name = chaincodeId.getName();
      console.log(`chaincodeId.getPath(): ${chaincodeId.getPath()}`);
      chaincodeID.path = chaincodeId.getPath();
      console.log(`chaincodeId.getVersion(): ${chaincodeId.getVersion()}`);
      chaincodeID.version = chaincodeId.getVersion();
      chaincodeSpecs.chaincodeID = chaincodeID;
      const chaincodeInput = chaincodeSpec.getInput();
      const chaincodeArgs: Array<string> = chaincodeInput!.getArgsList_asB64();
      console.log(`======***** CHAINCODE INPUTS ****======`);
      if (chaincodeArgs) {
        let i = 0;
        for (const arg of chaincodeArgs) {
          const argBuffer = Buffer.from(arg, 'base64');
          console.log(`Arg[${i++}]: ${argBuffer.toString('utf8')}`);
          try {
            chaincodeSpecs.chaincodeArguments.push(JSON.parse(argBuffer.toString('utf8')) as never);
          } catch (e) {
            chaincodeSpecs.chaincodeArguments.push(argBuffer.toString('utf8') as never );
          }
        }
        decodedBlockDataEnvelope.chaincodeSpecs = chaincodeSpecs;
      }
      console.log(`======***** CHAINCODE RESPONSE PAYLOAD ARGS ****======`);
      const proposalResponsePayload: ProposalResponsePayload = ProposalResponsePayload.deserializeBinary(chaincodeEndorseAction.getProposalResponsePayload_asU8());
      const proposalResponseHash = Buffer.from(proposalResponsePayload.getProposalHash_asB64(), 'base64').toString('hex');
      console.log(`proposalResponseHash: ${proposalResponseHash}`);
      decodedBlockDataEnvelope.proposalResponseHash = proposalResponseHash;
      console.log(`======***** CHAINCODE RWSET ****======`);
      const extension = proposalResponsePayload.getExtension_asU8();
      const chaincodeAction = ChaincodeAction.deserializeBinary(extension);
      const results = chaincodeAction.getResults_asU8();
      const txReadWriteSet: TxReadWriteSet = TxReadWriteSet.deserializeBinary(results);
      const nsReadWriteSet: Array<NsReadWriteSet> = txReadWriteSet.getNsRwsetList();

      for (const rwSet of nsReadWriteSet) {
        const nsRWSet = { namespace: {}, kvReads: [], kvWrites: [], kvMetadataWrites: [], rangeQueryInfos: [] };
        const namespace = rwSet.getNamespace();
        nsRWSet.namespace = namespace;
        console.log(`=====*** namespace: ${namespace} ***=====`);
        const kVRWSetProto = KVRWSet.deserializeBinary(rwSet.getRwset_asU8());
        console.log('------ kVRWSetProto.getReadsList() -----');
        const reads: Array<KVRead> = kVRWSetProto.getReadsList();
        for (const readSet of reads) {
          const kvRead = { key: {}, version: {} };
          console.log(`readSet.getKey(): ${readSet.getKey()}`);
          kvRead.key = readSet.getKey();
          console.log(`readSet.getVersion(): ${readSet.getVersion()}`);
          kvRead.version = readSet.getVersion()!;
          nsRWSet.kvReads.push(kvRead as never);
        }
        console.log('------ kVRWSetProto.getRangeQueriesInfoList() -----');
        const rangeQueryInfoProto: Array<RangeQueryInfo> = kVRWSetProto.getRangeQueriesInfoList();
        for (const rangeQ of rangeQueryInfoProto) {
          const rangeQueryInfo = { startKey: {}, endKey: {} };
          console.log(`rangeQ.getStartKey(): ${rangeQ.getStartKey()}`);
          rangeQueryInfo.startKey = rangeQ.getStartKey();
          console.log(`rangeQ.getEndtKey(): ${rangeQ.getEndKey()}`);
          rangeQueryInfo.endKey = rangeQ.getEndKey();
          nsRWSet.rangeQueryInfos.push(rangeQueryInfo as never);
        }
        console.log('------ kVRWSetProto.getWritesList() -----');
        const writes: Array<KVWrite> = kVRWSetProto.getWritesList();
        for (const write of writes) {
          const kvWrite = { key: {}, value: {} };
          console.log(`write.getKey(): ${write.getKey()}`);
          kvWrite.key = write.getKey();
          const value = Buffer.from(write.getValue_asB64(), 'base64').toString();
          console.log(`write.getValue(): ${value}`);
          try {
            kvWrite.value = JSON.parse(value);
          } catch (e) {
            kvWrite.value = value;
          }
          nsRWSet.kvWrites.push(kvWrite as never);
        }
        console.log('------ kVRWSetProto.getMetadataWritesList() -----');
        const metadataWriltes: Array<KVMetadataWrite> = kVRWSetProto.getMetadataWritesList();
        for (const metadataWrite of metadataWriltes) {
          const kvMetadataWrite = { key: {}, entries: [] };
          console.log(`metadataWrite.getKey(): ${metadataWrite.getKey()}`);
          kvMetadataWrite.key = metadataWrite.getKey();
          const metadataEntryList: Array<KVMetadataEntry> = metadataWrite.getEntriesList();
          for (const entry of metadataEntryList) {
            const ent = { name: {}, value: {} };
            const value = Buffer.from(entry.getValue_asB64(), 'base64').toString();
            console.log(`entry.getValue_asB64(): ${value}`);
            try {
              ent.value = JSON.parse(value);
            } catch (e) {
              ent.value = value;
            }
            console.log(`entry.getName(): ${entry.getName()}`);
            ent.name = entry.getName();
            kvMetadataWrite.entries.push(ent as never);
          }
          nsRWSet.kvMetadataWrites.push(kvMetadataWrite as never);
        }
        decodedBlockDataEnvelope.txReadWriteSet.push(nsRWSet as never);
      }
    }
  }
  return decodedBlockDataEnvelope;
};

/**
 * Decode the block
 * @param data
 */
export const decodeBlock = (
  block: Block,
): {
  dataHashAsB64: string;
  dataHashAsString: string;
  dataHash: string;
  previousDataHashAsB64: string;
  decodedBlockDataEnvelopes: any[];
  previousDataHash: string;
  blockNum: number;
  previousDataHashAsString: string;
} => {
//   const console = new console(decodeBlock.name);
  const decodedBlock = {
    blockNum: {} as number,
    dataHash: {} as string,
    dataHashAsB64: {} as string,
    dataHashAsString: {} as string,
    previousDataHash: {} as string,
    previousDataHashAsB64: {} as string,
    previousDataHashAsString: {} as string,
    decodedBlockDataEnvelopes: [],
    decodedBlockMetadata: [],
  };
  console.log('### Decoding Hyperledger Fabric Block ###');
  const blockHeader: BlockHeader = block.getHeader()!;
  const blockNum = blockHeader.getNumber();
  console.log(`### Block number: ${blockNum} ###`);
  decodedBlock.blockNum = blockNum;
  const dataHash = blockHeader.getDataHash().toString();
  console.log(`### Block data hash: ${dataHash} ###`);
  decodedBlock.dataHash = dataHash;
  const dataHashAsB64 = blockHeader.getDataHash_asB64();
  console.log(`### Block data hash B64: ${dataHashAsB64} ###`);
  decodedBlock.dataHashAsB64 = dataHashAsB64;
  const dataHashAsString = Buffer.from(dataHashAsB64, 'base64').toString('hex');
  console.log(`### Block data hash STRING HEX: ${dataHashAsString} ###`);
  decodedBlock.dataHashAsString = dataHashAsString;
  const previousDataHash = blockHeader.getPreviousHash().toString();
  console.log(`### Block previous data hash: ${previousDataHash} ###`);
  decodedBlock.previousDataHash = previousDataHash;
  const previousDataHashAsB64 = blockHeader.getPreviousHash_asB64();
  console.log(`### Block previous data hash B64: ${previousDataHashAsB64} ###`);
  decodedBlock.previousDataHashAsB64 = previousDataHashAsB64;
  const previousDataHashAsString = Buffer.from(previousDataHashAsB64, 'base64').toString('hex');
  console.log(`### Block previous data hash string HEX: ${previousDataHashAsString} ###`);
  decodedBlock.previousDataHashAsString = previousDataHashAsString;
  const blockData: BlockData = block.getData()!;
  const blockDataList = blockData.getDataList_asU8();
  console.log(`### Envelope quantity (number of transactions): ${blockDataList.length} ###`);
  if (blockDataList.length > 0) {
    for (const bl of blockDataList) {
      if (bl.length > 0) {
        const envelope = Envelope.deserializeBinary(bl);
        const decodedBlockDataEnvelope = decodeBlockDataEnvelope(envelope);
        decodedBlock.decodedBlockDataEnvelopes.push(decodedBlockDataEnvelope as never);
      } else {
        console.log('There is no transaction data in the block event.');
      }
    }
  }
  console.log('=====**** BLOCK METADATA ****=====');
  const blockMetaData: BlockMetadata = block.getMetadata()!;
  const blockMetaDataList: Array<Uint8Array> = blockMetaData.getMetadataList_asU8();
  console.log('=====**** METADATA 0 ****=====');
  const metadataProtoSignatures = blockMetaDataList[0];
  const metadata: Metadata = Metadata.deserializeBinary(metadataProtoSignatures!);
  const metadataSignature = { value: {}, signatures: [] };
  const value = metadata.getValue_asB64();
  console.log(`Metadata[0] value: ${value}`);
  metadataSignature.value = value;
  const metadataSignatures: Array<MetadataSignature> = metadata.getSignaturesList();
  for (const metadataSig of metadataSignatures) {
    const metadataSign = { nonce: {}, blockSignerMsp: {}, blockSignerX509Info: {}, blockSignerX509Subject: {}, blockSignerCertificate: {}, blockSignerSignature: {} };
    const sigHeader: SignatureHeader = SignatureHeader.deserializeBinary(metadataSig.getSignatureHeader_asU8());
    const signerNonce = sigHeader.getNonce_asB64();
    const signer: SerializedIdentity = SerializedIdentity.deserializeBinary(sigHeader.getCreator_asU8());
    const signerMsp = signer.getMspid();
    const signerId = Buffer.from(signer.getIdBytes_asB64(), 'base64');
    const certX509 = new X509();
    certX509.readCertPEM(signerId.toString());
    console.log(`==> SignerHeader nonce: ${signerNonce}`);
    metadataSign.nonce = signerNonce;
    console.log(`==> Signer MSP: ${signerMsp}`);
    metadataSign.blockSignerMsp = signerMsp;
    console.log(`==> Signer.getInfo(): \n ${certX509.getInfo()}`);
    metadataSign.blockSignerX509Info = certX509.getInfo();
    console.log(`==> Signer.getSubject(): ${JSON.stringify(certX509.getSubject())}`);
    metadataSign.blockSignerX509Subject = certX509.getSubject();
    console.log(`Creator Id Bytes: \n${signerId.toString()}\n `);
    metadataSign.blockSignerCertificate = signerId.toString();
    metadataSign.blockSignerSignature = metadataSig.getSignature_asB64();
    metadataSignature.signatures.push(metadataSign as never);
  }
  decodedBlock.decodedBlockMetadata.push(metadataSignature as never);
  console.log('=====**** METADATA 1 ****=====');
  const metadataProto1 = blockMetaDataList[1];
  decodedBlock.decodedBlockMetadata.push(metadataProto1 as never);
  console.log('=====**** METADATA 2 ****=====');
  const metadataProto2 = blockMetaDataList[2];
  const transactionFilter = { transactionFilter: {} };
  transactionFilter.transactionFilter = metadataProto2!;
  decodedBlock.decodedBlockMetadata.push(transactionFilter as never);
  console.log('=====**** METADATA 3 ****=====');
  const metadataProto3 = blockMetaDataList[3];
  decodedBlock.decodedBlockMetadata.push(metadataProto3 as never);
  console.log('=====**** METADATA 4 ****=====');
  const metadataProto4 = blockMetaDataList[4];
  const commitHash = {
    commitHashB64: {},
  };
  commitHash.commitHashB64 = Buffer.from(metadataProto4!).toString('base64');
  decodedBlock.decodedBlockMetadata.push(commitHash as never);

  console.log(`---> buildBlockInfo Block number: ${blockNum} - hash: ${dataHashAsString} - previous hash: ${previousDataHashAsString} end < ---`);
  console.log('### - END Building blockinfo ###');
  return decodedBlock;
};

/**
 * Decode the block
 * @param data
 */
export const decodeBlockProtobuf = (
  data: Buffer,
): {
  dataHashAsB64: string;
  dataHashAsString: string;
  dataHash: string;
  previousDataHashAsB64: string;
  decodedBlockDataEnvelopes: any[];
  previousDataHash: string;
  blockNum: number;
  previousDataHashAsString: string;
} => {
//   const console = new console(decodeBlockProtobuf.name);
  console.log('### Decoding Hyperledger Fabric Block ###');
  const block: Block = Block.deserializeBinary(data);
  const decodedBlock = decodeBlock(block);
  console.log('### - END Building blockinfo ###');
  return decodedBlock;
};

/**
 * Decode the block
 * @param header
 * @param data
 * @param metadata
 */
export const decodeBlockEventProtobuf = (
  header: Buffer,
  data: Buffer,
  metadata: Buffer,
): {
  dataHashAsB64: string;
  dataHashAsString: string;
  dataHash: string;
  previousDataHashAsB64: string;
  decodedBlockDataEnvelopes: any[];
  previousDataHash: string;
  blockNum: number;
  previousDataHashAsString: string;
} => {
//   const console = new console(decodeBlockProtobuf.name);
  console.log('### Decoding Hyperledger Fabric Block ###');
  const block: Block = Block.deserializeBinary(data);
  const decodedBlock = decodeBlock(block);
  console.log('### - END Building blockinfo ###');
  return decodedBlock;
};