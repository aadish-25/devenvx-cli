import chalk from 'chalk';

export function handleList() {
  console.log(chalk.bold("\n📦 Available Language Environments:\n"));

  // Fully Supported
  console.log(`${chalk.green('•')} ${chalk.cyan('C++')}     ${chalk.gray('(MinGW / TDM-GCC)')}`);
  console.log(`${chalk.green('•')} ${chalk.cyan('Java')}    ${chalk.gray('(OpenJDK / Oracle JDK)')}`);
  console.log(`${chalk.green('•')} ${chalk.cyan('Python')}  ${chalk.gray('(Official Python.org Build)')}`);

  console.log(chalk.bold("\n🧪 Experimental / Planned Support:\n"));

  // Future / Experimental
  console.log(`${chalk.yellow('•')} ${chalk.cyan('Node.js')} ${chalk.gray('(Node.js LTS & npm)')}`);
  console.log(`${chalk.yellow('•')} ${chalk.cyan('PHP')}     ${chalk.gray('(Windows Installer)')}`);
  console.log(`${chalk.yellow('•')} ${chalk.cyan('Go')}      ${chalk.gray('(Go SDK)')}`);
  console.log(`${chalk.yellow('•')} ${chalk.cyan('Ruby')}    ${chalk.gray('(RubyInstaller)')}`);
  console.log(`${chalk.yellow('•')} ${chalk.cyan('Rust')}    ${chalk.gray('(Rustup Toolchain)')}`);

  console.log(); // Spacing
}
