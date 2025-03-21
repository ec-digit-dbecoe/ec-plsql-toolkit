param (
    [string]$dir,
    [string]$cmd_id,
    [string]$op,
    [string]$apps_dir
)

# Validate directory
if (-not (Test-Path -Path $dir -PathType Container)) {
    # Silent exit on purpose as this is a normal case
    exit 0
}

# Resolve full directory path
$fullDir = (Resolve-Path $dir).Path

Write-Output "BEGIN"
Write-Output "    NULL;"

# Loop through files in directory
Get-ChildItem -Path $fullDir -File | ForEach-Object {
    $filePath = $_.FullName
    $relativePath = $filePath.Substring($fullDir.Length + 1)

    # Read file content as bytes and normalize line endings (CRLF -> LF)
    $contentBytes = [System.IO.File]::ReadAllBytes($filePath)
    $contentStr = [System.Text.Encoding]::UTF8.GetString($contentBytes) -replace "`r", ""
    $normalizedBytes = [System.Text.Encoding]::UTF8.GetBytes($contentStr)

    # Compute MD5 hash
    $md5 = [System.Security.Cryptography.MD5]::Create()
    $hashBytes = $md5.ComputeHash($normalizedBytes)
    $hashString = ($hashBytes | ForEach-Object { $_.ToString("x2") }) -join ""

    # Output formatted line
    Write-Output "    dbm_utility_krn.output_line(p_cmd_id=>$cmd_id, p_type=>'OUT', p_text=>'$hashString $dir\$relativePath');"
}

# Final parsing and ending statements
Write-Output "    dbm_utility_krn.parse_hashes(p_cmd_id=>$cmd_id, p_op=>'$op', p_apps_dir=>'$apps_dir');"
Write-Output "END;"
Write-Output "/"