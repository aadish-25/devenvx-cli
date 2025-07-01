# C++ Uninstall Script for DevEnvx
# Removes MSYS2 or MinGW toolchains if found (used by DevEnvx)
# ---------------------------------------------------------------------

Write-Host "`n[INFO] Attempting to uninstall C++ toolchain..." -ForegroundColor Cyan

$cppTools = @(
    @{ Name = "MSYS2"; Path = "C:\msys64"; Bin = "C:\msys64\mingw64\bin" },
    @{ Name = "MinGW"; Path = "C:\MinGW"; Bin = "C:\MinGW\bin" },
    @{ Name = "MinGW64"; Path = "C:\MinGW64"; Bin = "C:\MinGW64\bin" }
)

$allSuccess = $true
$foundAny = $false

# prints the type of installer found (mingw, mingw64 or msys2)
foreach ($tool in $cppTools) {
    if (Test-Path $tool.Path) {
        Write-Host "`n[OK] Found $($tool.Name) installation at: $($tool.Path)" -ForegroundColor Green
    }
}

# uninstalling all the tools of the cpp toolchain
foreach ($tool in $cppTools) {
    if (Test-Path $tool.Path) {
        $foundAny = $true
        Write-Host "[INFO] Removing $($tool.Name)..."

        try {
            Remove-Item -Recurse -Force -Path $tool.Path
        }
        catch {
            Write-Host "[FAIL] Failed to delete $($tool.Name) directory." -ForegroundColor Red
            $allSuccess = $false
            continue
        }

        $envPath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
        if ($envPath -match [regex]::Escape($tool.Bin)) {
            $newPath = ($envPath -split ';') -ne $tool.Bin -join ';'
            try {
                [System.Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
            }
            catch {
                Write-Host "[WARN] Couldn't clean PATH for $($tool.Name)" -ForegroundColor Yellow
            }
        }
    }
}

if (-not $foundAny) {
    Write-Host "`n[WARN] C++ toolchain does not appear to be installed or was already removed." -ForegroundColor Yellow
    exit 0
}

if ($allSuccess) {
    Write-Host "`n[SUCCESS] C++ toolchain uninstalled successfully." -ForegroundColor Green
    exit 0
}
else {
    Write-Host "`n[FAIL] Some components of the C++ toolchain could not be removed." -ForegroundColor Red
    exit 1
}
