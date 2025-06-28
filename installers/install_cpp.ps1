Write-Output "==> Checking for C++..."

if (Get-Command g++ -ErrorAction SilentlyContinue) {
    Write-Output "[OK] C++ is already installed."
} else {
    Write-Output "[X] C++ is NOT installed."
}
