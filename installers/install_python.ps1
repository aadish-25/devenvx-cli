<# Steps - 
    1. check if python is already installed, if yes then display message else install it
    2. install python 
    3. run it with silent flags
    4. verify with python --version
    5. run the hello.py script
#>

# function that shows the progress bar using '#' while installing
function Show-DownloadProgress {
    param (
        [System.IO.Stream]$inputStream,
        [long]$totalBytes,
        [string]$outputPath
    )

    $fileStream = [System.IO.File]::Create($outputPath)
    $buffer = New-Object byte[] 8192
    $totalRead = 0

    do {
        $read = $inputStream.Read($buffer, 0, $buffer.Length)
        if ($read -gt 0) {
            $fileStream.Write($buffer, 0, $read)
            $totalRead += $read
            $percent = [math]::Round(($totalRead / $totalBytes) * 100)
            $bar = "#" * ($percent / 2) + "-" * (50 - ($percent / 2))
            Write-Host -NoNewline "`r[$bar] $percent%"
        }
    } while ($read -gt 0)

    $fileStream.Close()
    Write-Host ""
    Write-Host ""
    Write-Host "[OK] Python installer downloaded successfully"
    Write-Host ""
}

# checking if python is already installed
Write-Host "`n[INFO] Checking if Python is already installed..." 
try {
    $version = python --version 2>&1
    if ($version -match "^Python\s+\d+\.\d+") {
        Write-Host "[SUCCESS] Python is already installed: $version" -ForegroundColor Green
        Write-Host ""
        exit 0
    } else {
        Write-Host "[FAIL] Python is not installed." -ForegroundColor Red
    }
} catch {
    Write-Host "[FAIL] Python is NOT installed." -ForegroundColor Red
}

# downloads the python installer (.exe)
Write-Host "`n[INFO] Downloading Python installer..."
[System.Console]::Out.Flush()

$pythonUrl = "https://www.python.org/ftp/python/3.12.3/python-3.12.3-amd64.exe"
$installerPath = "$env:TEMP\python-installer.exe"

$ProgressPreference = 'SilentlyContinue'
Add-Type -AssemblyName System.Net.Http

$client = New-Object System.Net.Http.HttpClient
$response = $client.GetAsync($pythonUrl, [System.Net.Http.HttpCompletionOption]::ResponseHeadersRead).Result
$totalBytes = $response.Content.Headers.ContentLength
$stream = $response.Content.ReadAsStreamAsync().Result

Show-DownloadProgress -inputStream $stream -totalBytes $totalBytes -outputPath $installerPath

# installing python from the .exe file installed previosuly
Write-Host "`n[INFO] Installing Python silently with PATH access..."
try {
    Start-Process `
        -FilePath $installerPath `
        -ArgumentList "/quiet", "InstallAllUsers=1", "PrependPath=1", "Include_test=0" `
        -Wait `
        -Verb RunAs

    Write-Host "`[OK] Python installation completed. Verifying installation..." -ForegroundColor Green
} catch {
    Write-Host "[FAIL] Installer failed or was denied." -ForegroundColor Red
    exit 1
}

# checking if python is correctly installed by checking python --version
Write-Host "`n[INFO] Verifying Python installation..."
try {
    $version = python --version 2>&1
    if ($version -match "^Python\s+\d+\.\d+") {
        Write-Host "[OK] Python installed: $version" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Installation may have failed. No version detected." -ForegroundColor Red
    }
} catch {
    Write-Host "[FAIL] Failed to verify Python after install." -ForegroundColor Red
}

# executing the hello.py script to test one final time
Write-Host "`n[INFO] Running test script: hello.py..."
$pythonPath = "python"
$helloScript = Join-Path $PSScriptRoot "..\scripts\hello.py"

& $pythonPath $helloScript
if ($LASTEXITCODE -ne 0) {
    Write-Host "[FAIL] hello.py execution failed." -ForegroundColor Red
} else {
    Write-Host ""
    Write-Host -ForegroundColor Green "`[SUCCESS] Python has been successfully installed and verified!"
}

# Final version check for DevEnvx CLI to handle exit
$version = & python --version 2>$null
if ($version) {
    exit 0
} else {
    exit 1
}