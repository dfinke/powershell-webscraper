# AI PowerShell WebScraper

A simple yet powerful PowerShell web scraper module that fetches and parses web content, returning data in a PowerShell-friendly format.

## Features

- **Easy to use**: Simple function interface with intuitive parameters
- **Multiple output formats**: Extract text, links, images, tables, or get all data at once
- **PowerShell native**: Built using PowerShell's built-in `Invoke-WebRequest` cmdlet
- **Structured output**: Returns well-organized PowerShell objects for easy manipulation
- **Error handling**: Robust error handling with informative messages
- **Verbose support**: Optional verbose output for debugging
- **WhatIf support**: Test functionality without making actual web requests
- **Table extraction**: Extract HTML tables with headers, rows, and captions

## Installation

1. Clone or download this repository
2. Import the module in PowerShell:
   ```powershell
   Import-Module ./WebScraper.psm1
   ```

## Usage

### Basic Usage

```powershell
# Get all data from a webpage
$result = Invoke-WebScraper -Url "https://example.com"

# Access different parts of the scraped data
Write-Host "Page Title: $($result.Title)"
Write-Host "Status Code: $($result.StatusCode)"
Write-Host "Number of Links: $($result.Links.Count)"
Write-Host "Text Preview: $($result.TextContent.Substring(0, 200))..."
```

### Output Formats

```powershell
# Get only text content
$text = Invoke-WebScraper -Url "https://example.com" -OutputFormat "Text"

# Get only links
$links = Invoke-WebScraper -Url "https://example.com" -OutputFormat "Links"

# Get only images
$images = Invoke-WebScraper -Url "https://example.com" -OutputFormat "Images"

# Get only tables
$tables = Invoke-WebScraper -Url "https://example.com" -OutputFormat "Tables"

# Get raw HTML
$html = Invoke-WebScraper -Url "https://example.com" -OutputFormat "Raw"

# Get all data (default)
$allData = Invoke-WebScraper -Url "https://example.com" -OutputFormat "All"
```

### Advanced Usage

```powershell
# Use custom User-Agent
$result = Invoke-WebScraper -Url "https://example.com" -UserAgent "My Custom Bot 1.0"

# Use with verbose output
$result = Invoke-WebScraper -Url "https://example.com" -Verbose

# Test without making actual request
Invoke-WebScraper -Url "https://example.com" -WhatIf
```

## Function Reference

### Invoke-WebScraper

**Synopsis**: A simple PowerShell web scraper that fetches and parses web content.

**Parameters**:
- `Url` (Required): The URL of the web page to scrape
- `OutputFormat` (Optional): Output format - 'Text', 'Links', 'Images', 'Tables', 'All', or 'Raw' (Default: 'All')
- `UserAgent` (Optional): Custom user agent string (Default: 'PowerShell WebScraper 1.0')

**Returns**:
- When `OutputFormat` is 'All': A PSCustomObject with properties:
  - `Url`: The requested URL
  - `Title`: Page title
  - `TextContent`: Clean text content
  - `Links`: Array of link objects with Text, Href, and AbsoluteUri
  - `Images`: Array of image objects with Alt, Src, and AbsoluteUri
  - `Tables`: Array of table objects (see Tables format below)
  - `StatusCode`: HTTP status code
  - `ContentLength`: Content length in characters
  - `LastModified`: Last modified date from headers
  - `ContentType`: Content type from headers

- When `OutputFormat` is 'Text': Clean text content as string
- When `OutputFormat` is 'Links': Array of link objects
- When `OutputFormat` is 'Images': Array of image objects
- When `OutputFormat` is 'Tables': Array of table objects with properties:
  - `Index`: The position of the table on the page (0-based)
  - `Caption`: The table caption (if available)
  - `Headers`: Array of header column names
  - `Rows`: Array of row data objects or arrays
  - `RowCount`: Number of rows in the table
- When `OutputFormat` is 'Raw': Raw HTML content as string

## Examples

See `Examples.ps1` for comprehensive usage examples.

Run the examples:
```powershell
.\Examples.ps1
```

## Testing

Run the test script to validate the module:
```powershell
.\Test-WebScraper.ps1
```

## Requirements

- PowerShell 5.1 or later
- Internet connectivity for web scraping
- No external dependencies required

## Error Handling

The function includes comprehensive error handling:
- Network connectivity issues
- Invalid URLs
- HTTP errors
- Parsing errors

All errors are returned as PowerShell error objects with descriptive messages.

## Limitations

- Requires internet connectivity to access external websites
- Does not handle JavaScript-rendered content (only static HTML)
- Rate limiting should be implemented by the user for multiple requests
- Some websites may block requests from PowerShell User-Agent

## Contributing

Feel free to submit issues, feature requests, or pull requests to improve this web scraper.

## License

This project is open source. Feel free to use and modify as needed.