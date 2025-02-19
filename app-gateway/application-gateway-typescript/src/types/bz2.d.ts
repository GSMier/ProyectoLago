declare module "bz2" {
    export function decompress(bytes: Uint8Array, checkCRC?: boolean): Uint8Array<ArrayBuffer>;
  }