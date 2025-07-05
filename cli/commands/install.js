// Purpose of handleInstall.js:
// This module handles the DevEnvx install command. It runs the appropriate PowerShell install script
// for each language passed in the CLI (e.g., `devenvx install python java`).
// It uses the runScript utility to execute platform-specific installation scripts.

import path from 'path';
import fs from 'fs';
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
    const scriptPath = path.join(
      __dirname,
      `../../installers/install_${lang}.ps1`
    );

    // Check if the install script actually exists for this language
    try {
      await fs.promises.access(scriptPath);
    } catch {
      console.log(chalk.yellow(`\n[WARN] '${lang}' is not supported.`));
      console.log(chalk.gray(`Use 'npx devenvx list' to view available languages.`));
      continue;
    }

    const displayName = lang === "cpp" ? "CPP" : lang.charAt(0).toUpperCase() + lang.slice(1);
    console.log(chalk.cyan(`\n[INFO] Installing ${displayName}...`));

    try {
      await runScript(scriptPath, displayName);
    } catch (err) {
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
