# Purpose of Show-DownloadProgress:
# Reads data from a source stream and writes it to a file while displaying a live progress bar with percentage updates.
# Used in DevEnvx to indicate real-time download progress for installers.

function Show-DownloadProgress {
    param (
        # The data source (input stream), total file size in bytes
        # and the target file path where the data will be saved
        [System.IO.Stream]$inputStream,
        [long]$totalBytes,
        [string]$outputPath
    )

    # Opens a new file at the specified path to store the downloaded data.
    # Sets up an 8 KB buffer to read the incoming data in chunks,
    # and initializes a counter to track the total number of bytes downloaded.
    $fileStream = [System.IO.File]::Create($outputPath)
    $buffer = New-Object byte[] 8192
    $totalRead = 0

    # Read the data in chunks from the input stream, write each chunk to the output file,
    # and update the download progress bar in the terminal until the entire file is downloaded.
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

    # Once the download is complete, we closes the file and print a success message to the terminal.
    $fileStream.Close()
    Write-Host ""
    Write-Host ""
    Write-Host "[OK] Installer downloaded successfully"
    Write-Host ""
}

## WHAT THE LOOP DOES:
# The loop keeps running until no more data is available — i.e., when the number of bytes read becomes 0 (download complete).
# $read = reads the file in chunks from the source and stores it in the buffer.
# It starts writing at index 0 and can read up to the size of the buffer (8 KB in this case).
# The if block checks whether any data was actually read.
# This is important because the loop is a do...while loop, which runs at least once — even if there's no data.
# So this check ensures we only write and show progress if data was received.
# The rest of the block writes the chunk to the output file, updates the total downloaded size,