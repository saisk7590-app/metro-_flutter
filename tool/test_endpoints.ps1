[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

Write-Output "=== 1. Testing get-notifications ==="
try {
    $res = Invoke-WebRequest -Uri "https://nxamsdev.winfocus.co.in/NxAmsDevServices/messaging/api/messaging/get-notifications" -Method Post -Body '{"Params":[{"key":"UnitId","value":"0"},{"key":"RoleId","value":"1"}]}' -ContentType "application/json" -UseBasicParsing
    Write-Output "Status: $($res.StatusCode)"
    Write-Output "Body: $($res.Content)"
} catch {
    Write-Output "Error: $_"
    if ($_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        Write-Output "Response: $($reader.ReadToEnd())"
    }
}

Write-Output "=== 2. Testing get-notifications-count ==="
try {
    $res = Invoke-WebRequest -Uri "https://nxamsdev.winfocus.co.in/NxAmsDevServices/messaging/api/messaging/get-notifications-count" -Method Post -Body '{"Params":[{"key":"UserId","value":"1"}]}' -ContentType "application/json" -UseBasicParsing
    Write-Output "Status: $($res.StatusCode)"
    Write-Output "Body: $($res.Content)"
} catch {
    Write-Output "Error: $_"
    if ($_.Exception.Response) {
        $stream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        Write-Output "Response: $($reader.ReadToEnd())"
    }
}

Write-Output "=== 3. Testing get-staff-details ==="
try {
    $res = Invoke-WebRequest -Uri "https://nxamsdev.winfocus.co.in/NxAmsDevServices/adminService/api/Admin/get-staff-details" -Method Post -Body '{"SearchByName":"","SearchByValue":"1"}' -ContentType "application/json" -UseBasicParsing
    Write-Output "Status: $($res.StatusCode)"
    Write-Output "Body: $($res.Content)"
} catch {
    Write-Output "Error: $_"
}
