import path from 'path';
import { fileURLToPath } from 'url';
import chalk from 'chalk';
import { runScript } from '../utils/runScript.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export function handleUninstall(language) {
  console.log(chalk.green(`🧹 Uninstalling:`), chalk.yellow(language));

  const lang = language.toLowerCase();

  if (lang === 'cpp') {
    const script = path.join(__dirname, '../../uninstallers/uninstall_cpp.ps1');
    runScript(script, 'C++');
  } else if (lang === 'java') {
    const script = path.join(__dirname, '../../uninstallers/uninstall_java.ps1');
    runScript(script, 'Java');
  } else if (lang === 'python') {
    const script = path.join(__dirname, '../../uninstallers/uninstall_python.ps1');
    runScript(script, 'Python');
  } else {
    console.log(chalk.red(`❌ Unsupported language: ${language}`));
  }
}
