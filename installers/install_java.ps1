<# Steps -
    1. check if java is already installed, if yes then display message else install it
    2. install java (jdk)
    3. run it with silent flags
    4. verify with java -version and javac -version
    5. compile and run the hello.java script to confirm setup
#>

# Import reusable download progress loader
. "$PSScriptRoot\..\cli\utils\showLoader.ps1"

# Refresh PATH from system/user before checking for tools
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" +
[System.Environment]::GetEnvironmentVariable("Path", "Machine")

# checking if java is already installed
Write-Host "`n[INFO] Checking if Java is already installed..." 

$javaInstalled = $false
$javacInstalled = $false

# running the command : java -version
try {
    $javaVersion = java -version 2>&1
    if ($javaVersion -match "version\s+`"\d+\.\d+") {
        $javaInstalled = $true
    }
}
catch {}

# running the command : javac --version
try {
    $javacVersion = javac --version 2>&1
    if ($javacVersion -match "javac\s+\d+\.\d+") {
        $javacInstalled = $true
    }
}
catch {}

# if both installed then only we cna say Java is installed
if ($javaInstalled -and $javacInstalled) {
    Write-Host "[SUCCESS] Java (JDK) is already installed." -ForegroundColor Green
    Write-Host ""
    exit 0
}
else {
    Write-Host "[FAIL] Java JDK is not fully installed." -ForegroundColor Red
}

# Step 2: Detect broken installation and clean it
$javaInstallRoot = "C:\Program Files\Java"
$foundBroken = $false

if (Test-Path $javaInstallRoot) {
    $jdkDirs = Get-ChildItem $javaInstallRoot -Directory | Where-Object { $_.Name -like "jdk*" }

    foreach ($dir in $jdkDirs) {
        $binPath = Join-Path $dir.FullName "bin"
        $javaExe = Join-Path $binPath "java.exe"
        $javacExe = Join-Path $binPath "javac.exe"

        if (-not (Test-Path $javaExe) -or -not (Test-Path $javacExe)) {
            Write-Host "`n[WARN] JDK folder '$($dir.Name)' exists but required binaries are missing." -ForegroundColor Yellow
            Write-Host "[INFO] Attempting to delete broken JDK installation: $($dir.FullName)" -ForegroundColor Cyan
            try {
                Remove-Item -Path $dir.FullName -Recurse -Force -ErrorAction Stop
                Write-Host "[OK] Broken JDK installation removed." -ForegroundColor Green
                $foundBroken = $true
            }
            catch {
                Write-Host "[FAIL] Could not delete $($dir.FullName). Please delete manually." -ForegroundColor Red
                exit 1
            }
        }
    }

    if ($foundBroken) {
        Start-Sleep -Seconds 1
    }
}

# Step 3: Download Oracle JDK
Write-Host "`n[INFO] Downloading Oracle Java JDK 21 installer..."
[System.Console]::Out.Flush()

$javaUrl = "https://download.oracle.com/java/21/latest/jdk-21_windows-x64_bin.exe"
$installerPath = "$env:TEMP\oracle-jdk-installer.exe"

$ProgressPreference = 'SilentlyContinue'
Add-Type -AssemblyName System.Net.Http

# To handle network download failures
try {
    $client = New-Object System.Net.Http.HttpClient
    $response = $client.GetAsync($javaUrl, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).Result

    if (-not $response.IsSuccessStatusCode) {
        Write-Host "`n[FAIL] Failed to download Java installer. HTTP Status: $($response.StatusCode)" -ForegroundColor Red
        exit 1
    }

    $totalBytes = $response.Content.Headers.ContentLength
    $stream = $response.Content.ReadAsStreamAsync().Result

    Show-DownloadProgress -inputStream $stream -totalBytes $totalBytes -outputPath $installerPath
}
catch {
    Write-Host "`n[FAIL] Network error while downloading Java. Please check your connection and try again." -ForegroundColor Red
    exit 1
}


# Step 4: Install Java silently
Write-Host "[INFO] Installing Oracle JDK 21 silently..."
Write-Host "[INFO] This will install system-wide and may prompt for admin rights." -ForegroundColor Cyan

try {
    Start-Process `
        -FilePath $installerPath `
        -ArgumentList "/s" `
        -Wait `
        -Verb RunAs

    Write-Host "`n[OK] Java installation completed. Verifying..." -ForegroundColor Green
}
catch {
    Write-Host "[FAIL] Oracle JDK installer failed or was denied." -ForegroundColor Red
    exit 1
}

# Step 5: Update session PATH and set JAVA_HOME
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")
Start-Sleep -Seconds 2

Write-Host "`n[INFO] Attempting to set JAVA_HOME..."
$jdkDir = Get-ChildItem $javaInstallRoot -Directory | Where-Object { $_.Name -like "jdk*" } | Sort-Object LastWriteTime -Descending | Select-Object -First 1

if ($jdkDir) {
    $jdkPath = $jdkDir.FullName
    Write-Host "[INFO] Detected JDK path: $jdkPath"

    try {
        [Environment]::SetEnvironmentVariable("JAVA_HOME", $jdkPath, "Machine")
        Write-Host "[OK] JAVA_HOME set system-wide" -ForegroundColor Green
    }
    catch {
        try {
            [Environment]::SetEnvironmentVariable("JAVA_HOME", $jdkPath, "User")
            Write-Host "[OK] JAVA_HOME set for current user" -ForegroundColor Green
        }
        catch {
            Write-Host "[WARN] Failed to set JAVA_HOME." -ForegroundColor Red
        }
    }
}
else {
    Write-Host "[WARN] Could not detect JDK installation directory." -ForegroundColor Yellow
}

# Step 6: Verify installation
Write-Host "`n[INFO] Verifying Java installation..."
$javaOK = $false
$javacOK = $false

try {
    $versionRaw = & java -version 2>&1 | Out-String
    $lines = $versionRaw -split "`n"
    $firstLine = $lines[0] -replace "^\s*java(\.exe)?\s*:\s*", ""
    if ($firstLine -match 'version\s+"(\d+\.\d+.*?)"') {
        Write-Host "[OK] java command available: $firstLine" -ForegroundColor Green
        $javaOK = $true
    }
}
catch {}

try {
    $javacVersion = javac -version 2>&1
    if ($javacVersion -match "javac\s+\d+\.\d+") {
        Write-Host "[OK] javac command available: $javacVersion" -ForegroundColor Green
        $javacOK = $true
    }
}
catch {}

if (-not $javaOK -or -not $javacOK) {
    Write-Host "[WARN] Java may not be fully available in this terminal yet. Try restarting your shell." -ForegroundColor Yellow
}
else {
    Write-Host "[OK] Java installed" -ForegroundColor Green
}

# Step 7: Run hello.java
Write-Host "`n[INFO] Running final Java verification with hello.java"
$javaFile = Join-Path $PSScriptRoot "..\scripts\hello.java"
$javaDir = Split-Path $javaFile

Write-Host "[INFO] Step 1: Compiling hello.java"
& javac $javaFile
if ($LASTEXITCODE -ne 0) {
    Write-Host "[FAIL] Compilation failed." -ForegroundColor Red
    exit 1
}

Write-Host "[INFO] Step 2: Running compiled Java program..."
Push-Location $javaDir
& java hello
Pop-Location

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n[SUCCESS] Java has been successfully installed and verified!" -ForegroundColor Green
}
else {
    Write-Host "[FAIL] hello.java execution failed." -ForegroundColor Red
}

# Step 8: Final check for CLI
$javaOK = $false
$javacOK = $false

try { & java -version > $null 2>&1; if ($LASTEXITCODE -eq 0) { $javaOK = $true } } catch {}
try { & javac -version > $null 2>&1; if ($LASTEXITCODE -eq 0) { $javacOK = $true } } catch {}

if ($javaOK -and $javacOK) {
    exit 0
}
else {
    exit 1
}

Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
