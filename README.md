<h1 align="center">
  🚀 DevEnvx CLI  
  <br>
  <a href="https://www.npmjs.com/package/devenvx">
    <img src="https://img.shields.io/badge/npm-devenvx-blue" alt="npm">
  </a>
  <a href="https://github.com/aadish-25/devenvx-cli">
    <img src="https://img.shields.io/badge/GitHub-Repository-brightgreen" alt="GitHub Repo">
  </a>
  <a href="https://github.com/aadish-25/devenvx-cli/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-red" alt="License">
  </a>
</h1>

<p align="center"><strong>Available instantly via <code>npx</code> — no install, no setup, no browser.</strong></p>

---

## The Ultimate Development Environment Setup Tool for Windows

**DevEnvx CLI** is a zero-install, cross-language setup tool available directly via `npx`.  
It lets you configure full development environments (Python, Java, C++, and more) from the terminal — no downloads, no GUIs, no extra setup.  
Everything happens via trusted PowerShell scripts under the hood, but you only run one command:

```bash
npx devenvx
```

That’s it. **No global installation. No browser. No configuration.**

---

## ✨ Why DevEnvx?

- **Powered by npm** — Instantly accessible via the world’s most trusted package registry — no installs, no browser, just run.
- **Truly One-Line Setup** — From nothing to a fully configured environment in seconds  
- **Zero Browser Required** — Everything happens in your terminal  
- **Windows-Native Integration** — Purpose-built for Windows using PowerShell scripts  
- **Clean, Fast, & Reliable** — Optimized installers with intelligent validation  
- **Multiple Language Support** — Set up C++, Java, Python, and more with one interface  

---

## 🚀 Get Started in Seconds

### 1. Run DevEnvx directly:

```bash
npx devenvx
```

### 2. Set up your desired programming language:

```bash
npx devenvx install python
```

### 3. Start coding instantly

Your environment is ready to use right away — no terminal restart needed.

```bash
python --version
```

> ℹ️ **Note:**  
> The first time you run `npx devenvx`, npm may ask:  
> `Need to install the following packages: devenvx... Ok to proceed? (y)`  
> Just type `y` — from next time, it runs instantly without prompts.

> ⚠️ Having issues running DevEnvx in PowerShell? [Click here to troubleshoot.](#-powershell-troubleshooting)

---

## 🛠️ Features That Set DevEnvx Apart

- **Smart Installation** — Automatically detects existing installations and skips unnecessary downloads  
- **Environment Validation** — Verifies your setup with real compilation tests  
- **PATH Management** — Automatically configures system PATH variables  
- **Clean Uninstallation** — Remove environments without leaving stray files or registry entries  
- **Multiple Language Support** — Install multiple languages with one command  
- **Published on npm** — Delivered via the world’s most trusted package registry — no shady downloads, no manual scripts

```bash
# Install multiple environments at once
npx devenvx install java cpp python
```

---

## 📋 Command Reference

### List Supported Languages

```bash
npx devenvx list
```

### Install Language Environment(s)

```bash
npx devenvx install python              # Install a single language
npx devenvx install java cpp            # Install multiple languages at once
```

### Verify Language Environment

```bash
npx devenvx check cpp
```

<details>
  <summary>Sample Output</summary>

  ```
  🔍 Checking tools for language: cpp

  ✅ C++ Compiler (g++) is installed. Version: g++ (tdm64-1) 10.3.0  
  ✅ C Compiler (gcc) is installed. Version: gcc (tdm64-1) 10.3.0  
  ✅ Debugger (gdb) is installed. Version: GNU gdb (GDB) 10.2  

  🎉 All required tools for cpp are installed and working properly!
  ```
</details>

### Uninstall Language Environment

```bash
npx devenvx uninstall python
```

---

## 🌟 Supported Languages

| Language | Status              | Installer Details             | Features                               |
| :------- | :------------------ | :---------------------------- | :------------------------------------- |
| C++      | ✅ Fully Supported  | MinGW / TDM-GCC               | g++, gcc, gdb                          |
| Java     | ✅ Fully Supported  | OpenJDK / Oracle JDK          | JDK, JRE, javac                        |
| Python   | ✅ Fully Supported  | Official Python.org Build     | Python 3.x, pip                        |
| Node.js  | 🧪 Experimental     | Node.js LTS                   | Node.js, npm                           |
| PHP      | 🧪 Experimental     | Windows Installer             | PHP, Composer                          |
| Go       | 🧪 Experimental     | Go SDK                        | Go toolchain                           |
| Ruby     | 🧪 Experimental     | RubyInstaller                 | Ruby, gem                              |
| Rust     | 🧪 Experimental     | Rustup Toolchain              | rustc, cargo                           |

---

## 🔄 How It Works

DevEnvx uses Node.js and PowerShell to create a seamless installation experience:

1. The CLI parses your command and identifies the language(s) to install  
2. It runs specialized PowerShell scripts with elevated permissions to:  
   - Download official installers directly from trusted sources  
   - Execute installations with silent flags for zero-interaction setup  
   - Configure system PATH and environment variables  
   - Verify the installation with real compilation tests  
3. You get a fully functional development environment without leaving your terminal  

---

## 🏆 What Makes DevEnvx One-of-a-Kind

- **No Browser Required** — Unlike other tools that open your browser or require manual downloads, DevEnvx handles everything within the terminal  
- **Zero Manual Intervention** — No clicking through installers or manually configuring environment variables  
- **First-Class Windows Support** — Built specifically for Windows, not a Linux tool poorly adapted to Windows  
- **Intelligent Recovery** — Automatically detects and fixes broken or partial installations  
- **Actual Compilation Testing** — Verifies installations by compiling and running real code  

---

## 📚 PowerShell Documentation

To understand how DevEnvx works under the hood, including all PowerShell flags, behaviors, and scripting logic used in our installers and uninstallers:

🔗 [docs/powershell-notes.md](./docs/powershell-notes.md)

This guide is beginner-friendly and explains every flag and concept used in the project — a must-read if you're exploring or contributing.

---

## 🔍 Real-World Use Cases

- **Developer Onboarding** — Get new team members coding in minutes with a complete environment setup.  
- **Multi-Language Learning** — Quickly set up and switch between Python, Java, C++, and more for study or experimentation.  
- **Classroom & Training** — Provision dozens of machines with consistent environments — no manual setup needed.  
- **CI/CD Integration** — Automate reliable, reproducible dev setups in your continuous integration workflows.  

---

## 📋 Prerequisites

- Windows 10 or 11  
- Node.js v14.0.0 or higher  
- Administrator privileges (for system-level installations)  

---

## 👥 Contributing

We welcome contributions! To add support for a new language or improve existing functionality:

1. Fork the repository  
2. Create a new branch for your feature  
3. Add your installer/uninstaller scripts  
4. Submit a pull request  

See the [contributing guidelines](CONTRIBUTING.md) for detailed instructions.

---

## 📜 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 📊 Project Roadmap

- [ ] Support for more programming languages  
- [ ] Automated development environment setup (VS Code, IDEs)  
- [ ] Project template generation  
- [ ] Docker container integration  
- [ ] Cross-platform support (macOS, Linux)  

---

## 🤝 Acknowledgments

- Built with [Node.js](https://nodejs.org/) and [PowerShell](https://github.com/PowerShell/PowerShell)  

---

<p align="center"><em>DevEnvx is available globally via the world's largest package registry — <strong>npm</strong>.</em></p>

<p align="center"><strong>DevEnvx: Because setting up your development environment shouldn't be harder than actual coding.</strong></p>

---

## 🧠 PowerShell Troubleshooting

If you see an error like this when running `npx devenvx`:

```
npx : File C:\Program Files\nodejs\npx.ps1 cannot be loaded because running scripts is disabled on this system.
```

It means your system's **PowerShell script execution policy is restricted**.

### ✅ Fix: Allow PowerShell Scripts Permanently (Safe)

To allow trusted scripts to run in all PowerShell sessions for your user account, run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

This is a **safe and permanent fix** that enables locally created or signed scripts — without affecting system-wide security.