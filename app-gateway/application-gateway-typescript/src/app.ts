/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

import { Command, commands } from './commands';
import { displayInputParameters, newGatewayConnection, newGrpcConnection } from './connect';


async function main(): Promise<void> {
    displayInputParameters();


    const commandName = process?.argv[2];
    if(!commandName) return;
    const args = process?.argv?.slice(3);

    const command = commands[commandName];
    if (!command) {
        printUsage();
        throw new Error(`Unknown command: ${commandName}`);
    }

    try {
        await runCommand(commands.qscc!, args);
        
    } catch (error) {
        console.log(error);
        return;
        
    }

    // await runCommand(command, args);

}

main().catch((error: unknown) => {
    console.error('******** FAILED to run the application:', error);
    process.exitCode = 1;
});

async function runCommand(command: Command, args: string[]): Promise<void> {
    const client = await newGrpcConnection();
    try {
        const gateway = await newGatewayConnection(client);
        try {
            await command(gateway, args);
        } finally {
            gateway.close();
        }
    } finally {
        client.close();
    }
}


function printUsage(): void {
    console.log('Arguments: <command> [<arg1> ...]');
    console.log('Available commands:');
    console.log(`\t${Object.keys(commands).sort().join('\n\t')}`);
}
