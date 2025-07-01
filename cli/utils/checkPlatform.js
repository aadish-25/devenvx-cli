// Purpose of checkPlatform.js:
// Verifies that the CLI is being executed on a supported platform (currently Windows only).
// If the platform is not Windows, it displays an appropriate message and terminates execution.

import os from 'os';
import chalk from 'chalk';

// Validates that the current OS is Windows ('win32'). Exits the process if not.
export function ensureWindowsPlatform() {
  const platform = os.platform();
  
  // Display an error and exit if the platform is not supported (i.e., not Windows)
  if (platform !== 'win32') {
    console.log(chalk.red('\n[FAIL] DevEnvx currently supports only Windows systems.'));
    console.log(chalk.yellowBright('[INFO] macOS and Linux support is planned for future updates.\n'));
    process.exit(1);
  }
}
