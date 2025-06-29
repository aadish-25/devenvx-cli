# MsiExec.exe /X "{GUID}" 
# wrap the {GUID} inside "" and space between X and {GUID}

# ---------------------------------------------------------------------

# No need to clear PATH as uninstalling python takes care of it

Write-Host "`n[INFO] Attempting to remove Python from your system..." -ForegroundColor Cyan

# define registry paths where installed software info is stored
$registryPaths = @(
  "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
  "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
  "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$pythonUninstallEntry = $null

# loop through all registry paths to find a matching python install
foreach ($path in $registryPaths) {
  $items = Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object {
    $_.DisplayName -like "Python*" -and
    $_.Publisher -eq "Python Software Foundation" -and
    $_.UninstallString -match "python-.*\.exe.+/uninstall"
  }

  if ($items) {
    # select the first matching entry to uninstall
    $pythonUninstallEntry = $items | Select-Object -First 1
    break
  }
}

if ($pythonUninstallEntry) {
  $uninstallCmd = $pythonUninstallEntry.UninstallString

  Write-Host "`n[OK] Found Python installation. Removing it now..." -ForegroundColor Green
  Write-Host "`n[INFO] Running Python uninstaller silently..." -ForegroundColor Yellow

  # run the uninstall command silently using cmd
  Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "$uninstallCmd /quiet" -WindowStyle Hidden -Wait

  Write-Host "`n[SUCCESS] Python uninstallation completed." -ForegroundColor Green
}
else {
  # show a warning if python was not found
  Write-Host "`n[WARN] Python does not appear to be installed or was already removed." -ForegroundColor Yellow
  exit 0 
}

# The following comment contains the code that gives the list of entries containing 'python'
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
