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
    $javacVersion = javac -version 2>&1
    if ($javacVersion -match "javac\s+\d+\.\d+") {
        $javacInstalled = $true
    }
}
catch {}

if ($javaInstalled -and $javacInstalled) {
    Write-Host "[SUCCESS] Java (JDK) is already installed." -ForegroundColor Green
    Write-Host ""
    exit 0
} else {
    Write-Host "[FAIL] Java JDK is not fully installed." -ForegroundColor Red
}
