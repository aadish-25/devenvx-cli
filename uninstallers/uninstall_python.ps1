# Python Uninstall Script for DevEnvx

# This script is part of DevEnvx. It silently uninstalls Python from the system
# if it was installed via the official Python.org installer. It locates the uninstaller
# via Windows registry and executes it in the background.

# ---------------------------------------------------------------------

# No need to clear PATH as uninstalling python takes care of it

Write-Host "`n[INFO] Attempting to remove Python from your system..." -ForegroundColor Cyan

# Define all registry paths that may contain uninstaller entries
$registryPaths = @(
  "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
  "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
  "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$pythonUninstallEntry = $null

# Search all registry locations for a valid Python uninstall entry
# # A valid entry is one where DisplayName has 'Python', Publisher is 'Python Software Foundation'
# which means it was officially installed via python.org's installer and the UninstallString
# that uses the standard Python installer filename.

# In short - An installed application that starts with ‘Python’, was published by the Python 
# Software Foundation, and has an official uninstaller path.

# Loop through each registry path
foreach ($path in $registryPaths) {

  # Retrieve all installed program entries from the current registry path
  $items = Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object {

    # Filter the entries to find the correct Python installer
    $_.DisplayName -like "Python*" -and
    $_.Publisher -eq "Python Software Foundation" -and
    $_.UninstallString -match "python-.*\.exe.+/uninstall"
  }
  
  if ($items) {
    # select the first matching entry to uninstall and stop checking further
    $pythonUninstallEntry = $items | Select-Object -First 1
    break
  }
}

# If a valid entry was found, uninstall it
if ($pythonUninstallEntry) {
  $uninstallCmd = $pythonUninstallEntry.UninstallString

  Write-Host "`n[OK] Found Python installation. Removing it now..." -ForegroundColor Green
  Write-Host "`n[INFO] Running Python uninstaller silently..." -ForegroundColor Yellow

  # Runs the uninstall command in a hidden Command Prompt window silently
  Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "$uninstallCmd /quiet" -WindowStyle Hidden -Wait

  Write-Host "`n[SUCCESS] Python uninstallation completed." -ForegroundColor Green
}
else {
  # Show a warning if valid entry was not found (either not installed or has already been removed)
  Write-Host "`n[WARN] Python does not appear to be installed or was already removed.`n" -ForegroundColor Yellow
  exit 0 
}

# The following comment contains the code that gives the list of entries containing 'python'
# Feel free to uncomment and check all the processes whose DisplayName has 'Python'
# These are the process before we filter out on the basis of Publisher and UninstallString

<#
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
