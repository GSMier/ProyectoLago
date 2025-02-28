/*
 * SPDX-License-Identifier: Apache-2.0
 */
import {
  Context,
  Contract,
  Info,
  Returns,
  Transaction,
} from "fabric-contract-api";
import stringify from "json-stringify-deterministic";
import sortKeysRecursive from "sort-keys-recursive";
import { ScientificData } from "./scientificData";
import { ClientIdentity } from "fabric-shim";

@Info({
  title: "ScientificDataCollect",
  description: "Smart contract for collecting scientific data",
})
export class ScientificDataCollectContract extends Contract {
  @Transaction()
  public async CreateRecord(ctx: Context, data: string): Promise<void> {
    const Cid = new ClientIdentity(ctx.stub);
    if (!Cid.assertAttributeValue("role", "collaborator")) {
      throw new Error("Only collaborators can create record");
    }

    const dataObj = JSON.parse(data) as ScientificData;
    // Validate input fields
    if (
      !dataObj.Id ||
      !dataObj.type ||
      !dataObj.generationDate ||
      !dataObj.metadata ||
      !dataObj.rawData ||
      !dataObj.siteName
    ) {
      throw new Error("Missing required fields");
    }

    // Store the record in the blockchain state
    await ctx.stub.putState(
      dataObj.Id,
      Buffer.from(stringify(sortKeysRecursive(dataObj)))
    );
  }

  @Transaction(false)
  @Returns("string")
  public async ReadRecord(ctx: Context, id: string): Promise<string> {
    const recordJSON = await ctx.stub.getState(id);
    if (!recordJSON || recordJSON.length === 0) {
      throw new Error(`The record ${id} does not exist`);
    }
    return recordJSON.toString();
  }

  @Transaction()
  public async UpdateRecord(
    ctx: Context,
    id: string,
    updatedData: string
  ): Promise<void> {
    const Cid = new ClientIdentity(ctx.stub);
    if (!Cid.assertAttributeValue("role", "collaborator")) {
      throw new Error("Only collaborators can modify records");
    }
    const exists = await this.RecordExists(ctx, id);
    if (!exists) {
      throw new Error(`The record ${id} does not exist`);
    }

    const updatedDataObj: Partial<ScientificData> = JSON.parse(updatedData);
    const oldDataJson = await ctx.stub.getState(id);
    const oldData = JSON.parse(oldDataJson.toString()) as ScientificData;
    // Update the existing fields
    const newData = { ...oldData, ...updatedDataObj };

    // Store the updated data
    await ctx.stub.putState(
      id,
      Buffer.from(stringify(sortKeysRecursive(newData)))
    );
  }

  @Transaction()
  public async DeleteRecord(ctx: Context, id: string): Promise<void> {
    const Cid = new ClientIdentity(ctx.stub);
    if(!Cid.assertAttributeValue('role','collaborator')){
      throw new Error('Only collaborators can delete a record');
    }
    const exists = await this.RecordExists(ctx, id);
    if (!exists) {
      throw new Error(`The record ${id} does not exist`);
    }
    await ctx.stub.deleteState(id);
  }

  @Transaction(false)
  public async GetAllRecords(ctx: Context): Promise<string> {
    const allResults = [];
    // range query with empty string for startKey and endKey does an open-ended query of all assets in the chaincode namespace.
    const iterator = await ctx.stub.getStateByRange("", "");
    let result = await iterator.next();
    while (!result.done) {
      const strValue = Buffer.from(result.value.value.toString()).toString(
        "utf8"
      );
      let record;
      try {
        record = JSON.parse(strValue) as ScientificData;
      } catch (err) {
        console.log(err);
        record = strValue;
      }
      allResults.push(record);
      result = await iterator.next();
    }
    return JSON.stringify(allResults);
  }


  @Transaction(false)
  public async GetRecordById(ctx: Context, id: string): Promise<string> {
    const recordJSON = await ctx.stub.getState(id);
    if (!recordJSON || recordJSON.length === 0) {
      throw new Error(`The record with id ${id} does not exist`);
    }
    return recordJSON.toString();
  }


  @Transaction(false)
  public async GetHistoryForRecord(ctx: Context, id: string): Promise<string> {
    const resultsIterator = await ctx.stub.getHistoryForKey(id);
    const results = await this.GetAllResults(resultsIterator, true);
    return JSON.stringify(results);
  }

  private async RecordExists(ctx: Context, id: string): Promise<boolean> {
    const recordJSON = await ctx.stub.getState(id);
    return recordJSON && recordJSON.length > 0;
  }

  private async GetAllResults(iterator: any, isHistory: boolean) {
    let allResults = [];
    let res = await iterator.next();
    while (!res.done) {
      if (res.value && res.value.value.toString()) {
        let jsonRes = {} as any;
        if (isHistory && isHistory === true) {
          jsonRes.TxId = res.value.txId;
          jsonRes.Timestamp = res.value.timestamp;
          try {
            jsonRes.Value = JSON.parse(res.value.value.toString("utf8"));
          } catch (err) {
            console.log(err);
            jsonRes.Value = res.value.value.toString("utf8");
          }
        } else {
          jsonRes.Key = res.value.key;
          try {
            jsonRes.Record = JSON.parse(res.value.value.toString("utf8"));
          } catch (err) {
            jsonRes.Record = res.value.value.toString("utf8");
          }
        }
        allResults.push(jsonRes);
      }
      res = await iterator.next();
    }
    iterator.close();
    return allResults;
  }
}
