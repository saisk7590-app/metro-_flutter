$root = "E:\Sai Kiran\Metro\metro_flutter\lib"
$files = Get-ChildItem -Path $root -Filter *.dart -Recurse

$results = foreach ($f in $files) {
    $lineCount = (Get-Content -Path $f.FullName | Measure-Object -Line).Lines
    $rel = $f.FullName.Substring($root.Length + 1)
    $parts = $rel.Split([System.IO.Path]::DirectorySeparatorChar)
    
    $folder = if ($parts.Length -gt 1) { $parts[0] } else { "root" }
    $subfolder = if ($parts.Length -gt 2) { $parts[1..($parts.Length - 2)] -join "/" } else { "-" }
    
    [PSCustomObject]@{
        FileName = $f.Name
        Folder = $folder
        Subfolder = $subfolder
        Lines = $lineCount
        FullPath = $f.FullName
    }
}

$sorted = $results | Sort-Object -Property Lines -Descending

Write-Output "Total files: $($sorted.Count)"
Write-Output "--- TOP 35 HIGHEST LINES OF CODE ---"
$sorted | Select-Object -First 35 | Format-Table FileName, Folder, Subfolder, Lines -AutoSize
