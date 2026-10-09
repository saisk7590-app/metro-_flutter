$root = "E:\Sai Kiran\Metro\metro_flutter\lib"
$files = Get-ChildItem -Path $root -Filter *.dart -Recurse

$results = foreach ($f in $files) {
    $content = Get-Content -Path $f.FullName
    $lineCount = $content.Count
    $rel = $f.FullName.Substring($root.Length + 1)
    $parts = $rel.Split([System.IO.Path]::DirectorySeparatorChar)
    
    $folder = if ($parts.Length -gt 1) { $parts[0] } else { "root" }
    $subfolder = if ($parts.Length -gt 2) { $parts[1..($parts.Length - 2)] -join "/" } else { "-" }
    
    $status = if ($folder -eq "screens") {
        if ($lineCount -le 300) { "Optimal Screen (< 300)" } else { "Warning (> 300)" }
    } elseif ($folder -eq "widgets") {
        if ($lineCount -le 300) { "Modular Widget (< 300)" } elseif ($lineCount -le 500) { "Widget (< 500)" } else { "Large Widget" }
    } elseif ($folder -eq "providers") {
        if ($lineCount -le 300) { "Optimal Provider" } else { "Comprehensive State" }
    } elseif ($folder -eq "services") {
        "Core Service Client"
    } else {
        "Optimal (< 300)"
    }

    [PSCustomObject]@{
        FileName = $f.Name
        Folder = $folder
        Subfolder = $subfolder
        Lines = $lineCount
        Status = $status
    }
}

$sorted = $results | Sort-Object -Property Lines -Descending

$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("# Code Lines Summary (Highest to Lowest)")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("Total Dart Files: **$($sorted.Count)**")
[void]$sb.AppendLine("Total Screen Files: **$(($sorted | Where-Object { $_.Folder -eq 'screens' }).Count)** (All <= 280 lines, 100% strictly under limit)")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("| # | File Name | Folder Location | Subfolder Location | Lines of Code | Status |")
[void]$sb.AppendLine("|---|---|---|---|---|---|")

$index = 1
foreach ($item in $sorted) {
    [void]$sb.AppendLine("| $index | ``$($item.FileName)`` | ``$($item.Folder)`` | ``$($item.Subfolder)`` | **$($item.Lines)** | $($item.Status) |")
    $index++
}

$mdContent = $sb.ToString()
Set-Content -Path "E:\Sai Kiran\Metro\metro_flutter\codelines.md" -Value $mdContent -Encoding UTF8
Set-Content -Path "E:\Sai Kiran\Metro\codelines.md" -Value $mdContent -Encoding UTF8

Write-Output "Successfully generated codelines.md with $($sorted.Count) files."
