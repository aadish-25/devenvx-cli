Write-Output "==> Checking for Java..."

if (Get-Command javac -ErrorAction SilentlyContinue) {
    Write-Output "[OK] Java is already installed."
} else {
    Write-Output "[X] Java is NOT installed."
}
