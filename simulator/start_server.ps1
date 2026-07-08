$port = 8080
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
try {
    $listener.Start()
    Write-Host "Server started at http://localhost:$port/"
} catch {
    Write-Host "Failed to start listener: $_"
    exit 1
}

$localPath = $PSScriptRoot

# Clean cleanups on script abort
Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
    $listener.Stop()
    Write-Host "Server stopped."
}

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        $url = $request.Url.LocalPath
        if ($url -eq "/") { $url = "/index.html" }
        
        # Replace forward slashes with backslashes for Join-Path
        $relPath = $url.TrimStart('/')
        $filePath = [System.IO.Path]::Combine($localPath, $relPath)
        
        if (Test-Path $filePath -PathType Leaf) {
            $bytes = [System.IO.File]::ReadAllBytes($filePath)
            
            # Mime type check
            if ($url.EndsWith(".html")) { $response.ContentType = "text/html" }
            elseif ($url.EndsWith(".css")) { $response.ContentType = "text/css" }
            elseif ($url.EndsWith(".js")) { $response.ContentType = "application/javascript" }
            elseif ($url.EndsWith(".jpg") -or $url.EndsWith(".jpeg")) { $response.ContentType = "image/jpeg" }
            elseif ($url.EndsWith(".png")) { $response.ContentType = "image/png" }
            
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
            $err = [System.Text.Encoding]::UTF8.GetBytes("File Not Found: $url")
            $response.OutputStream.Write($err, 0, $err.Length)
        }
        $response.OutputStream.Close()
    } catch {
        # Keep serving even if request errored
    }
}
