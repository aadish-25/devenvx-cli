#!/usr/bin/env node

import { Command } from "commander";
import chalk from "chalk";
import figlet from "figlet";
import { handleInstall } from "./commands/install.js";

const program = new Command();

program
    .name("devenvx")
    .version("1.0.0")
    .description("DevEnvx CLI for installing C++, Java, and Python environments");

if (process.argv.length <= 2) {
    console.log(chalk.cyanBright.bold("\n🚀 Welcome to DevEnvx CLI\n"));
    console.log(chalk.red(figlet.textSync("DevEnvx", { font: "ANSI Shadow" })));
}

program
    .command("install [languages...]")
    .description("Install environments for selected languages")
    .option('--check', 'checks if langauge already exists')
    .action(handleInstall);

program
    .command('verify [languages...]')
    .description("To verify if the environment is set up for the selected languages")
    .action();

program
    .command('reset [languages...]')
    .description("To reset development environment for chosen languages")
    .action()

program.parse(process.argv);
