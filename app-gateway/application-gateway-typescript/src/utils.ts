import { HashLocation } from "./contract";
import * as crypto from "crypto";
import * as fs from "fs";
const bz2 = require("unbzip2-stream");
const utf8Decoder = new TextDecoder();



export type PrintView<T> = {
    [K in keyof T]: T[K] extends Uint8Array ? string : T[K];
};


export function printable<T extends object>(event: T): PrintView<T> {
    return Object.fromEntries(
        Object.entries(event).map(([k, v]) => [k, v instanceof Uint8Array ? utf8Decoder.decode(v) : v])
    ) as PrintView<T>;
}

export function assertAllDefined<T>(values: (T | undefined)[], message: string | (() => string)): T[] {
    values.forEach(value => assertDefined(value, message));
    return values as T[];
}

export function assertDefined<T>(value: T | undefined, message: string | (() => string)): T {
    if (value == undefined) {
        throw new Error(typeof message === 'string' ? message : message());
    }

    return value;
}

async function sha256Bzip2Hash(filePath: string): Promise<string | void> {
    return new Promise((resolve, reject) => {
      const hasher = crypto.createHash("sha256");
      const stream = fs.createReadStream(filePath).pipe(bz2());

      stream.on("data", (chunk: any) => {
        hasher.update(chunk);
      });

      stream.on("end", () => resolve(hasher.digest("hex")));
      stream.on("error", (err: any) =>
        reject(`Error reading ${filePath}: ${err.message}`)
      );
    });
  }


async function computeHash(filePath: string): Promise<string | void> {
    try {
      if (filePath.endsWith(".bz2")) {
        const hash = await sha256Bzip2Hash(filePath);
        return hash;
      } else {
        const fileContent = fs.readFileSync(filePath);
        let contentToHash = fileContent;

        return crypto.createHash("sha256").update(contentToHash).digest("hex");
      }
    } catch (error) {
      console.log("***There has been an error reading the file***");
      console.log(error);
    }
  }

export async function verifyHash(
    dataProperty:
      | HashLocation
      | { primary: HashLocation; secondary: HashLocation }
      | undefined,
    folderPath: string
  ): Promise<boolean> {
    if (!dataProperty) {
      return true; // No verification needed for string type
    }
    const dataHash = dataProperty as HashLocation;
    const dataPriSec = dataProperty as {
      primary: HashLocation;
      secondary: HashLocation;
    };

    if (!!dataHash?.location) {
      const filePath = `${folderPath}${dataHash.location}`;
      const computedHash = await computeHash(filePath);
      return computedHash === dataHash.hash;
    } else {
      const filePriPath = `${folderPath}${dataPriSec.primary.location}`;
      const fileSecPath = `${folderPath}${dataPriSec.secondary.location}`;
      const computedHashPri = await computeHash(filePriPath);
      const computedHashSec = await computeHash(fileSecPath);
      return (
        computedHashPri === dataPriSec.primary.hash &&
        computedHashSec === dataPriSec.secondary.hash
      );
    }
  }