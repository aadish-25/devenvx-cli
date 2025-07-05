# Java Uninstall Script for DevEnvx

# This script is part of DevEnvx. It silently uninstalls Java from the system
# by searching the Windows Registry for Java installations that were installed
# via MSI installers. Once located, it extracts and formats the uninstall command,
# then executes it in the background using CMD with proper error handling.

# ---------------------------------------------------------------------

Write-Host "`n[INFO] Attempting to remove Java from your system..." -ForegroundColor Cyan

# Define all registry paths that may contain uninstaller entries
$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$javaUninstallEntry = $null

# Search all registry locations for a valid Java uninstall entry
# A valid entry is one where DisplayName contains 'Java' and the UninstallString
# includes 'msiexec.exe', which indicates it was installed using an official MSI-based installer.

# In short – An installed application that mentions ‘Java’ in its name and has a proper 
# MSI-based uninstall path, meaning it came from a trusted Java distribution like Oracle or OpenJDK.

# Loop through each registry path
foreach ($path in $registryPaths) {

    # Retrieve all installed program entries from the current registry path
    $items = Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object {

        # Filter the entries to find a valid Java installation with an MSI-based uninstaller
        $_.DisplayName -like "*Java*" -and
        $_.UninstallString -match "msiexec\.exe"
    }

    if ($items) {
        # select the first matching entry to uninstall and stop checking further
        $javaUninstallEntry = $items | Select-Object -First 1
        break
    }
}

# If a valid entry was found, uninstall it
if ($javaUninstallEntry) {
    $uninstallCmd = $javaUninstallEntry.UninstallString

    Write-Host "`n[INFO] Found uninstall command:" -ForegroundColor Yellow

    # Reformat the uninstall command if needed
    if ($uninstallCmd -match "MsiExec\.exe\s+/X\{(.+?)\}") {
        $guid = $matches[1]
        $uninstallCmd = "MsiExec.exe /X `"{$guid}`""
    }

    Write-Host "`n[INFO] Uninstalling Java..." -ForegroundColor Cyan

    # Runs the uninstall command in a hidden Command Prompt window silently
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
    # Show a warning if valid entry was not found (either not installed or has already been removed)
    Write-Host "`n[WARN] Java does not appear to be installed or was already removed.`n" -ForegroundColor Yellow
    exit 0
}
