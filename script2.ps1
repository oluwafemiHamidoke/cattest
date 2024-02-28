# Define the path to the folder you want to scan
$FolderPath = "C:\Users\olalea\Documents\github\B-devops-infra-db"

# Get all files in the folder and its subfolders
$Files = Get-ChildItem -Path $FolderPath -Recurse -File

# List to hold paths of UTF-16 encoded files
$Utf16Files = @()

foreach ($File in $Files) {
    try {
        $reader = [System.IO.StreamReader]::new($File.FullName, $true)
        $null = $reader.Read() # Trigger detection
        $encoding = $reader.CurrentEncoding
        $reader.Close()

        # Check if the encoding is UTF-16 LE or BE
        if ($encoding -eq [System.Text.Encoding]::Unicode -or $encoding -eq [System.Text.Encoding]::BigEndianUnicode) {
            $Utf16Files += $File.FullName
        }
    } catch {
        Write-Output "Error reading file: $($File.FullName)"
    }
}

# Output the list of UTF-16 encoded files
if ($Utf16Files.Count -gt 0) {
    Write-Output "UTF-16 Encoded Files:"
    $Utf16Files | ForEach-Object { Write-Output $_ }
} else {
    Write-Output "No UTF-16 encoded files found."
}
