# Define the path to the folder you want to check
$FolderPath = "C:\Users\olalea\Documents\github\B-devops-infra-db"

# Get all files in the folder and subfolders
$Files = Get-ChildItem -Path $FolderPath -Recurse -File

# List to hold files that are not UTF-8 encoded
$NonUtf8Files = @()

foreach ($File in $Files) {
    try {
        # Attempt to auto-detect encoding
        $reader = [System.IO.StreamReader]::new($File.FullName, $true)
        $null = $reader.Read() # Trigger detection
        $encoding = $reader.CurrentEncoding
        $reader.Close()

        # Check if the encoding is not UTF-8 (without BOM, UTF-8 BOM is identified differently)
        if ($encoding -ne [System.Text.Encoding]::UTF8 -and $encoding -ne [System.Text.UTF8Encoding]::new($true)) {
            $NonUtf8Files += [PSCustomObject]@{
                Path = $File.FullName
                Encoding = $encoding.EncodingName
            }
        }
    } catch {
        Write-Output "Error reading file: $File.FullName"
    }
}

# Output the list of non-UTF-8 encoded files with their encoding
$NonUtf8Files | ForEach-Object { Write-Output "$($_.Path) - $($_.Encoding)" }
