# Parameters
param (
    [string]$FilePath,         # Full path to the file
    [string]$CmdId,            # Command ID for dbm_utility_krn.output_line
    [string]$TmpDir,           # Temporary directory for chunk processing
    [int]$ChunkSize = 20480    # Chunk size in bytes (default 20KB)
)

Write-Output "BEGIN"

# Output the file path as relative, without encoding
$RelativePath = $FilePath
Write-Output "    dbm_utility_krn.output_line(p_cmd_id=>$CmdId, p_type=>'OUT', p_base64=>FALSE, p_text=>'#!$RelativePath');"

# Open file stream for reading
$FileStream = [System.IO.File]::OpenRead($FilePath)
$ChunkCount = 0

try {
    while ($true) {
        # Read a chunk of data
        $Buffer = New-Object byte[] $ChunkSize
        $BytesRead = $FileStream.Read($Buffer, 0, $ChunkSize)

        # If no more bytes were read, we have reached the end of the file
        if ($BytesRead -eq 0) { break }

        # Trim the buffer to actual bytes read if it's less than ChunkSize
        if ($BytesRead -lt $ChunkSize) {
            $Buffer = $Buffer[0..($BytesRead - 1)]
        }

        # Encode the chunk in base64
        $Base64String = [Convert]::ToBase64String($Buffer)

        # Split the base64 string into lines of 64 characters
        $LineStart = 0
        $OutputLines = "`n"  # Collect all 64-character lines

        while ($LineStart -lt $Base64String.Length) {
            $LineEnd = [Math]::Min($LineStart + 64, $Base64String.Length)
            $Base64Line = $Base64String.Substring($LineStart, $LineEnd - $LineStart)

            # Append this line to the output string with newline
            $OutputLines += $Base64Line + "`n"
            $LineStart = $LineEnd
        }

        # Output the base64-encoded chunk, split into 64-character lines
        Write-Output "    dbm_utility_krn.output_line(p_cmd_id=>$CmdId, p_type=>'OUT', p_base64=>TRUE, p_chunk=>$ChunkCount, p_text=>'$OutputLines');"

        # Increment the chunk counter
        $ChunkCount++
    }
} finally {
    # Ensure the file stream is closed
    $FileStream.Close()
}

Write-Output "COMMIT;"
Write-Output "END;"
Write-Output "/"
