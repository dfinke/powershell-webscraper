# Quick Start Demo for WebScraper Module

Write-Host "PowerShell WebScraper - Quick Start Demo" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan

# Import the module
Write-Host "`nImporting WebScraper module..." -ForegroundColor Yellow
Import-Module ./WebScraper.psm1 -Force

# Show available function
Write-Host "`nAvailable functions:" -ForegroundColor Yellow
Get-Command -Module WebScraper

# Show help
Write-Host "`nFunction help:" -ForegroundColor Yellow
Get-Help Invoke-WebScraper -Parameter *

Write-Host "`nQuick usage examples:" -ForegroundColor Yellow
Write-Host "# Get all data from a webpage:"
Write-Host 'Invoke-WebScraper -Url "https://example.com"' -ForegroundColor Green

Write-Host "`n# Get only text content:"
Write-Host 'Invoke-WebScraper -Url "https://example.com" -OutputFormat "Text"' -ForegroundColor Green

Write-Host "`n# Get only links:"
Write-Host 'Invoke-WebScraper -Url "https://example.com" -OutputFormat "Links"' -ForegroundColor Green

Write-Host "`n# Get tables from the page:"
Write-Host 'Invoke-WebScraper -Url "https://en.wikipedia.org/wiki/List_of_presidents_of_the_United_States" -OutputFormat "Tables"' -ForegroundColor Green

Write-Host "`n# Test without making request:"
Write-Host 'Invoke-WebScraper -Url "https://example.com" -WhatIf' -ForegroundColor Green

Write-Host "`nFor more examples, run: .\Examples.ps1" -ForegroundColor Cyan
Write-Host "To test the module, run: .\Test-WebScraper.ps1" -ForegroundColor Cyan

Write-Host "`nModule ready to use! 🚀" -ForegroundColor Green