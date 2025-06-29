import { execSync } from 'child_process';
import chalk from 'chalk';

// function that shows the 'devenvx' installtion command if langauge isn't present 
const installHelp = (language) => {
  return chalk.yellow(
    `👉 You can try installing it using: ${chalk.cyan(`devenvx install ${language}`)}`
  );
};

// function that runs commands to check if the language is present or not
// this is done by checking their versions using --version(or -version for some tools) 
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

// the main function to handle check
export function handleCheck(language) {
  console.log(chalk.bold(`\n🔍 Checking tools for language: ${chalk.blue(language)}\n`));

  let allOk = true;

  // Python check (we check both python and python3)
  if (language === 'python') {
    let found = false;

    try {
      const output = execSync('python --version 2>&1', { encoding: 'utf8' });
      const version = output.split('\n').find(line => line.trim())?.trim() || 'Unknown';

      console.log(`${chalk.green('✅')} Python (python) is installed. ${chalk.gray('Version:')} ${chalk.cyan(version)}`);
      found = true;
      allOk = true;
    } catch { }

    if (!found) {
      try {
        const output = execSync('python3 --version 2>&1', { encoding: 'utf8' });
        const version = output.split('\n').find(line => line.trim())?.trim() || 'Unknown';

        console.log(`${chalk.green('✅')} Python (python3) is installed. ${chalk.gray('Version:')} ${chalk.cyan(version)}`);
        found = true;
        allOk = true;
      } catch { }
    }

    if (!found) {
      console.log(`${chalk.red('❌')} Python is not installed or not working properly.`);
      console.log(installHelp(language));
      console.log();
      allOk = false;
    }
  }

  // Java check (runtime and compiler checks)
  else if (language === 'java') {
    allOk &&= checkCommand('java', 'Java Runtime (java)', language, '-version');
    allOk &&= checkCommand('javac', 'Java Compiler (javac)', language);

  }

  // CPP check (g++, gcc and gdc)
  else if (language === 'cpp') {
    allOk &&= checkCommand('g++', 'C++ Compiler (g++)', language);
    allOk &&= checkCommand('gcc', 'C Compiler (gcc)', language);
    allOk &&= checkCommand('gdb', 'Debugger (gdb)', language);
  }

  // Nodejs check
  else if (language === 'node') {
    allOk &&= checkCommand('node', 'Node.js (node)', language);
  }

  // PHP check
  else if (language === 'php') {
    allOk &&= checkCommand('php', 'PHP (php)', language);
  }

  // Go check
  else if (language === 'go') {
    allOk &&= checkCommand('go', 'Go (go)', language);
  }

  // Ruby check
  else if (language === 'ruby') {
    allOk &&= checkCommand('ruby', 'Ruby (ruby)', language);
  }

  // C check
  else if (language === 'c') {
    allOk &&= checkCommand('gcc', 'C Compiler (gcc)', language);
  }

  // Rust check (rustc and cargo)
  else if (language === 'rust') {
    allOk &&= checkCommand('rustc', 'Rust Compiler (rustc)', language);
    allOk &&= checkCommand('cargo', 'Rust Package Manager (cargo)', language);
  }

  // fallback for unsupported languages
  else {
    console.log(chalk.red(`❌ Unsupported language: ${language}\n`));
    return;
  }

  // final check: if all required tools are available
  if (allOk) {
    console.log(chalk.greenBright(`\n🎉 All required tools for ${language} are installed and working properly!\n`));
  } else {
    console.log(chalk.yellowBright(`\n⚠️ Some required tools for ${language} are missing or broken.\n`));
  }
}