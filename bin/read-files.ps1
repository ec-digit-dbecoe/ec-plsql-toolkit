# Parameters
param (
    [string]$DirectoryPath,     # Directory Path passed from the batch file
    [string]$Pattern,           # File pattern (e.g., *.txt)
    [string]$CmdId,             # Command ID for dbm_utility_krn.output_line
    [string]$TmpDir,            # Temporary directory for chunk processing (not actually needed here)
    [int]$ChunkSize = 20480     # Chunk size in bytes (default 20KB)
)

Write-Output "BEGIN"

# Resolve DirectoryPath to an absolute path if it's relative
try {
    $AbsoluteDirectoryPath = (Resolve-Path -Path $DirectoryPath).Path
} catch {
    Write-Output "Invalid directory path: $DirectoryPath"
    exit
}

# Get the current working directory
$CWD = (Get-Location).Path

# Debug: Print out the resolved directory path and CWD
#Write-Output "Resolved DirectoryPath: $AbsoluteDirectoryPath"
#Write-Output "Current Working Directory: $CWD"

# Process each file matching the pattern in the resolved directory path
Get-ChildItem -Path $AbsoluteDirectoryPath -Filter $Pattern -Recurse | ForEach-Object {
    $FilePath = $_.FullName

    # Calculate the relative path based on the provided DirectoryPath
    if ($FilePath.StartsWith($AbsoluteDirectoryPath)) {
        $RelativePath = $FilePath.Substring($AbsoluteDirectoryPath.Length).TrimStart('\')
    } else {
        $RelativePath = $FilePath
    }

    # Debug: Check final relative path
    #Write-Output "Final Relative Path: $RelativePath"

    # Output the relative path
    Write-Output "    dbm_utility_krn.output_line(p_cmd_id=>$CmdId, p_type=>'OUT', p_base64=>FALSE, p_text=>'#!${RelativePath}');"

    # Open file stream and initialize chunk counter
    $FileStream = [System.IO.File]::OpenRead($FilePath)
    $ChunkCount = 0

    # Loop to process file in chunks
    while ($true) {
        $Buffer = New-Object byte[] $ChunkSize
        $BytesRead = $FileStream.Read($Buffer, 0, $ChunkSize)
        
        # If no more bytes were read, break out of the loop (end of file)
        if ($BytesRead -eq 0) { break }

        # Trim the buffer if the last chunk is smaller than the ChunkSize
        if ($BytesRead -lt $ChunkSize) {
            $Buffer = $Buffer[0..($BytesRead - 1)]
        }

        # Convert the chunk to base64
        $Base64String = [Convert]::ToBase64String($Buffer)

        # Split the base64 string into chunks of max 64 characters (lines)
        $LineStart = 0
        $OutputLines = "`n"

        while ($LineStart -lt $Base64String.Length) {
            $LineEnd = [Math]::Min($LineStart + 64, $Base64String.Length)
            $Base64Line = $Base64String.Substring($LineStart, $LineEnd - $LineStart)

            # Append this line to the output string (with new line)
            $OutputLines += $Base64Line + "`n"

            # Move to the next 64-character chunk
            $LineStart = $LineEnd
        }

        # Output the base64-encoded chunk (all lines)
        Write-Output "    dbm_utility_krn.output_line(p_cmd_id=>$CmdId, p_type=>'OUT', p_base64=>TRUE, p_chunk=>$ChunkCount, p_text=>'$OutputLines');"

        # Increment chunk count for each processed chunk
        $ChunkCount++
    }

    # Close the file stream after processing
    $FileStream.Close()
}

Write-Output "COMMIT;"
Write-Output "END;"
Write-Output "/"
