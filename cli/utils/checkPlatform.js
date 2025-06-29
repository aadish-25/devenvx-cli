import os from 'os';
import chalk from 'chalk';

export function ensureWindowsPlatform() {
  const platform = os.platform();
  if (platform !== 'win32') {
    console.log(chalk.red('❌ Sorry! DevEnvx currently supports only Windows systems.'));
    console.log(chalk.yellow('💡 macOS and Linux support is planned for future updates.\n'));
    process.exit(1);
  }
}
