import { Gateway } from '@hyperledger/fabric-gateway';
import { assertDefined } from '../utils';
import * as fs from "fs";
import { chaincodeName, channelName } from '../connect';
import { ScientificData, ScientificDataCollection } from '../contract';

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
    ) as Partial<ScientificData>  & Pick<ScientificData, "Id">;
    if (
      !jsonData.Id
    )
      throw new Error("Missing required field ID");
      
    const network = gateway.getNetwork(channelName);
    const contract = network.getContract(chaincodeName);
    const smartContract = new ScientificDataCollection(contract);
    await smartContract.updateRecord(jsonData);
    
    
    console.log(`*** Successfully submitted transaction of record update with  ID: ${jsonData.Id}}`);
    
  } catch (error) {
    console.error(error);
    return;
  }

}