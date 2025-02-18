import { Gateway } from "@hyperledger/fabric-gateway";
import create from './create';
import deleteCommand from './delete';
import getAllAssets from './getAllAssets';
import listen from './listen';
import read from './read';
import update from './update'
import qscc from './qscc'

export type Command = (gateway: Gateway, args: string[]) => Promise<void>;

export const commands: Record<string, Command> = {
    create,
    delete: deleteCommand,
    getAllAssets,
    listen,
    read,
    update,
    qscc
    
};