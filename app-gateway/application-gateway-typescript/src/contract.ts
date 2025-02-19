/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import { CommitError, Contract, StatusCode } from "@hyperledger/fabric-gateway";
import { TextDecoder } from "util";

const RETRIES = 2;

const utf8Decoder = new TextDecoder();

export interface HashLocation{
  hash: string;
  location: string
}

export interface ScientificData {
  Id: string;
  type: string;
  generationDate: string;
  metadata: HashLocation | {primary: HashLocation, secondary: HashLocation};
  rawData: HashLocation | {primary: HashLocation, secondary: HashLocation};
  inputData?: HashLocation;
  inputMetadata?: HashLocation;
  outputData?: HashLocation;
  outputMetadata?: HashLocation;
  siteName: string;
  collaboratorName?: string;
  orcid?: string;
  accesUrl?: string;
}


/**
 * ScientificDataTransfer presents the smart contract in a form appropriate to the business application. Internally it uses the
 * Fabric Gateway client API to invoke transaction functions, and deals with the translation between the business
 * application and API representation of parameters and return values.
 */
export class ScientificDataCollection {
  private contract: Contract;

  constructor(contract: Contract) {
    this.contract = contract;
  }

  async createRecord(data: ScientificData): Promise<void> {
    await this.contract.submit("CreateRecord", {
      arguments: [JSON.stringify(data)],
    });
  }

  async getAllRecords(): Promise<ScientificData[]> {
    const result = await this.contract.evaluate("GetAllRecords");
    if (result.length === 0) {
      return [];
    }

    return JSON.parse(utf8Decoder.decode(result)) as ScientificData[];
  }

  async readRecord(id: string): Promise<ScientificData> {
    const result = await this.contract.evaluate("ReadRecord", {
      arguments: [id],
    });
    return JSON.parse(utf8Decoder.decode(result)) as ScientificData;
  }

  async updateRecord(
    updatedData :Partial<ScientificData>  & Pick<ScientificData, "Id">
  ): Promise<void> {
    await submitWithRetry(() =>
      this.contract.submit("UpdateRecord", {
        arguments: [JSON.stringify(updatedData)],
      })
    );
  }

  async deleteRecord(id: string): Promise<void> {
    await submitWithRetry(() =>
      this.contract.submit("DeleteRecord", {
        arguments: [id],
      })
    );
  }

  async recordExists(id: string): Promise<boolean> {
    const result = await this.contract.evaluate("RecordExists", {
      arguments: [id],
    });
    return utf8Decoder.decode(result).toLowerCase() === "true";
  }

  async getHistoryForRecord(id: string): Promise<string> {
    const result = await this.contract.evaluate("GetHistoryForRecord", {
      arguments: [id],
    });
    return JSON.parse(utf8Decoder.decode(result));
  }
}

async function submitWithRetry<T>(submit: () => Promise<T>): Promise<T> {
  let lastError: unknown | undefined;

  for (let retryCount = 0; retryCount < RETRIES; retryCount++) {
    try {
      return await submit();
    } catch (err: unknown) {
      lastError = err;
      if (err instanceof CommitError) {
        // Transaction failed validation and did not update the ledger. Handle specific transaction validation codes.
        if (err.code === StatusCode.MVCC_READ_CONFLICT) {
          continue; // Retry
        }
      }
      break; // Failure -- don't retry
    }
  }

  throw lastError;
}
