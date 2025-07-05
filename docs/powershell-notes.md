# ⚡ DevEnvx PowerShell Internals

A beginner-friendly deep dive into every PowerShell concept used in **DevEnvx** — including install, uninstall, and setup utilities.

This guide assumes **zero prior PowerShell experience** and is written to feel like a dev-to-dev walkthrough.

---

## 📘 Table of Contents

1. [Console Output Behavior](#1-console-output-behavior)  
2. [Installer Labels & Flags](#2-installer-labels--flags)  
3. [Elevation & Admin Privileges](#3-elevation--admin-privileges)  
4. [Process Handling](#4-process-handling)  
5. [HTTP Downloads with Streaming](#5-http-downloads-with-streaming)  
6. [Path Management](#6-path-management)  
7. [Command Detection & Execution](#7-command-detection--execution)  
8. [Error Handling](#8-error-handling)  
9. [Uninstall Logic](#9-uninstall-logic)  
10. [Miscellaneous Concepts](#10-miscellaneous-concepts)  

---

## 1. 🖥 Console Output Behavior

```powershell
[System.Console]::Out.Flush()
```

Forces the console to flush any buffered output and display it immediately.

When a program prints something to the screen, it often doesn’t send it immediately.  
Instead, it stores the output temporarily in a memory area called a “buffer”. This line clears that buffer so the message appears instantly.

---

## 2. 🏷 Installer Labels & Flags

### Common Python Installer Flags

```text
/quiet             → Run silently (no UI)  
InstallAllUsers=0  → Install for current user only  
PrependPath=1      → Add to PATH  
Include_test=0     → Skip installing the test suite  
```

Used when launching `.exe` installers to customize the setup behavior — especially for silent installs with no user interaction.

---

## 3. 🔐 Elevation & Admin Privileges

```powershell
-Verb RunAs
```

Runs the installer with administrator privileges by triggering UAC elevation — but since UAC is a Windows-level security boundary, the user must manually click 'Allow'; it **cannot** be auto-approved by any script or app.

Instead of asking the user to open PowerShell manually as admin, we use `-Verb RunAs` to automatically show the UAC prompt when needed. The script takes care of it.

---

> 💬 **Question** – If the user still has to click 'Allow' for elevation, then what does running as administrator actually enable?

**Answer –**

🔐 What admin privileges help with:
Running the installer using `-Verb RunAs` elevates it to administrator mode after the user approves the UAC prompt. This allows the installer to:
- Write to protected directories like `C:\Program Files`
- Modify system-wide environment variables (like adding Python to the global PATH)
- Install applications for **all users**
- Register services
- Perform system-level setup

⚠️ What could happen without admin privileges:
If the script runs without elevation, it runs using the current user's permissions. This can:
- Prevent access to protected folders
- Restrict changes to system PATH
- Block installation for all users  
In some cases, it may even fail silently or skip important steps — leading to broken setups or runtime errors.

---

## 4. 🔄 Process Handling

```powershell
$process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", $uninstallCmd -Wait -NoNewWindow -PassThru
```

### Explanation of flags:

- `-Wait`  
  Tells PowerShell to pause until the process finishes.  
  It doesn’t move to the next line immediately — just like saying: "Don’t continue until this finishes."

- `-NoNewWindow`  
  Keeps the process inside the **same** terminal window.  
  This prevents new popups and makes logs visible in one place. Especially useful when you want output from the process to show directly in your PowerShell session.

- `-PassThru`  
  Returns a **Process object**. Without this, nothing is returned — it just executes silently.  
  But if you need to check the result, like exit codes, you'll need this.

```powershell
$process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", $uninstallCmd -Wait -NoNewWindow -PassThru
```

This stores the outcome of the process inside `$process` so you can inspect properties like `.ExitCode`.

---

## 5. 🌐 HTTP Downloads with Streaming

```powershell
$client = New-Object System.Net.Http.HttpClient
$response = $client.GetAsync($url, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).Result

$stream = $response.Content.ReadAsStreamAsync().Result
$target = [System.IO.File]::Create($outputPath)

$stream.CopyTo($target)

$target.Close()
$stream.Close()
```

### Explanation:

- The first line creates a `HttpClient` object. It can send GET, POST, etc., and is **reusable**.
- The second line sends a GET request, but only reads the headers — not the content.
  `ResponseHeadersRead` tells it to return **immediately** after receiving headers.

- `$stream` opens a stream to start reading the file's contents (but doesn’t read yet).
- `$target` creates or overwrites a local file where the content will be written.
  [At this point — **no data has transferred yet**.]

- `$stream.CopyTo($target)` is the command that starts the actual transfer.

Think of `$stream` and `$target` like workers waiting at their stations.  
They’ve been told: **“Be ready to do your job, but don’t start yet.”**  
When `CopyTo` is called, both start — the stream begins receiving data from the internet, and the target begins writing it to your disk.

This happens in **chunks** — not all at once.  
By default, each chunk is 80KB. You can customize it using:

```powershell
$stream.CopyTo($target, 4096)  # → 4KB chunk size
```

---

## 6. 🧬 Path Management

```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "Machine")
```

When a script modifies the PATH, it updates it in the Windows Registry — this change applies system-wide instantly.

But your **current PowerShell terminal session doesn’t refresh automatically**. It still holds the old `$env:Path` loaded when the terminal started.

This line forces the current session to **reload both the User and System PATH** directly from the Registry.

> ✅ So the user doesn’t have to restart their terminal or IDE — the changes are visible right away.

---

## 7. 🔍 Command Detection & Execution

```powershell
if (Get-Command python -ErrorAction SilentlyContinue)
```

This checks if a command exists (like `python`, `g++`, etc.) **without throwing an error** if it doesn't.

### `-ErrorAction` behavior:

| Value              | Description                                                  |
|--------------------|--------------------------------------------------------------|
| `SilentlyContinue` | Don’t show the error, but log it quietly                     |
| `Ignore`           | Suppresses the error **and doesn’t even log it**             |
| `Stop`             | Stops the script immediately if there's an error             |
| `Continue`         | Displays the error and continues                             |
| `Inquire`          | Prompts the user interactively (ask what to do on error)     |

> 🧠 `SilentlyContinue` is great for "try to find it, but don’t panic if it’s missing" checks.

---

## 8. ❗ Error Handling

### Try/Catch with `-ErrorAction Stop`

For PowerShell to **actually enter a `catch` block**, you must tell it to stop on errors.

```powershell
try {
    Some-Command -ErrorAction Stop
} catch {
    Write-Host "Caught an error!"
}
```

---

### `$LASTEXITCODE`

This holds the exit code of the **last native application** (like a `.exe` or `cmd.exe`) that was run.

Useful for checking whether an installer or external command succeeded or failed.

---

## 9. ♻ Uninstall Logic

### C++ Toolchain (MSYS2 / MinGW)

- Uses `Test-Path` to check if MSYS2 exists (`C:\msys64`)
- Stops any MSYS2 background processes
- Deletes folders using:

```powershell
Remove-Item "C:\msys64" -Recurse -Force
```

- Cleans up the PATH using:

```powershell
[System.Environment]::SetEnvironmentVariable("Path", $newPath, $scope)
```

---

### Java Uninstaller

- Looks into the registry for apps where `DisplayName` contains `"Java"`
- Checks that uninstall string uses `MsiExec.exe /X {GUID}`
- Re-runs that command silently:

```powershell
Start-Process -FilePath "cmd.exe" -ArgumentList "/c", $uninstallCmd -Wait -NoNewWindow -PassThru
```

---

### Python Uninstaller

- Detects Python registry entries where:
  - `DisplayName` starts with `"Python"`
  - `Publisher` is `"Python Software Foundation"`
  - `UninstallString` has `python-XYZ.exe /uninstall`
- Then executes with:

```powershell
Start-Process ... /quiet
```

---

## 10. 🧩 Miscellaneous Concepts

### `$PSScriptRoot`

Gives the folder path of the script that’s currently running.  
Great for locating sibling files (like `utils.ps1`) reliably.

---

### `-Recurse`

Tells a command to process **all subfolders and files inside** the specified folder — recursively.

Used in:

```powershell
Remove-Item -Recurse
```

---

### `-Force`

Bypasses permissions and allows access to hidden/system files.  
Also skips confirmation prompts for deletion.

> ⚠️ It does **not** mean "forcefully kill a process".  
> It simply allows operations on normally restricted items.

---

### `&` (Call Operator)

Used to run a script, command, or executable stored in a **string or variable**.

```powershell
$cmd = "python --version"
& $cmd
```

Without `&`, PowerShell treats the string as plain text. You must use `&` to **execute** it.

---

## 🧠 Recap

This file documents every PowerShell mechanic we use in DevEnvx:

- ✅ Silent installers  
- 🧹 Registry & PATH refresh  
- ♻️ Toolchain removal  
- 🌐 Streaming file downloads  
- 🔍 Binary detection  
- 🔐 Elevation handling  