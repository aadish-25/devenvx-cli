// Purpose of handleInstall.js:
// This module handles the DevEnvx install command. It runs the appropriate PowerShell install script
// for each language passed in the CLI (e.g., `devenvx install python java`).
// It uses the runScript utility to execute platform-specific installation scripts.

import path from 'path';
import { fileURLToPath } from 'url';
import chalk from 'chalk';
import { runScript } from '../utils/runScript.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// filename : devenvx\cli\commands\handleInstall.js
// dirname : devenvx\cli\commands

// Main function that handles the installation process
export async function handleInstall(languages) {
  for (const lang of languages) {
    const displayName = lang === "cpp" ? "CPP" : lang.charAt(0).toUpperCase() + lang.slice(1);
    console.log(chalk.cyan(`\n[INFO] Installing ${displayName}...`));

    // This means from the current directory, go 2 steps behind and then into the installers
    // Just writing the installers path without .join(dirname) would mislead the script
    // to go 2 steps behind from wherever the terminal is running
    // Doing .join() tells the program to always go 2 steps behind wrt the directory and find installers
    const scriptPath = path.join(
      __dirname,
      `../../installers/install_${lang}.ps1`
    );

    // runScript() - executes the script whose path is defined by scriptPath
    try {
      await runScript(scriptPath, displayName);
    } catch (err) {
      // PowerShell install scripts return exit code 1 for expected failures (like already installed),
      // so we only print this if something truly crashed.
      if (err.code !== 1) {
        console.error(chalk.red(`\n[FAIL] Unexpected error installing ${displayName}`));
      }
    }
  }
}

// NOTE - No error message is logged for exit code 1, because it's already handled
// within the respective installation PowerShell scripts.
//
// In the context of installation, exit code 1 usually means:
// - The language is already installed
// - Some files are missing or corrupted
// - The environment setup failed due to known reasons (like permission issues)
