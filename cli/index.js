#!/usr/bin/env node

import { Command } from "commander";
import chalk from "chalk";
import figlet from "figlet";

import { ensureWindowsPlatform } from './utils/checkPlatform.js';
import { handleInstall } from "./commands/install.js";
import { handleCheck } from './commands/check.js';
import { handleUninstall } from './commands/uninstall.js';
import { handleList } from "./commands/list.js";

ensureWindowsPlatform();

const program = new Command();

program
    .name("devenvx")
    .version("1.0.0");

if (process.argv.length <= 2) {
    console.log(chalk.cyanBright.bold("\n🚀 Welcome to DevEnvx CLI\n"));
    console.log(chalk.red(figlet.textSync("DevEnvx", { font: "ANSI Shadow" })));

    console.log(chalk.blueBright("⚙️ DevEnvx CLI - Install and manage C++, Java, and Python environments"));
    console.log(chalk.greenBright("✨ Use ") + chalk.yellowBright("devenvx --help") + chalk.greenBright(" to get started!\n"));
}

program
    .command("install [languages...]")
    .description("Install environments for selected languages")
    .action(handleInstall);

program
    .command("check <language>")
    .description("Check if the environment is set up for the selected language")
    .action(handleCheck);

program
    .command("uninstall <language>")
    .description("Uninstall the development environment for the selected language")
    .action(handleUninstall);

program
    .command("list")
    .description("Show all supported languages")
    .action(handleList);

program.parse(process.argv);
