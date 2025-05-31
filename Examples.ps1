# Example usage of the WebScraper module

# Import the module
Import-Module ./WebScraper.psm1 -Force

# Example 1: Get all data from a webpage
Write-Host "Example 1: Getting all data from example.com" -ForegroundColor Green
try {
    $result = Invoke-WebScraper -Url "https://example.com" -Verbose
    Write-Host "Title: $($result.Title)"
    Write-Host "Status Code: $($result.StatusCode)"
    Write-Host "Content Length: $($result.ContentLength)"
    Write-Host "Number of Links: $($result.Links.Count)"
    Write-Host "Number of Images: $($result.Images.Count)"
    Write-Host "Text Preview: $($result.TextContent.Substring(0, [Math]::Min(200, $result.TextContent.Length)))..."
} catch {
    Write-Warning "Could not access example.com: $($_.Exception.Message)"
}

Write-Host "`n" + "="*50 + "`n"

# Example 2: Get only links from a webpage
Write-Host "Example 2: Getting only links" -ForegroundColor Green
try {
    $links = Invoke-WebScraper -Url "https://example.com" -OutputFormat "Links"
    $links | ForEach-Object { Write-Host "Link: $($_.Text) -> $($_.Href)" }
} catch {
    Write-Warning "Could not get links: $($_.Exception.Message)"
}

Write-Host "`n" + "="*50 + "`n"

# Example 3: Get only text content
Write-Host "Example 3: Getting only text content" -ForegroundColor Green
try {
    $text = Invoke-WebScraper -Url "https://example.com" -OutputFormat "Text"
    Write-Host "Text content: $($text.Substring(0, [Math]::Min(300, $text.Length)))..."
} catch {
    Write-Warning "Could not get text content: $($_.Exception.Message)"
}

Write-Host "`n" + "="*50 + "`n"

# Example 4: Get raw HTML
Write-Host "Example 4: Getting raw HTML" -ForegroundColor Green
try {
    $html = Invoke-WebScraper -Url "https://example.com" -OutputFormat "Raw"
    Write-Host "HTML length: $($html.Length) characters"
    Write-Host "HTML preview: $($html.Substring(0, [Math]::Min(200, $html.Length)))..."
} catch {
    Write-Warning "Could not get raw HTML: $($_.Exception.Message)"
}

Write-Host "`nExamples completed. Note: These examples require internet access to work properly." -ForegroundColor Yellow