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
}
catch {
    Write-Warning "Could not access example.com: $($_.Exception.Message)"
}

Write-Host "`n" + "="*50 + "`n"

# Example 2: Get only links from a webpage
Write-Host "Example 2: Getting only links" -ForegroundColor Green
try {
    $links = Invoke-WebScraper -Url "https://example.com" -OutputFormat "Links"
    $links | ForEach-Object { Write-Host "Link: $($_.Text) -> $($_.Href)" }
}
catch {
    Write-Warning "Could not get links: $($_.Exception.Message)"
}

Write-Host "`n" + "="*50 + "`n"

# Example 3: Get only text content
Write-Host "Example 3: Getting only text content" -ForegroundColor Green
try {
    $text = Invoke-WebScraper -Url "https://example.com" -OutputFormat "Text"
    Write-Host "Text content: $($text.Substring(0, [Math]::Min(300, $text.Length)))..."
}
catch {
    Write-Warning "Could not get text content: $($_.Exception.Message)"
}

Write-Host "`n" + "="*50 + "`n"

# Example 4: Get raw HTML
Write-Host "Example 4: Getting raw HTML" -ForegroundColor Green
try {
    $html = Invoke-WebScraper -Url "https://example.com" -OutputFormat "Raw"
    Write-Host "HTML length: $($html.Length) characters"
    Write-Host "HTML preview: $($html.Substring(0, [Math]::Min(200, $html.Length)))..."
}
catch {
    Write-Warning "Could not get raw HTML: $($_.Exception.Message)"
}

Write-Host "`n" + "="*50 + "`n"

# Example 5: Get tables from a webpage
Write-Host "Example 5: Getting HTML tables" -ForegroundColor Green
try {
    # Wikipedia pages are a good source of tables
    $tables = Invoke-WebScraper -Url "https://en.wikipedia.org/wiki/List_of_presidents_of_the_United_States" -OutputFormat "Tables"
    Write-Host "Found $($tables.Count) tables on the page."
    
    # Display information about the first table
    if ($tables.Count -gt 0) {
        $firstTable = $tables[0]
        Write-Host "Table index: $($firstTable.Index)"
        Write-Host "Table caption: $($firstTable.Caption)"
        Write-Host "Number of headers: $($firstTable.Headers.Count)"
        Write-Host "Number of rows: $($firstTable.RowCount)"
        
        # Display headers
        Write-Host "`nHeaders:" -ForegroundColor Cyan
        $firstTable.Headers | ForEach-Object { Write-Host "- $_" }
        
        # Display first two rows as an example
        Write-Host "`nFirst two rows:" -ForegroundColor Cyan
        if ($firstTable.RowCount -gt 0) {
            $firstTable.Rows | Select-Object -First 2 | Format-Table
        }
    }
}
catch {
    Write-Warning "Could not get tables: $($_.Exception.Message)"
}

Write-Host "`n" + "="*50 + "`n"

# Example 6: Get all data including tables
Write-Host "Example 6: Getting all data including tables" -ForegroundColor Green
try {
    $allData = Invoke-WebScraper -Url "https://en.wikipedia.org/wiki/PowerShell" -Verbose
    Write-Host "Title: $($allData.Title)"
    Write-Host "Number of tables: $($allData.Tables.Count)"
    Write-Host "Number of links: $($allData.Links.Count)"
    Write-Host "Number of images: $($allData.Images.Count)"
}
catch {
    Write-Warning "Could not access Wikipedia: $($_.Exception.Message)"
}

Write-Host "`nExamples completed. Note: These examples require internet access to work properly." -ForegroundColor Yellow