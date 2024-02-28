# Define the path to the folder you want to scan
$FolderPath = "C:\Users\olalea\Documents\github\B-devops-infra-db"

# Get all files in the folder and its subfolders
$Files = Get-ChildItem -Path $FolderPath -Recurse -File

# Initialize an empty array to hold results
$Utf16Files = @()

foreach ($File in $Files) {
    try {
        # Open the file with a StreamReader to detect the encoding
        $reader = [System.IO.StreamReader]::new($File.FullName, $true)
        $null = $reader.Read() # Trigger detection
        $encoding = $reader.CurrentEncoding
        $reader.Close()

        # Check if the encoding is UTF-16 LE or BE
        if ($encoding -eq [System.Text.Encoding]::Unicode) {
            $Utf16Files += [PSCustomObject]@{
                File = $File.FullName
                Encoding = 'UTF-16 LE'
            }
        } elseif ($encoding -eq [System.Text.Encoding]::BigEndianUnicode) {
            $Utf16Files += [PSCustomObject]@{
                File = $File.FullName
                Encoding = 'UTF-16 BE'
            }
        }
    } catch {
        Write-Output "Error reading file: $($File.FullName)"
    }
}

# Output the list of UTF-16 encoded files with their encoding
if ($Utf16Files.Count -gt 0) {
    Write-Output "UTF-16 Encoded Files and their Encodings:"
    $Utf16Files | ForEach-Object { Write-Output "$($_.Encoding): $($_.File)" }
} else {
    Write-Output "No UTF-16 encoded files found."
}
