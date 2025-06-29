# Default python uninstaller doesnt clean up the PATH, which might lead to unexpected behaviour when we say `where python`
# If you install python and then uninstall from your settings, and then check PATH variables, you will still find its path there
# We aim to fix at least the core uninstallation in this version.

# MsiExec.exe /X "{GUID}" 
# wrap the {GUID} inside "" and space between X and {GUID}

# ---------------------------------------------------------------------

<#
gives the list of entries containing python

Write-Host "`n[INFO] Searching for all Python-related entries in registry..." -ForegroundColor Cyan

$registryPaths = @(
  "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
  "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
  "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

foreach ($path in $registryPaths) {
  Get-ItemProperty $path -ErrorAction SilentlyContinue |
  Where-Object { $_.DisplayName -like "*Python*" } |
  ForEach-Object {
    Write-Host "`n----------------------------------------"
    Write-Host "Display Name    : $($_.DisplayName)"
    Write-Host "Publisher       : $($_.Publisher)"
    Write-Host "Version         : $($_.DisplayVersion)"
    Write-Host "Install Location: $($_.InstallLocation)"
    Write-Host "Uninstall String: $($_.UninstallString)"
  }
}
#>

Write-Host "`n[INFO] Attempting to remove Python from your system..." -ForegroundColor Cyan

$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$pythonUninstallEntry = $null

foreach ($path in $registryPaths) {
    $items = Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object {
        $_.DisplayName -like "Python*" -and
        $_.Publisher -eq "Python Software Foundation" -and
        $_.UninstallString -match "python-.*\.exe.+/uninstall"
    }

    if ($items) {
        $pythonUninstallEntry = $items | Select-Object -First 1
        break
    }
}

if ($pythonUninstallEntry) {
    $uninstallCmd = $pythonUninstallEntry.UninstallString

    Write-Host "`n[OK] Found Python installation. Removing it now..." -ForegroundColor Green
    Write-Host "`n[INFO] Running Python uninstaller silently..." -ForegroundColor Yellow

    Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "$uninstallCmd /quiet" -WindowStyle Hidden -Wait

    Write-Host "`n[SUCCESS] Python uninstallation completed. Python has been successfully removed from your system." -ForegroundColor Green
}
else {
    Write-Host "`n[WARN] Python does not appear to be installed or was already removed." -ForegroundColor Yellow
}
