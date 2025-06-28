import path from 'path';
import { fileURLToPath } from 'url';
import chalk from 'chalk';
import { runScript } from '../utils/runScript.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export async function handleInstall(languages) {
  for (const lang of languages) {
    console.log(chalk.green(`\n📦 Installing:`), chalk.yellow(lang));

    const scriptPath = path.join(
      __dirname,
      `../../installers/install_${lang}.ps1`
    );

    try {
      await runScript(scriptPath, lang.charAt(0).toUpperCase() + lang.slice(1));
    } catch (e) {
      console.error(`❌ Failed to install ${lang}`);
    }
  }
}

