# MsiExec.exe /X "{GUID}" 
# wrap the {GUID} inside "" and space between X and {GUID}

# ---------------------------------------------------------------------

Write-Host "`n[INFO] Attempting to remove Java from your system..." -ForegroundColor Cyan

# Define registry paths where installed software info is stored
$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$javaUninstallEntry = $null

# Search through all registry entries for Java-related installations
foreach ($path in $registryPaths) {
    $items = Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object {
        $_.DisplayName -like "*Java*" -and
        $_.UninstallString -match "msiexec\.exe"
    }

    if ($items) {
        $javaUninstallEntry = $items | Select-Object -First 1
        break
    }
}

if ($javaUninstallEntry) {
    $uninstallCmd = $javaUninstallEntry.UninstallString

    Write-Host "`n[INFO] Found uninstall command:" -ForegroundColor Yellow

    if ($uninstallCmd -match "MsiExec\.exe\s+/X\{(.+?)\}") {
        $guid = $matches[1]
        $uninstallCmd = "MsiExec.exe /X `"{$guid}`""
    }

    Write-Host "`n[INFO] Uninstalling Java..." -ForegroundColor Cyan

    # executing uninstall command silently via CMD and check uninstall exit code
    try {
        $process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", $uninstallCmd -Wait -NoNewWindow -PassThru
        $exitCode = $process.ExitCode

        switch ($exitCode) {
            0 {
                Write-Host "`n[SUCCESS] Java has been successfully uninstalled." -ForegroundColor Green
            }
            1602 {
                Write-Host "`n[FAIL] Java uninstaller was cancelled by the user (Exit code: 1602)." -ForegroundColor Red
            }
            default {
                Write-Host "`n[FAIL] Java uninstallation failed with exit code $exitCode." -ForegroundColor Red
            }
        }
        exit 0
    }
    catch {
        Write-Host "`n[FAIL] Java uninstallation encountered an error." -ForegroundColor Red
        exit 0
    }
}
else {
    Write-Host "`n[WARN] Java does not appear to be installed or was already removed." -ForegroundColor Yellow
    exit 0
}
