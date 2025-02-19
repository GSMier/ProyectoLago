import { Gateway } from "@hyperledger/fabric-gateway";
import { assertDefined } from "../utils";
import * as fs from "fs";
import { ScientificData, ScientificDataCollection } from "../contract";
import { chaincodeName, channelName } from "../connect";

export default async function main(
  gateway: Gateway,
  args: string[]
): Promise<void> {
  const jsonFilePath = assertDefined(
    args[0],
    "It must be provided a JSON file"
  );

  try {
    const jsonData = JSON.parse(
      fs.readFileSync(jsonFilePath, "utf8")
    ) as ScientificData;
    if (
      !jsonData.Id ||
      !jsonData.generationDate ||
      !jsonData.type ||
      !jsonData.metadata ||
      !jsonData.rawData ||
      !jsonData.siteName
    )
      throw new Error("Missing required fields");
      
    const network = gateway.getNetwork(channelName);
    const contract = network.getContract(chaincodeName);
    const smartContract = new ScientificDataCollection(contract);
    await smartContract.createRecord(jsonData);
    
    
    console.log(`*** Successfully submitted transaction of record create with  ID: ${jsonData.Id}}`);
    
  } catch (error) {
    console.error(error);
    return;
  }

}
