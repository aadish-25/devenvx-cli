// Purpose of handleUninstall.js:
// This module handles the DevEnvx uninstall command. It runs the appropriate PowerShell uninstall script
// for the specified language passed via CLI (e.g., `devenvx uninstall python`).
// It uses the runScript utility to execute platform-specific uninstaller scripts.

import path from 'path';
import { fileURLToPath } from 'url';
import chalk from 'chalk';
import { runScript } from '../utils/runScript.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// filename : devenvx\cli\commands\handleUninstall.js
// dirname : devenvx\cli\commands

// Main function that handles the uninstallation process
export async function handleUninstall(language) {
  const lang = language.toLowerCase();

  const scriptMap = {
    cpp: path.join(__dirname, '../../uninstallers/uninstall_cpp.ps1'),
    java: path.join(__dirname, '../../uninstallers/uninstall_java.ps1'),
    python: path.join(__dirname, '../../uninstallers/uninstall_python.ps1'),
  };

  // Get the correct uninstall script for the selected language
  const script = scriptMap[lang];

  if (!script) {
    console.log(chalk.red(`[FAIL] Unsupported language: ${language}`));
    return;
  }

  const displayName = lang === "cpp" ? "CPP" : lang.charAt(0).toUpperCase() + lang.slice(1);
  console.log(chalk.cyan(`\n[INFO] Uninstalling ${displayName}...`));

  // runScript() - executes the script whose path is defined above
  try {
    await runScript(script, displayName);
  } catch (err) {
    // PowerShell uninstall scripts return exit code 1 for known failures (e.g., not installed),
    // so we only show this error if it's truly unexpected
    if (err.code !== 1) {
      console.error(chalk.red(`\n[FAIL] Unexpected error uninstalling ${displayName}`));
    }
  }

}

// NOTE - No error message is logged for exit code 1, because it's already handled 
// within the respective uninstall PowerShell scripts.
//
// In the context of uninstallation, exit code 1 typically indicates:
// - The language is not currently installed
// - Required uninstall keys or files are missing
// - The environment has already been removed

addEventListeneras
false