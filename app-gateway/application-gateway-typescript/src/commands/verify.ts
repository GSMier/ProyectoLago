import { Gateway } from "@hyperledger/fabric-gateway";
import { ScientificDataCollection } from "../contract";
import { chaincodeName, channelName } from "../connect";
import { assertDefined, verifyHash } from "../utils";


export default async function main(
  gateway: Gateway,
  args: string[]
): Promise<void> {
  const folderPath = assertDefined(args[0], "Arguments: <folderPath>");
  const network = gateway.getNetwork(channelName);
  const contract = network.getContract(chaincodeName);

  const smartContract = new ScientificDataCollection(contract);
  const records = await smartContract.getAllRecords();


  for (const record of records) {
    const isRawDataVerified = await verifyHash(record.rawData, folderPath);
    const isMetadataVerified = await verifyHash(record.metadata, folderPath);
    const isInputDataVerified = await verifyHash(record.inputData, folderPath);
    const isInputMetadataVerified = await verifyHash(
      record.inputMetadata,
      folderPath
    );
    const isOutputDataVerified = await verifyHash(
      record.outputData,
      folderPath
    );
    const isOutputMetadataVerified = await verifyHash(
      record.outputMetadata,
      folderPath
    );

    if (
      isRawDataVerified &&
      isMetadataVerified &&
      isInputDataVerified &&
      isInputMetadataVerified &&
      isOutputDataVerified &&
      isOutputMetadataVerified
    ) {
      console.log(`Record ${record.Id} is verified.`);
    } else {
      console.log(`Record ${record.Id} verification failed.`);
    }
  }
}
