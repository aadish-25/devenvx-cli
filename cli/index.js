#!/usr/bin/env node

import { Command } from "commander";
import chalk from "chalk";
import figlet from "figlet";
import ora from "ora";

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
