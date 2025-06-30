<# Steps -
    1. check if java is already installed, if yes then display message else install it
    2. install java (jdk)
    3. run it with silent flags
    4. verify with java -version and javac -version
    5. compile and run the hello.java script to confirm setup
#>

# Import reusable download progress loader
. "$PSScriptRoot\..\cli\utils\showLoader.ps1"

# checking if java is already installed
Write-Host "`n[INFO] Checking if Java is already installed..." 

$javaInstalled = $false
$javacInstalled = $false

try {
    $javaVersion = java -version 2>&1
    if ($javaVersion -match "version\s+`"\d+\.\d+") {
        $javaInstalled = $true
    }
}
catch {}

try {
    $javacVersion = javac --version 2>&1
    if ($javacVersion -match "javac\s+\d+\.\d+") {
        $javacInstalled = $true
    }
}
catch {}

if ($javaInstalled -and $javacInstalled) {
    Write-Host "[SUCCESS] Java (JDK) is already installed." -ForegroundColor Green
    Write-Host ""
    exit 0
}
else {
    Write-Host "[FAIL] Java JDK is not fully installed." -ForegroundColor Red
}

# downloads the Oracle JDK installer (.exe)
Write-Host "`n[INFO] Downloading Oracle Java JDK 21 installer..."
[System.Console]::Out.Flush()

# Oracle JDK 21 LTS (Windows x64)
$javaUrl = "https://download.oracle.com/java/21/latest/jdk-21_windows-x64_bin.exe"
$installerPath = "$env:TEMP\oracle-jdk-installer.exe"

$ProgressPreference = 'SilentlyContinue'
Add-Type -AssemblyName System.Net.Http

$client = New-Object System.Net.Http.HttpClient
$response = $client.GetAsync($javaUrl, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).Result
$totalBytes = $response.Content.Headers.ContentLength
$stream = $response.Content.ReadAsStreamAsync().Result

Show-DownloadProgress -inputStream $stream -totalBytes $totalBytes -outputPath $installerPath

# installing Java from the .exe file downloaded previously
Write-Host "[INFO] Installing Oracle JDK 21 silently..." 
Write-Host "[INFO] This will install system-wide and may prompt for admin rights." -ForegroundColor Cyan

try {
    Start-Process `
        -FilePath $installerPath `
        -ArgumentList "/s" `
        -Wait `
        -Verb RunAs

    Write-Host "`[OK] Java installation completed. Verifying..." -ForegroundColor Green
}
catch {
    Write-Host "[FAIL] Oracle JDK installer failed or was denied." -ForegroundColor Red
    exit 1
}

# update current session PATH to detect new python
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")

# added delay to handle slow registry/ENV propogation
Start-Sleep -Seconds 2


# checking if java is correctly installed by checking java -version and javac -version
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
else{
    Write-Host "[OK] Java installed" -ForegroundColor Green
}

# executing hello.java to test one final time
Write-Host "`n[INFO] Running final Java verification with hello.java"

$javaFile = Join-Path $PSScriptRoot "..\scripts\hello.java"
$javaDir = Split-Path $javaFile

# step1 : compile
Write-Host "[INFO] Step 1: Compiling hello.java"
& javac $javaFile

if ($LASTEXITCODE -ne 0) {
    Write-Host "[FAIL] Compilation failed." -ForegroundColor Red
    exit 1
}

# step1 : run
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

# Final version check for DevEnvx CLI to handle exit
$javaOK = $false
$javacOK = $false

try {
    & java -version > $null 2>&1
    if ($LASTEXITCODE -eq 0) {
        $javaOK = $true
    }
}
catch {}

try {
    & javac -version > $null 2>&1
    if ($LASTEXITCODE -eq 0) {
        $javacOK = $true
    }
}
catch {}

if ($javaOK -and $javacOK) {
    exit 0
}
else {
    exit 1
}

Remove-Item $installerPath -Force
