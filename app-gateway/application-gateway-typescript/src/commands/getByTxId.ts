import { Gateway } from "@hyperledger/fabric-gateway";
import {  channelName } from '../connect';
import { assertDefined } from "../utils";
import { decodeProcessedTransaction } from "../decodeBlock";
import { writeFileSync } from "fs";
export default async function main(gateway: Gateway, args: string[]): Promise<any> {
    const network = gateway.getNetwork(channelName);
    const contract = network.getContract("qscc");
    const transactionId = assertDefined(args[0], "Arguments: <folderPath>");
    
    
    
    const data = await contract.evaluateTransaction("GetTransactionByID", channelName, transactionId);
    const newDecodedTransaction = decodeProcessedTransaction(Buffer.from(data));
    console.log('---> getTransactionByTxId - end < ---');

    writeFileSync(`/var/data/decodedTransaction.json`, JSON.stringify(newDecodedTransaction, null, 2));
    return { newDecodedTransaction }

    
}