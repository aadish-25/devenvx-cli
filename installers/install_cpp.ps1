<# Steps -
    1. check if C++ tools (g++, gcc, gdb) are already installed, if yes then display message else install TDM-GCC
    2. install TDM-GCC (g++, gcc, gdb)
    3. run it with silent flags
    4. verify with g++ --version and gdb --version
    5. compile and run the hello.cpp script to confirm setup
#>

# Import reusable download progress loader
. "$PSScriptRoot\..\cli\utils\showLoader.ps1"

# Refresh PATH from system/user before checking for tools
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" + `
    [System.Environment]::GetEnvironmentVariable("Path", "Machine")

# checking if g++, gcc, gdb are already installed
Write-Host "`n[INFO] Checking if C++ tools are already installed..."

$gppInstalled = $false
$gccInstalled = $false
$gdbInstalled = $false

# check for g++
try {
    & g++ --version > $null 2>&1
    if ($LASTEXITCODE -eq 0) {
        $gppInstalled = $true
    }
}
catch {}

# check for gcc
try {
    & gcc --version > $null 2>&1
    if ($LASTEXITCODE -eq 0) {
        $gccInstalled = $true
    }
}
catch {}

# check for gdb
try {
    & gdb --version > $null 2>&1
    if ($LASTEXITCODE -eq 0) {
        $gdbInstalled = $true
    }
}
catch {}

# if all 3 tools are installed, skip setup
if ($gppInstalled -and $gccInstalled -and $gdbInstalled) {
    Write-Host "[SUCCESS] C++ toolchain (g++, gcc, gdb) is already installed." -ForegroundColor Green
    Write-Host ""
    exit 0
}
else {
    Write-Host "[FAIL] C++ toolchain (g++, gcc, gdb) is not fully installed." -ForegroundColor Red
}

$installDir = "C:\msys64"
$bashPath = Join-Path $installDir "usr\bin\bash.exe"
$skipExtraction = $false

if (Test-Path $bashPath) {
    Write-Host "`n[INFO] MSYS2 already present. Skipping extraction..." -ForegroundColor Green
    $skipExtraction = $true
}

# Check for corrupted MSYS2 install (MSYS2 exists, but toolchain missing)
$msysBinPath = "C:\msys64\mingw64\bin"
$expectedBinaries = @("g++.exe", "gcc.exe", "gdb.exe")
$brokenState = $false

foreach ($binary in $expectedBinaries) {
    if (-not (Test-Path (Join-Path $msysBinPath $binary))) {
        $brokenState = $true
        break
    }
}

if ($skipExtraction -and $brokenState) {
    Write-Host "`n[WARN] MSYS2 exists, but essential toolchain files are missing." -ForegroundColor Yellow
    Write-Host "`n[INFO] Attempting automatic recovery by deleting and reinstalling MSYS2..." -ForegroundColor Cyan

    try {
        Remove-Item -Path $installDir -Recurse -Force -ErrorAction Stop
        Write-Host "[OK] Corrupted MSYS2 removed. Will re-extract fresh copy." -ForegroundColor Green
        $skipExtraction = $false
    }
    catch {
        Write-Host "[FAIL] Could not delete C:\msys64. Please delete manually and retry." -ForegroundColor Red
        exit 1
    }
}


if (-not $skipExtraction) {
    # Step 2 - Downloading and extracting MSYS2 archive
    Write-Host "`n[INFO] Downloading MSYS2 base archive (for MinGW-w64 GCC toolchain, no GUI installer)..." -ForegroundColor Cyan
    [System.Console]::Out.Flush()

    $baseUrl = "https://github.com/msys2/msys2-installer/releases/download/2025-06-22/msys2-base-x86_64-20250622.tar.xz"
    $archivePath = "$env:TEMP\msys2-base.tar.xz"

    $ProgressPreference = 'SilentlyContinue'
    Add-Type -AssemblyName System.Net.Http

    # To handle network download failures
    try {
        $client = New-Object System.Net.Http.HttpClient
        $response = $client.GetAsync($baseUrl, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).Result

        if (-not $response.IsSuccessStatusCode) {
            Write-Host "`n[FAIL] Failed to download MSYS2 archive. HTTP Status: $($response.StatusCode)" -ForegroundColor Red
            exit 1
        }

        $totalBytes = $response.Content.Headers.ContentLength
        $stream = $response.Content.ReadAsStreamAsync().Result

        Show-DownloadProgress -inputStream $stream -totalBytes $totalBytes -outputPath $archivePath
    }
    catch {
        Write-Host "`n[FAIL] Network error while downloading MSYS2. Please check your connection and try again." -ForegroundColor Red
        exit 1
    }


    # Extract archive to C:\ so msys64 lands correctly
    Write-Host "`[INFO] Extracting MSYS2 archive to C:\..."
    if (Test-Path $installDir) {
        Remove-Item -Path $installDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    try {
        tar -xf $archivePath -C "C:\"
    }
    catch {
        Write-Host "`[FAIL] Failed to extract MSYS2 archive." -ForegroundColor Red
        exit 1
    }

    # Clean up archive
    try {
        Remove-Item -Path $archivePath -Force -ErrorAction SilentlyContinue
        Write-Host "`[INFO] Cleaned up temporary archive file." -ForegroundColor DarkGray
    }
    catch {
        Write-Host "[WARN] Failed to delete archive file (may be locked). Skipping..." -ForegroundColor Yellow
    }

    # Verify MSYS2 presence
    if (-not (Test-Path $bashPath)) {
        Write-Host "`n[FAIL] MSYS2 bash.exe not found - extraction failed or archive is corrupted." -ForegroundColor Red
        exit 1
    }

    Write-Host "`n[OK] MSYS2 base extracted successfully." -ForegroundColor Green
}

# Step 3 — Install GCC toolchain via pacman
Write-Host "`n[INFO] Proceeding to initialize and install GCC toolchain..." -ForegroundColor Cyan
[System.Console]::Out.Flush()

$bashPath = "C:\msys64\usr\bin\bash.exe"

# Define bash script to update pacman and install toolchain
$bootstrapScript = @'
pacman --noconfirm -Sy
pacman --noconfirm -S mingw-w64-x86_64-gcc mingw-w64-x86_64-gdb
'@

# Save bash commands to a temporary shell script
$scriptPath = "$env:TEMP\msys2-bootstrap.sh"
$logPath = "$env:TEMP\msys2-bootstrap.log"

Set-Content -Path $scriptPath -Value $bootstrapScript -Encoding ASCII

# Execute the script using MSYS2 bash, hide all output (redirect to file or null)
try {
    & $bashPath --login -c "bash '$scriptPath'" *> $logPath 2>&1
}
catch {
    Write-Host "`n[FAIL] Failed to run MSYS2 bash for toolchain install." -ForegroundColor Red
    exit 1
}

# Clean up temporary script
try {
    Remove-Item $scriptPath -Force -ErrorAction SilentlyContinue
}
catch {
    Write-Host "[WARN] Failed to delete temp bash script. Skipping cleanup..." -ForegroundColor Yellow
}

# Final validation
$gppPath = "C:\msys64\mingw64\bin\g++.exe"
$gccPath = "C:\msys64\mingw64\bin\gcc.exe"
$gdbPath = "C:\msys64\mingw64\bin\gdb.exe"

if ((Test-Path $gppPath) -and (Test-Path $gccPath) -and (Test-Path $gdbPath)) {
    Write-Host "`n[OK] GCC toolchain successfully installed!" -ForegroundColor Green
}
else {
    Write-Host "`n[FAIL] Toolchain installation failed - one or more binaries are missing." -ForegroundColor Red
    Write-Host "`n[INFO] See log: $logPath" -ForegroundColor Yellow
    exit 1
}

# Step 6 — Add GCC toolchain to user's PATH permanently
$mingwBinPath = "C:\msys64\mingw64\bin"
$currentUserPath = [Environment]::GetEnvironmentVariable("Path", "User")

# Simple containment check (case-insensitive)
if ($currentUserPath -notlike "*$mingwBinPath*") {
    $newUserPath = "$currentUserPath;$mingwBinPath"

    try {
        [Environment]::SetEnvironmentVariable("Path", $newUserPath, "User")
        Write-Host "`n[OK] Added GCC toolchain to your user PATH permanently." -ForegroundColor Green
    }
    catch {
        Write-Host "`n[FAIL] Could not update user PATH." -ForegroundColor Red
        Write-Host "[HINT] Manually add '$mingwBinPath' to your system PATH." -ForegroundColor Yellow
    }

    # Update current session PATH (note: IDEs like VS Code may not reflect this immediately)
    try {
        $env:Path = "$mingwBinPath;$env:Path"
        Write-Host "[OK] PATH updated for current terminal session." -ForegroundColor Green
    }
    catch {
        Write-Host "[WARN] Couldn't update current session PATH." -ForegroundColor Yellow
    }
}
else {
    Write-Host "`n[INFO] GCC toolchain is already in your PATH." -ForegroundColor DarkGray
}

# Always display restart advisory
Write-Host "`n[NOTE] If you still face issues using g++, gcc, or gdb," -ForegroundColor Cyan
Write-Host "[NOTE] please restart your terminal or VS Code to ensure PATH changes are applied." -ForegroundColor Cyan

# Step 7 — Verifying C++ toolchain setup with hello.cpp
Write-Host "`n[INFO] Verifying C++ setup with hello.cpp test script..."

$helloCpp = Join-Path $PSScriptRoot "..\scripts\hello.cpp"
$helloExe = Join-Path $PSScriptRoot "..\scripts\hello.exe"

# Step 1: Check if g++ is available
try {
    & g++ --version > $null 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw
    }
}
catch {
    Write-Host "[FAIL] g++ is not available in this terminal. Cannot compile hello.cpp." -ForegroundColor Red
    Write-Host "[HINT] Try restarting your terminal or VS Code if you just installed C++." -ForegroundColor Yellow
    exit 1
}

# Step 2: Compile the hello.cpp file
Write-Host "[INFO] Step 1: Compiling hello.cpp..."
try {
    & g++ $helloCpp -o $helloExe
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[FAIL] Compilation failed. Please check hello.cpp for syntax errors." -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "[FAIL] Unexpected error while compiling hello.cpp." -ForegroundColor Red
    exit 1
}

# Step 3: Run the compiled program
Write-Host "[INFO] Step 2: Running hello.exe..."
try {
    & $helloExe
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n`n[SUCCESS] C++ toolchain has been successfully installed and verified!" -ForegroundColor Green
    }
    else {
        Write-Host "`n`n[FAIL] hello.exe executed but returned an error." -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "`n[FAIL] Could not run hello.exe." -ForegroundColor Red
    exit 1
}

# Remove insaller line needed