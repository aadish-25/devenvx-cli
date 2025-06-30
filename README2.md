# DevEnvx CLI

<p align="center">
  <a href="https://www.npmjs.com/package/devenvx">
    <img src="https://img.shields.io/npm/v/devenvx.svg" alt="npm version">
  </a>
  <a href="https://github.com/aadish-25/devenvx-cli/blob/main/LICENSE">
    <img src="https://img.shields.io/npm/l/devenvx.svg" alt="license">
  </a>
</p>

<p align="center">
  <strong>Your one-stop solution for setting up development environments on Windows.</strong>
</p>

---

DevEnvx is a command-line interface (CLI) tool designed to automate the installation and configuration of development environments for various programming languages on the Windows operating system. It simplifies the process of setting up a new machine or a new project, ensuring that you have all the necessary tools and compilers ready to go with just a few commands.

## Key Features

- **Automated Setup:** Install compilers, interpreters, and build tools without manual downloads or complex configuration steps.
- **Environment Validation:** Quickly check if your environment is correctly configured for a specific language.
- **Clean Uninstallation:** Remove development environments cleanly, without leaving behind stray files or registry entries.
- **Windows-Native:** Utilizes PowerShell scripts to ensure seamless integration with the Windows environment.
- **Extensible:** Built with a modular structure to easily add support for new languages in the future.

## Prerequisites

- **Windows Operating System:** This tool is designed specifically for Windows.
- **Node.js:** Version 14 or higher.
- **npm (Node Package Manager):** Included with Node.js.
- **Administrator Privileges:** The installation scripts require administrator privileges to install software and modify system paths. Please run your terminal (Command Prompt, PowerShell, or Windows Terminal) as an administrator.

## Installation

To get started, install the DevEnvx CLI globally using npm.

```bash
npm install -g devenvx
```

## Command Reference

Here is a detailed breakdown of all the available commands.

---

### `devenvx list`

Lists all the programming languages that are supported by the CLI, indicating whether they are fully supported or experimental.

**Usage:**

```bash
devenvx list
```

---

### `devenvx install [languages...]`

Downloads and installs the development tools for one or more specified languages.

**Usage:**

```bash
devenvx install <language1> [language2] [...]
```

**Arguments:**

- `[languages...]`: A space-separated list of languages to install.

**Examples:**

- **Install a single language:**

  ```bash
  devenvx install python
  ```

- **Install multiple languages at once:**

  ```bash
  devenvx install java cpp
  ```

---

### `devenvx check <language>`

Verifies that the required tools for a given language are installed and accessible in the system's PATH.

**Usage:**

```bash
devenvx check <language>
```

**Arguments:**

- `<language>`: The language to check.

**What it Checks:**

- **`python`**: Checks for `python` or `python3`.
- **`java`**: Checks for `java` (Java Runtime) and `javac` (Java Compiler).
- **`cpp`**: Checks for `g++` (C++ Compiler), `gcc` (C Compiler), and `gdb` (Debugger).
- **`node`**: Checks for `node`.
- **`php`**: Checks for `php`.
- **`go`**: Checks for `go`.
- **`ruby`**: Checks for `ruby`.
- **`c`**: Checks for `gcc`.
- **`rust`**: Checks for `rustc` and `cargo`.

**Example:**

```bash
devenvx check cpp
```

**Sample Output:**

```
🔍 Checking tools for language: cpp

✅ C++ Compiler (g++) is installed. Version: g++ (tdm64-1) 10.3.0
✅ C Compiler (gcc) is installed. Version: gcc (tdm64-1) 10.3.0
✅ Debugger (gdb) is installed. Version: GNU gdb (GDB) 10.2

🎉 All required tools for cpp are installed and working properly!
```

---

### `devenvx uninstall <language>`

Uninstalls the development environment for a specific language that was previously installed by DevEnvx.

**Usage:**

```bash
devenvx uninstall <language>
```

**Arguments:**

- `<language>`: The language environment to uninstall.

**Example:**

```bash
devenvx uninstall python
```

---

## Supported Languages

| Language | Status              | Installer Details             |
| :------- | :------------------ | :---------------------------- |
| C++      | ✅ Fully Supported  | MinGW / TDM-GCC               |
| Java     | ✅ Fully Supported  | OpenJDK / Oracle JDK          |
| Python   | ✅ Fully Supported  | Official Python.org Build     |
| Node.js  | 🧪 Experimental     | Node.js LTS & npm             |
| PHP      | 🧪 Experimental     | Windows Installer             |
| Go       | 🧪 Experimental     | Go SDK                        |
| Ruby     | 🧪 Experimental     | RubyInstaller                 |
| Rust     | 🧪 Experimental     | Rustup Toolchain              |

## How It Works

DevEnvx is a Node.js application that serves as a user-friendly wrapper around a collection of PowerShell (`.ps1`) scripts. When you run a command like `devenvx install python`, the CLI locates the corresponding `install_python.ps1` script and executes it with the necessary permissions. This approach allows the tool to perform powerful system-level tasks, such as downloading and running installers, setting environment variables, and configuring the system PATH.

## Contributing

We welcome contributions from the community! If you'd like to help improve DevEnvx or add support for a new language, please follow these steps:

1.  **Fork the repository** on GitHub.
2.  **Create a new branch** for your feature or bug fix: `git checkout -b feat/add-new-language`
3.  **Make your changes.** If adding a new language, you will need to create:
    - An installer script in `installers/install_new-language.ps1`.
    - An uninstaller script in `uninstallers/uninstall_new-language.ps1`.
    - Update the command handlers in the `cli/commands/` directory.
4.  **Commit your changes** with a clear and descriptive commit message.
5.  **Push your branch** to your fork.
6.  **Create a pull request** to the main repository.

## License

This project is licensed under the ISC License. See the [LICENSE](LICENSE) file for more details.