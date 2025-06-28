#!/usr/bin/env node

import { Command } from "commander";
import chalk from "chalk";
import figlet from "figlet";
import ora from "ora";

import { exec } from 'child_process';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);


const program = new Command()

program
    .name('devenvx')
    .version('1.0.0')
    .description('DevEnvx CLI for installing C++, Java, and Python environments')

if (process.argv.length <= 2) {
    console.log(chalk.cyanBright.bold("\n🚀 Welcome to DevEnvx CLI\n"));

    console.log(
        chalk.red(
            figlet.textSync("DevEnvx", {
                font: "ANSI Shadow",
                horizontalLayout: "default",
                verticalLayout: "default",
                width: 80,
                whitespaceBreak: true,
            })
        )
    );
}

program.command('install [languages...]')
    .description('Used to install environments for selected languages')
    .action((languages) => {
        console.log(chalk.green(`📦 Installing: `) + chalk.yellow(languages.join(', ')));

        if (languages.includes('cpp')) {
            const scriptPath = path.join(__dirname, '../installers/install_cpp.ps1');
            exec(`powershell -ExecutionPolicy Bypass -File "${scriptPath}"`, (err, stdout, stderr) => {
                if (err) {
                    console.error(chalk.red('❌ Error running install_cpp.ps1'));
                    console.error(chalk.gray(stderr));
                    return;
                }
                console.log(chalk.green(stdout));
            });
        }
    })

program.command('verify [languages...]')
    .description("To verify if the environment is set up for the selected languages")
    .action((languages) => {
        console.log(chalk.green(`🛠️ Checking for development environment for ${languages.join(', ')}`));
    })

program.command('reset [languages...]')
    .description("To reset development environment for chosen languages")
    .action((languages) => {
        console.log(chalk.green(`♻️ Checking for development environment for ${languages.join(', ')}`));
    })

program.parse(process.argv);
