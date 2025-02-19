import { Gateway } from "@hyperledger/fabric-gateway";
import create from './create';
import deleteCommand from './delete';
import getAllRecords from './getAllRecords';
import read from './read';
import update from './update'
import qscc from './qscc'
import history from './history'
import verify from './verify'
import verifyOne from './verifyOne'

export type Command = (gateway: Gateway, args: string[] ) => Promise<void | string>;

export const commands: Record<string, Command> = {
    create,
    delete: deleteCommand,
    getAllRecords,
    read,
    update,
    qscc,
    history,
    verify,
    verifyOne
    
};