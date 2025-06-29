function Show-DownloadProgress {
    param (
        [System.IO.Stream]$inputStream,
        [long]$totalBytes,
        [string]$outputPath
    )

    $fileStream = [System.IO.File]::Create($outputPath)
    $buffer = New-Object byte[] 8192
    $totalRead = 0

    do {
        $read = $inputStream.Read($buffer, 0, $buffer.Length)
        if ($read -gt 0) {
            $fileStream.Write($buffer, 0, $read)
            $totalRead += $read
            $percent = [math]::Round(($totalRead / $totalBytes) * 100)
            $bar = "#" * ($percent / 2) + "-" * (50 - ($percent / 2))
            Write-Host -NoNewline "`r[$bar] $percent%"
        }
    } while ($read -gt 0)

    $fileStream.Close()
    Write-Host ""
    Write-Host ""
    Write-Host "[OK] Installer downloaded successfully"
    Write-Host ""
}
