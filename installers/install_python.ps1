# Python Install Script for DevEnvx

# This script is part of DevEnvx. It installs Python automatically if not already installed.
# It checks for existing installation, handles broken installs, downloads the official installer,
# runs it silently, verifies setup, and finally runs a test script to confirm everything works.

# ---------------------------------------------------------------------

# Import reusable progress bar function for showing installer download progress
. "$PSScriptRoot\..\cli\utils\showLoader.ps1"

# Refresh the current PowerShell session's PATH variable to include any recent system/user updates
# $env:Path holds the current PATH for this terminal session only
# This line pulls fresh PATH values from registry (User + Machine) and combines them
# It overwrites $env:Path, updating the session with the latest PATH entries
# Thus user doesnt have to restart their terminal or IDE to see the changes
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" +
[System.Environment]::GetEnvironmentVariable("Path", "Machine")

# Checking if Python is already installed by running 'python --version'
Write-Host "`n[INFO] Checking if Python is already installed..." 
try {

    # 2>&1 redirects stderr (stream 2) to stdout (stream 1), ensuring both are captured.
    # Useful because some versions of Python print the version to stderr.
    $version = python --version 2>&1
    if ($version -match "^Python\s+\d+\.\d+") {
        # s - one or more spaces
        # d - one or more digits
        # Captures something like - Python 3.1.1
        Write-Host "[SUCCESS] Python is already installed: $version`n" -ForegroundColor Green
        exit 0
    }
    else {
        Write-Host "[FAIL] Python is not installed." -ForegroundColor Red
    }
}
catch {
    Write-Host "[FAIL] Python is not installed." -ForegroundColor Red
}

# Detects broken installation and cleans it
# It checks if the installation folder exists but Python executable is missing
# This usually means a previous install was interrupted or corrupted
$expectedPath = "C:\Users\$env:USERNAME\AppData\Local\Programs\Python"
$expectedExe = "$expectedPath\Python312\python.exe"

# It checks the expected path for the expected exe
if ((Test-Path $expectedPath) -and (-not (Test-Path $expectedExe))) {
    Write-Host "`n[WARN] Python folder exists but essential binary is missing." -ForegroundColor Yellow
    Write-Host "[INFO] Attempting automatic recovery by deleting broken install..." -ForegroundColor Cyan

    try {
        Remove-Item -Path $expectedPath -Recurse -Force -ErrorAction Stop
        Write-Host "[OK] Broken Python installation removed." -ForegroundColor Green
    }
    catch {
        Write-Host "[FAIL] Could not delete broken Python install. Please delete it manually: $expectedPath" -ForegroundColor Red
        exit 1
    }
}

# Download the official Python installer from python.org
Write-Host "`n[INFO] Downloading Python installer..."
[System.Console]::Out.Flush()

$pythonUrl = "https://www.python.org/ftp/python/3.12.3/python-3.12.3-amd64.exe"
$installerPath = "$env:TEMP\python-installer.exe"

$ProgressPreference = 'SilentlyContinue'
Add-Type -AssemblyName System.Net.Http

try {
    $client = New-Object System.Net.Http.HttpClient
    $response = $client.GetAsync($pythonUrl, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).Result
    $totalBytes = $response.Content.Headers.ContentLength
    $stream = $response.Content.ReadAsStreamAsync().Result

    Show-DownloadProgress -inputStream $stream -totalBytes $totalBytes -outputPath $installerPath
}
catch {
    Write-Host "`n[FAIL] Unable to download the Python installer. Please try again." -ForegroundColor Red
    exit 1
}

# Install Python silently 
Write-Host "[INFO] Installing Python silently with PATH access..."
Write-Host "[INFO] Installing Python for current user (admin not required)." -ForegroundColor Cyan
try {
    # Install for the current user only, add to PATH and skip test suites
    # The test suite refers to internal Python self-tests, mainly for developers
    Start-Process `
        -FilePath $installerPath `
        -ArgumentList "/quiet", "InstallAllUsers=0", "PrependPath=1", "Include_test=0" `
        -Wait `
        -Verb RunAs

    Write-Host "`n[OK] Python installation completed. Verifying installation..." -ForegroundColor Green
}
catch {
    Write-Host "`n[FAIL] Installer failed or was denied." -ForegroundColor Red
    exit 1
}

# Refresh session PATH again and give some time for system to catch up
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")
Start-Sleep -Seconds 2

# Verifying if Python command is now available and working
Write-Host "`n[INFO] Verifying Python installation..."

# Tried to locate a command named 'python', if not found supresses the error (this is defined by the 
# ErrorAction)
if (Get-Command python -ErrorAction SilentlyContinue) {
    try {
        $version = python --version 2>&1
        if ($version -match "^Python\s+\d+\.\d+") {
            Write-Host "[OK] Python installed: $version" -ForegroundColor Green
        }
        else {
            Write-Host "[FAIL] Installation may have failed. No version detected." -ForegroundColor Red
        }
    }
    catch {
        Write-Host "[FAIL] Failed to verify Python after install." -ForegroundColor Red
    }
}
else {
    Write-Host "[FAIL] Python command not found. Either the installation failed or PATH was not updated." -ForegroundColor Red

    # If still not detected, advise user to restart the terminal
    Write-Host "[WARN] Python might not be available in this terminal yet. Try restarting your shell or opening a new one." -ForegroundColor Yellow
}

# Run a test script to confirm Python is working
Write-Host "`n[INFO] Running test script: hello.py"
$pythonPath = "python"
$helloScript = Join-Path $PSScriptRoot "..\scripts\hello.py"

# Run the Python interpreter (python) and pass hello.py as the script to execute.
# & is the call operator in PowerShell. It tells PowerShell to execute a command.
# Same as : python path\to\hello.py
& $pythonPath $helloScript

# $LASTEXITCODE - holds the exit code of the last native application run.
# python hello.py : the last native application run
# If equal to 0 then success, not equal (ne) then failure
if ($LASTEXITCODE -ne 0) {
    Write-Host "[FAIL] hello.py execution failed." -ForegroundColor Red
    exit 1  # Exit with failure
}
else {
    Write-Host ""
    Write-Host -ForegroundColor Green "[SUCCESS] Python has been successfully installed and verified!"
    Write-Host ""
    
    # Clean up by removing the downloaded installer file
    Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
    exit 0  # Exit with success
}


