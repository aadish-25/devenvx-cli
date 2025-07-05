// Purpose of checkTool.js:
// This script verifies whether the required tools (like compilers or interpreters) for a given programming language
// are installed and working correctly by checking their versions.
// Used in DevEnvx for the `devenvx check <language>` command.

import { execSync } from 'child_process';
import chalk from 'chalk';

// Function that shows the 'devenvx' installation command if language isn't present
const installHelp = (language) => {
  return chalk.yellow(
    `👉 You can try installing it using: ${chalk.cyan(`devenvx install ${language}`)}`
  );
};

// Function to check command version
const checkCommand = (cmd, cmdName, language, versionFlag = '--version') => {
  try {
    const output = execSync(`${cmd} ${versionFlag} 2>&1`, {
      encoding: 'utf8',
    });
    const versionLine = output.split('\n').find(line => line.trim())?.trim() || 'Unknown';
    console.log(
      `${chalk.green('✅')} ${chalk.bold(cmdName)} is installed. ${chalk.gray('Version:')} ${chalk.cyan(versionLine)}`
    );
    return true;
  } catch {
    console.log(`${chalk.red('❌')} ${chalk.bold(cmdName)} is not installed or not working properly.`);
    console.log(installHelp(language));
    console.log();
    return false;
  }
};

// List of dynamically supported check handlers
const checkHandlers = {
  python: () => {
    let found = false;
    try {
      const output = execSync('python --version 2>&1', { encoding: 'utf8' });
      const version = output.split('\n').find(line => line.trim())?.trim() || 'Unknown';
      console.log(`${chalk.green('✅')} Python (python) is installed. ${chalk.gray('Version:')} ${chalk.cyan(version)}`);
      found = true;
    } catch { }

    if (!found) {
      try {
        const output = execSync('python3 --version 2>&1', { encoding: 'utf8' });
        const version = output.split('\n').find(line => line.trim())?.trim() || 'Unknown';
        console.log(`${chalk.green('✅')} Python (python3) is installed. ${chalk.gray('Version:')} ${chalk.cyan(version)}`);
        found = true;
      } catch { }
    }

    if (!found) {
      console.log(`${chalk.red('❌')} Python is not installed or not working properly.`);
      console.log(installHelp('python'));
      return false;
    }

    return true;
  },

  java: () =>
    checkCommand('java', 'Java Runtime (java)', 'java', '-version') &&
    checkCommand('javac', 'Java Compiler (javac)', 'java'),

  cpp: () =>
    checkCommand('g++', 'C++ Compiler (g++)', 'cpp') &&
    checkCommand('gcc', 'C Compiler (gcc)', 'cpp') &&
    checkCommand('gdb', 'Debugger (gdb)', 'cpp'),

  node: () =>
    checkCommand('node', 'Node.js (node)', 'node'),

  php: () =>
    checkCommand('php', 'PHP (php)', 'php'),

  go: () =>
    checkCommand('go', 'Go (go)', 'go'),

  ruby: () =>
    checkCommand('ruby', 'Ruby (ruby)', 'ruby'),

  c: () =>
    checkCommand('gcc', 'C Compiler (gcc)', 'c'),

  rust: () =>
    checkCommand('rustc', 'Rust Compiler (rustc)', 'rust') &&
    checkCommand('cargo', 'Rust Package Manager (cargo)', 'rust'),
};

// Main function called when user runs: devenvx check <language>
export function handleCheck(language) {
  const checkFn = checkHandlers[language];

  if (!checkFn) {
    console.log(chalk.yellow(`\n[WARN] '${language}' is not a supported language.`));
    console.log(chalk.gray(`[HINT] Use ${chalk.cyan('npx devenvx list')} to see all supported languages.\n`));
    return;
  }

  console.log(chalk.bold(`\n🔍 Checking tools for language: ${chalk.blue(language)}\n`));

  const allOk = checkFn();

  if (allOk) {
    console.log(chalk.greenBright(`\n🎉 All required tools for ${language} are installed and working properly!\n`));
  } else {
    console.log(chalk.yellowBright(`⚠️ Some required tools for ${language} are missing or broken.\n`));
  }
}