#!/usr/bin/env node

import { Command } from "commander";
import chalk from "chalk";
import figlet from "figlet";

import { handleInstall } from "./commands/install.js";
import { handleCheck } from './commands/check.js';
import { handleUninstall } from './commands/uninstall.js';
import { handleList } from "./commands/list.js";

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
    .action(handleInstall);

program
    .command('check <language>')
    .description("To check if the environment is set up for the selected language")
    .action(handleCheck);

program
    .command('uninstall <language>')
    .description("To uninstall the development environment for chosen language")
    .action(handleUninstall)

program
  .command('list')
  .description('Show all supported languages')
  .action(handleList);


program.parse(process.argv);
