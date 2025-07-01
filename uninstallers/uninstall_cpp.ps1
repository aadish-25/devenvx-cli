# C++ Uninstall Script for DevEnvx
# Removes MSYS2 or MinGW toolchains if found (used by DevEnvx)

# ---------------------------------------------------------------------

Write-Host "`n[INFO] Attempting to uninstall C++ toolchain..." -ForegroundColor Cyan

# Define known C++ toolchains and their install/bin paths
$cppTools = @(
    @{ Name = "MSYS2"; Path = "C:\msys64"; Bin = "C:\msys64\mingw64\bin" },
    @{ Name = "MinGW"; Path = "C:\MinGW"; Bin = "C:\MinGW\bin" },
    @{ Name = "MinGW64"; Path = "C:\MinGW64"; Bin = "C:\MinGW64\bin" }
)

# Flags to track whether anything was found and whether all uninstalls succeeded
$foundAny = $false
$allSuccess = $true

# Print detected installations (MSYS2, MinGW or MinGW64)
foreach ($tool in $cppTools) {
    if (Test-Path $tool.Path) {
        Write-Host "`n[OK] Found $($tool.Name) installation at: $($tool.Path)" -ForegroundColor Green
    }
}

# Uninstall each C++ toolchain
foreach ($tool in $cppTools) {
    if (Test-Path $tool.Path) {
        $foundAny = $true
        Write-Host "[INFO] Removing $($tool.Name)..."

        # Attempt to kill any running processes that might lock the toolchain folder
        # Before deleting the toolchain folder (like C:\msys64), 
        # it tries to find and stop any programs that are currently using it.

        # HOW -> Gets all process, filters those whose path is similar to or inside the tool's path
        # If yes, then try tostop the process
        # All processes are checked one by one
        Get-Process | Where-Object { $_.Path -like "$($tool.Path)*" } | ForEach-Object {
            try {
                Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
            } catch {}
        }
        
        # Try to delete the installation folder (C:\toolFolder for eg. C:\msys64)
        try {
            Remove-Item -Recurse -Force -Path $tool.Path -ErrorAction Stop
            Write-Host "`n[OK] $($tool.Name) successfully removed." -ForegroundColor Green
        }
        catch {
            Write-Host "[FAIL] Failed to delete $($tool.Name) directory." -ForegroundColor Red
            $allSuccess = $false
            continue
        }

        # Clean up PATH variable (User and Machine)
        $scopes = @("User", "Machine")
        foreach ($scope in $scopes) {
            $envPath = [System.Environment]::GetEnvironmentVariable("Path", $scope)
            if ($envPath -match [regex]::Escape($tool.Bin)) {
                $newPath = ($envPath -split ';') -ne $tool.Bin -join ';'
                try {
                    [System.Environment]::SetEnvironmentVariable("Path", $newPath, $scope)
                    Write-Host "[OK] Cleaned $scope PATH for $($tool.Name)" -ForegroundColor DarkGray
                } catch {
                    Write-Host "[WARN] Couldn't clean $scope PATH for $($tool.Name)" -ForegroundColor Yellow
                }
            }
        }
    }
}

# Reporting final status

# No toolchain found i.e MSYS2, MinGW or MinGW64 were not found
if (-not $foundAny) {
    Write-Host "`n[WARN] C++ toolchain does not appear to be installed or was already removed." -ForegroundColor Yellow
    exit 0
}
# Toolchain uninstalled successfully
if ($allSuccess) {
    Write-Host "`n[SUCCESS] C++ toolchain uninstalled successfully." -ForegroundColor Green
    exit 0
}

else {
    Write-Host "`n[FAIL] Some components of the C++ toolchain could not be removed." -ForegroundColor Red
    Write-Host "[HINT] Close all editors and terminals, then try uninstalling again." -ForegroundColor Cyan
    exit 1
}
