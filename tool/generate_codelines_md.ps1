$root = "E:\Sai Kiran\Metro\metro_flutter\lib"
$files = Get-ChildItem -Path $root -Filter *.dart -Recurse

$results = foreach ($f in $files) {
    $lineCount = [System.IO.File]::ReadAllLines($f.FullName).Length
    $rel = $f.FullName.Substring($root.Length + 1)
    $parts = $rel.Split([System.IO.Path]::DirectorySeparatorChar)
    
    $folder = if ($parts.Length -gt 1) { $parts[0] } else { "root" }
    $subfolder = if ($parts.Length -gt 2) { $parts[1..($parts.Length - 2)] -join "/" } else { "-" }
    
    # Categorization and line rules
    $category = ""
    $status = ""
    $isWarning = $false

    if ($folder -eq "screens") {
        $category = "Screens"
        if ($lineCount -le 300) {
            $status = "Optimal Screen (<= 300)"
        } else {
            $status = "Warning (> 300)"
            $isWarning = $true
        }
    } elseif ($folder -eq "widgets") {
        $category = "Widgets"
        if ($lineCount -le 300) {
            $status = "Modular Widget (< 300)"
        } elseif ($lineCount -le 500) {
            $status = "Widget (< 500)"
        } elseif ($lineCount -le 700) {
            $status = "Optimal Widget (<= 700)"
        } else {
            $status = "Warning (> 700)"
            $isWarning = $true
        }
    } elseif ($folder -in @("services", "repositories") -or $f.Name -like "http_client_runner*") {
        $category = "Network & APIs"
        if ($folder -eq "services") {
            if ($lineCount -le 400) {
                $status = "Optimal Service (<= 400)"
            } elseif ($lineCount -le 500) {
                $status = "Acceptable Service (<= 500)"
            } else {
                $status = "Warning (> 500)"
                $isWarning = $true
            }
        } elseif ($folder -eq "repositories") {
            if ($lineCount -le 200) {
                $status = "Optimal Repository (<= 200)"
            } else {
                $status = "Warning (> 200)"
                $isWarning = $true
            }
        } else {
            $status = "HTTP Client Runner"
        }
    } elseif ($folder -eq "providers") {
        $category = "Providers"
        if ($lineCount -le 400) {
            $status = "Optimal Provider (<= 400)"
        } elseif ($lineCount -le 500) {
            $status = "Acceptable Provider (<= 500)"
        } else {
            $status = "Warning (> 500)"
            $isWarning = $true
        }
    } elseif ($folder -in @("models", "data")) {
        $category = "Models & Data"
        if ($lineCount -le 350) {
            $status = if ($folder -eq "models") { "Optimal Model (<= 350)" } else { "Static Data (<= 350)" }
        } else {
            $status = "Warning (> 350)"
            $isWarning = $true
        }
    } else {
        $category = "Architecture & Utilities"
        if ($lineCount -le 250) {
            $status = if ($folder -eq "theme") {
                "Theme System (<= 250)"
            } elseif ($folder -eq "navigation") {
                "Navigation (<= 250)"
            } elseif ($folder -eq "constants") {
                "Constants (<= 250)"
            } elseif ($folder -eq "utils") {
                "Utility (<= 250)"
            } else {
                "App Entrypoint (<= 250)"
            }
        } else {
            $status = "Warning (> 250)"
            $isWarning = $true
        }
    }

    [PSCustomObject]@{
        FileName  = $f.Name
        Folder    = $folder
        Subfolder = $subfolder
        Category  = $category
        Lines     = $lineCount
        Status    = $status
        IsWarning = $isWarning
    }
}

$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("# Code Lines Summary by Category")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("> **Note**: This file is maintained inside ``metro_flutter/codelines.md`` as the single source of truth for code line metrics and refactoring targets.")
[void]$sb.AppendLine("")

$totalFiles = $results.Count
$screens = $results | Where-Object { $_.Category -eq 'Screens' } | Sort-Object -Property Lines -Descending
$widgets = $results | Where-Object { $_.Category -eq 'Widgets' } | Sort-Object -Property Lines -Descending
$network = $results | Where-Object { $_.Category -eq 'Network & APIs' } | Sort-Object -Property Lines -Descending
$providers = $results | Where-Object { $_.Category -eq 'Providers' } | Sort-Object -Property Lines -Descending
$models = $results | Where-Object { $_.Category -eq 'Models & Data' } | Sort-Object -Property Lines -Descending
$arch = $results | Where-Object { $_.Category -eq 'Architecture & Utilities' } | Sort-Object -Property Lines -Descending

$screenWarnings = @($screens | Where-Object { $_.IsWarning }).Count
$widgetWarnings = @($widgets | Where-Object { $_.IsWarning }).Count
$networkWarnings = @($network | Where-Object { $_.IsWarning }).Count
$providerWarnings = @($providers | Where-Object { $_.IsWarning }).Count
$modelWarnings = @($models | Where-Object { $_.IsWarning }).Count
$archWarnings = @($arch | Where-Object { $_.IsWarning }).Count

[void]$sb.AppendLine("### Overview Metrics")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("- **Total Dart Files**: **$totalFiles**")
[void]$sb.AppendLine("- **Screens (Rule: <= 300 lines)**: **$($screens.Count)** files ($($screens.Count - $screenWarnings)/$($screens.Count) passing, $screenWarnings warning)")
[void]$sb.AppendLine("- **Widgets (Rule: <= 700 lines)**: **$($widgets.Count)** files ($($widgets.Count - $widgetWarnings)/$($widgets.Count) passing, $widgetWarnings warning)")
[void]$sb.AppendLine("- **Network, Services & Repositories (Services <= 500, Repos <= 200)**: **$($network.Count)** files ($($network.Count - $networkWarnings)/$($network.Count) passing, $networkWarnings warning)")
[void]$sb.AppendLine("- **Providers & State Management (Rule: <= 500 lines)**: **$($providers.Count)** files ($($providers.Count - $providerWarnings)/$($providers.Count) passing, $providerWarnings warning)")
[void]$sb.AppendLine("- **Models & Data (Rule: <= 350 lines)**: **$($models.Count)** files ($($models.Count - $modelWarnings)/$($models.Count) passing, $modelWarnings warning)")
[void]$sb.AppendLine("- **Architecture, Theme & Utilities (Rule: <= 250 lines)**: **$($arch.Count)** files ($($arch.Count - $archWarnings)/$($arch.Count) passing, $archWarnings warning)")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("---")
[void]$sb.AppendLine("")

function Append-CategoryTable($title, $rule, $items) {
    [void]$sb.AppendLine("## $title")
    if ($rule) {
        [void]$sb.AppendLine("*Target Rule: $rule*")
    }
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("| # | File Name | Folder / Subfolder | Lines of Code | Status |")
    [void]$sb.AppendLine("|---|---|---|---|---|")
    
    $idx = 1
    foreach ($item in $items) {
        $location = if ($item.Subfolder -ne "-") { "$($item.Folder)/$($item.Subfolder)" } else { "$($item.Folder)" }
        [void]$sb.AppendLine("| $idx | ``$($item.FileName)`` | ``$location`` | **$($item.Lines)** | $($item.Status) |")
        $idx++
    }
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("---")
    [void]$sb.AppendLine("")
}

Append-CategoryTable "1. Screens" "All screen files strictly <= 300 lines" $screens
Append-CategoryTable "2. Widgets" "All widget files strictly <= 700 lines (target <= 500)" $widgets
Append-CategoryTable "3. Network, Services & Repositories" "Services <= 500 lines (target <= 400), Repositories <= 200 lines" $network
Append-CategoryTable "4. Providers & State Management" "State management & ChangeNotifier strictly <= 500 lines (target <= 400)" $providers
Append-CategoryTable "5. Models & Data" "DTOs, models & static data schemas strictly <= 350 lines" $models
Append-CategoryTable "6. Architecture, Theme & Utilities" "Theme, navigation, constants & helpers strictly <= 250 lines" $arch

$mdContent = $sb.ToString()
Set-Content -Path "E:\Sai Kiran\Metro\metro_flutter\codelines.md" -Value $mdContent -Encoding UTF8

Write-Output "Successfully generated categorical codelines.md with $totalFiles files in metro_flutter/codelines.md."
