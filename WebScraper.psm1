function Invoke-WebScraper {
    <#
    .SYNOPSIS
    A simple PowerShell web scraper that fetches and parses web content.
    
    .DESCRIPTION
    This function takes a URL, fetches the web page content, and returns the data in a usable PowerShell format.
    It can extract text content, links, images, and other HTML elements.
    
    .PARAMETER Url
    The URL of the web page to scrape.
      .PARAMETER OutputFormat
    The format to return the data in. Options: 'Text', 'Links', 'Images', 'Tables', 'All', 'Raw'
    Default is 'All' which returns a structured object with multiple properties.
    
    .PARAMETER UserAgent
    Optional user agent string to use for the web request.
    
    .EXAMPLE
    Invoke-WebScraper -Url "https://example.com"
    Returns all extracted data from the page.
    
    .EXAMPLE
    Invoke-WebScraper -Url "https://example.com" -OutputFormat "Links"
    Returns only the links found on the page.
      .EXAMPLE
    Invoke-WebScraper -Url "https://example.com" -OutputFormat "Text"
    Returns only the text content of the page.
    
    .EXAMPLE
    Invoke-WebScraper -Url "https://example.com" -OutputFormat "Tables"
    Returns only the tables found on the page.
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Url,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Text', 'Links', 'Images', 'Tables', 'All', 'Raw')]
        [string]$OutputFormat = 'All',
        
        [Parameter(Mandatory = $false)]
        [string]$UserAgent = 'PowerShell WebScraper 1.0'
    )
    
    try {
        # Check if this is a WhatIf scenario
        if ($PSCmdlet.ShouldProcess($Url, "Scrape web content")) {
            # Fetch the web page
            Write-Verbose "Fetching content from: $Url"
            $webRequest = Invoke-WebRequest -Uri $Url -UserAgent $UserAgent -ErrorAction Stop
            Write-Verbose "Content retrieved successfully. Status code: $($webRequest.StatusCode)"
            
            # Parse the HTML content
            $htmlContent = $webRequest.Content
            Write-Verbose "HTML content length: $($htmlContent.Length) characters"
            
            # Extract different types of content based on output format
            switch ($OutputFormat) {
                'Raw' {
                    return $htmlContent
                }
                'Text' {
                    return Get-TextContent -HtmlContent $htmlContent
                }
                'Links' {
                    return Get-Links -WebRequest $webRequest
                }
                'Images' {
                    return Get-Images -WebRequest $webRequest
                }
                'Tables' {
                    return Get-Tables -WebRequest $webRequest -HtmlContent $htmlContent
                }
                'All' {
                    $result = [PSCustomObject]@{
                        Url           = $Url
                        Title         = Get-PageTitle -HtmlContent $htmlContent
                        TextContent   = Get-TextContent -HtmlContent $htmlContent
                        Links         = Get-Links -WebRequest $webRequest
                        Images        = Get-Images -WebRequest $webRequest
                        Tables        = Get-Tables -WebRequest $webRequest -HtmlContent $htmlContent
                        StatusCode    = $webRequest.StatusCode
                        ContentLength = $htmlContent.Length
                        LastModified  = $webRequest.Headers['Last-Modified']
                        ContentType   = $webRequest.Headers['Content-Type']
                    }
                    return $result
                }
            }
        }
        else {
            Write-Host "Would scrape content from: $Url" -ForegroundColor Yellow
            return $null
        }
    }
    catch {
        Write-Error "Failed to scrape URL '$Url': $($_.Exception.Message)"
        return $null
    }
}

function Get-PageTitle {
    param([string]$HtmlContent)
    
    if ($HtmlContent -match '<title[^>]*>([^<]+)</title>') {
        return $matches[1].Trim()
    }
    return $null
}

function Get-TextContent {
    param([string]$HtmlContent)
    
    # Remove script and style elements
    $cleanHtml = $HtmlContent -replace '<script[^>]*>.*?</script>', '' -replace '<style[^>]*>.*?</style>', ''
    
    # Remove HTML tags
    $textContent = $cleanHtml -replace '<[^>]+>', ' '
    
    # Clean up whitespace
    $textContent = $textContent -replace '\s+', ' '
    $textContent = $textContent.Trim()
    
    return $textContent
}

function Get-Links {
    param($WebRequest)
    
    $links = @()
    
    # Extract links using the parsed links property if available
    if ($WebRequest.Links) {
        foreach ($link in $WebRequest.Links) {
            $linkObj = [PSCustomObject]@{
                Text        = $link.innerText
                Href        = $link.href
                AbsoluteUri = if ($link.href -match '^https?://') { $link.href } else { 
                    try { 
                        $uri = New-Object System.Uri([System.Uri]$WebRequest.BaseResponse.ResponseUri, $link.href)
                        $uri.ToString()
                    }
                    catch { 
                        $link.href 
                    }
                }
            }
            $links += $linkObj
        }
    }
    
    return $links
}

function Get-Images {
    param($WebRequest)
    
    $images = @()
    
    # Extract images using the parsed images property if available
    if ($WebRequest.Images) {
        foreach ($image in $WebRequest.Images) {
            $imageObj = [PSCustomObject]@{
                Alt         = $image.alt
                Src         = $image.src
                AbsoluteUri = if ($image.src -match '^https?://') { $image.src } else { 
                    try { 
                        $uri = New-Object System.Uri([System.Uri]$WebRequest.BaseResponse.ResponseUri, $image.src)
                        $uri.ToString()
                    }
                    catch { 
                        $image.src 
                    }
                }
            }
            $images += $imageObj
        }
    }
    
    return $images
}

function Get-Tables {
    param(
        $WebRequest,
        [string]$HtmlContent
    )
    
    $tables = @()
    
    # First check if we can access ParsedHtml (this doesn't work in PowerShell Core)
    try {
        if ($WebRequest.ParsedHtml -and $null -ne $WebRequest.ParsedHtml.getElementsByTagName('table')) {
            Write-Verbose "Using ParsedHtml method to extract tables"
            $htmlTables = $WebRequest.ParsedHtml.getElementsByTagName('table')
            
            for ($i = 0; $i -lt $htmlTables.length; $i++) {
                $table = $htmlTables.item($i)
                $tableData = ConvertTo-TableObject -HtmlTable $table -TableIndex $i
                $tables += $tableData
            }
            return $tables
        }
    }
    catch {
        Write-Verbose "ParsedHtml method failed, falling back to alternative methods"
    }

    # If we're here, ParsedHtml didn't work or wasn't available
    # Try using the newer HTML parser in PowerShell 6+ if available
    if ($PSVersionTable.PSVersion.Major -ge 6) {
        try {
            Write-Verbose "Using PowerShell Core HTML parsing method"
            $htmlTables = $WebRequest.SelectNodes('//table')
            
            if ($null -ne $htmlTables -and $htmlTables.Count -gt 0) {
                for ($i = 0; $i -lt $htmlTables.Count; $i++) {
                    $tableHtml = $htmlTables[$i].OuterHTML
                    $tableData = ConvertTo-TableObjectFromHtml -HtmlTable $tableHtml -TableIndex $i
                    $tables += $tableData
                }
                return $tables
            }
        }
        catch {
            Write-Verbose "PowerShell Core parsing method failed: $($_.Exception.Message)"
        }
    }

    # As a last resort, use regex extraction
    Write-Verbose "Using regex-based extraction method"
    try {
        # More robust regex pattern to match tables
        $regex = [regex]'(?s)<table\b[^>]*>(.*?)</table>'
        $tableMatches = $regex.Matches($HtmlContent)
        
        if ($tableMatches.Count -gt 0) {
            Write-Verbose "Found $($tableMatches.Count) tables using regex"
            for ($i = 0; $i -lt $tableMatches.Count; $i++) {
                $tableHtml = $tableMatches[$i].Value
                $tableData = ConvertTo-TableObjectFromHtml -HtmlTable $tableHtml -TableIndex $i
                $tables += $tableData
            }
        }
        else {
            Write-Verbose "No tables found using regex pattern"
        }
    }
    catch {
        Write-Verbose "Regex extraction failed: $($_.Exception.Message)"
    }
    
    return $tables
}

function ConvertTo-TableObject {
    param(
        $HtmlTable,
        [int]$TableIndex
    )
    
    $tableRows = @()
    $headers = @()
    $caption = ""
    
    # Try to get the table caption if present
    try {
        $captionElement = $HtmlTable.getElementsByTagName('caption')
        if ($captionElement -and $captionElement.length -gt 0) {
            $caption = $captionElement.item(0).innerText.Trim()
        }
    }
    catch {
        Write-Verbose "Could not extract caption: $($_.Exception.Message)"
    }
    
    # First look for headers in thead section
    try {
        $thead = $HtmlTable.getElementsByTagName('thead')
        if ($thead -and $thead.length -gt 0) {
            $thElements = $thead.item(0).getElementsByTagName('th')
            if ($thElements -and $thElements.length -gt 0) {
                foreach ($th in $thElements) {
                    $headerText = $th.innerText.Trim()
                    if ([string]::IsNullOrWhiteSpace($headerText)) {
                        $headerText = "Column$($headers.Count + 1)"
                    }
                    $headers += $headerText
                }
            }
        }
    }
    catch {
        Write-Verbose "Error processing thead: $($_.Exception.Message)"
    }
    
    # If no headers found in thead, look for th elements in the first row
    if ($headers.Count -eq 0) {
        try {
            $thElements = $HtmlTable.getElementsByTagName('th')
            if ($thElements -and $thElements.length -gt 0) {
                foreach ($th in $thElements) {
                    $headerText = $th.innerText.Trim()
                    if ([string]::IsNullOrWhiteSpace($headerText)) {
                        $headerText = "Column$($headers.Count + 1)"
                    }
                    $headers += $headerText
                }
            }
        }
        catch {
            Write-Verbose "Error processing th elements: $($_.Exception.Message)"
        }
    }
    
    # Extract rows from tbody if present, otherwise from the table directly
    $rowElements = @()
    try {
        $tbody = $HtmlTable.getElementsByTagName('tbody')
        if ($tbody -and $tbody.length -gt 0) {
            $rowElements = $tbody.item(0).getElementsByTagName('tr')
        }
        else {
            $rowElements = $HtmlTable.getElementsByTagName('tr')
        }
    }
    catch {
        # Fallback to getting tr elements directly from table
        try {
            $rowElements = $HtmlTable.getElementsByTagName('tr')
        }
        catch {
            Write-Verbose "Could not extract rows: $($_.Exception.Message)"
        }
    }
    
    # Process each row
    $rowIndex = 0
    foreach ($row in $rowElements) {
        $rowData = @()
        $isHeaderRow = $false
        
        # Check if this is a header row (all cells are TH) - skip if we already have headers
        if ($headers.Count -eq 0 -or $rowIndex -gt 0) {
            try {
                $thCells = $row.getElementsByTagName('th')
                if ($thCells -and $thCells.length -gt 0 -and 
                    ($rowIndex -eq 0 -or $thCells.length -eq $row.childNodes.length)) {
                    $isHeaderRow = ($rowIndex -eq 0)
                    
                    if ($isHeaderRow) {
                        foreach ($th in $thCells) {
                            $headerText = $th.innerText.Trim()
                            if ([string]::IsNullOrWhiteSpace($headerText)) {
                                $headerText = "Column$($headers.Count + 1)"
                            }
                            $headers += $headerText
                        }
                        $rowIndex++
                        continue
                    }
                }
            }
            catch {
                Write-Verbose "Error checking for header row: $($_.Exception.Message)"
            }
        }
        
        # Get TD elements (data cells)
        try {
            $tdCells = $row.getElementsByTagName('td')
            if ($tdCells -and $tdCells.length -gt 0) {
                foreach ($td in $tdCells) {
                    $cellText = $td.innerText.Trim()
                    $rowData += $cellText
                }
            }
            elseif ($rowIndex -gt 0) {
                # If no TD cells and we're past the first row, check for TH cells
                $thCells = $row.getElementsByTagName('th')
                if ($thCells -and $thCells.length -gt 0) {
                    foreach ($th in $thCells) {
                        $cellText = $th.innerText.Trim()
                        $rowData += $cellText
                    }
                }
            }
        }
        catch {
            Write-Verbose "Error processing row cells: $($_.Exception.Message)"
        }
        
        # Skip empty rows
        if ($rowData.Count -eq 0) {
            $rowIndex++
            continue
        }
        
        # Create row object
        if ($headers.Count -gt 0) {
            $rowObj = [ordered]@{}
            
            # Make sure headers cover all columns
            while ($headers.Count -lt $rowData.Count) {
                $headers += "Column$($headers.Count + 1)"
            }
            
            # Assign values to headers
            for ($j = 0; $j -lt [Math]::Min($headers.Count, $rowData.Count); $j++) {
                $rowObj[$headers[$j]] = $rowData[$j]
            }
            
            # Add null for missing columns
            for ($j = $rowData.Count; $j -lt $headers.Count; $j++) {
                $rowObj[$headers[$j]] = $null
            }
            
            $tableRows += [PSCustomObject]$rowObj
        }
        else {
            # No headers, just add as array
            $tableRows += , $rowData
        }
        
        $rowIndex++
    }
    
    # If we have rows but no headers, create default headers
    if ($headers.Count -eq 0 -and $tableRows.Count -gt 0) {
        $firstRow = $tableRows[0]
        if ($firstRow -is [Array]) {
            $columnCount = $firstRow.Count
            for ($i = 1; $i -le $columnCount; $i++) {
                $headers += "Column$i"
            }
        }
    }
    
    return [PSCustomObject]@{
        Index    = $TableIndex
        Headers  = $headers
        Rows     = $tableRows
        RowCount = $tableRows.Count
        Caption  = $caption
    }
}

function ConvertTo-TableObjectFromHtml {
    param(
        [string]$HtmlTable,
        [int]$TableIndex
    )
    
    $tableRows = @()
    $headers = @()
    $hasHeadersRow = $false
    
    # Extract header rows - Wikipedia often has headers in thead or first tr
    $theadRegex = [regex]'(?s)<thead[^>]*>(.*?)</thead>'
    $theadMatch = $theadRegex.Match($HtmlTable)
    
    if ($theadMatch.Success) {
        $thRegex = [regex]'<th[^>]*>(.*?)</th>'
        $thMatches = $thRegex.Matches($theadMatch.Value)
        $hasHeadersRow = ($thMatches.Count -gt 0)
        
        foreach ($match in $thMatches) {
            $headerText = $match.Groups[1].Value.Trim()
            # Clean up potential HTML inside header cells
            $headerText = $headerText -replace '(?s)<[^>]+>', ' '
            $headerText = $headerText -replace '\s+', ' '
            $headerText = $headerText.Trim()
            $headers += $headerText
        }
    }
    
    # If no thead, look for th elements in the first row
    if (-not $hasHeadersRow) {
        $thRegex = [regex]'<th[^>]*>(.*?)</th>'
        $thMatches = $thRegex.Matches($HtmlTable)
        
        if ($thMatches.Count -gt 0) {
            foreach ($match in $thMatches) {
                $headerText = $match.Groups[1].Value.Trim()
                # Clean up potential HTML inside header cells
                $headerText = $headerText -replace '(?s)<[^>]+>', ' '
                $headerText = $headerText -replace '\s+', ' '
                $headerText = $headerText.Trim()
                if ([string]::IsNullOrWhiteSpace($headerText)) {
                    $headerText = "Column$($headers.Count + 1)"
                }
                $headers += $headerText
            }
        }
    }
    
    # Extract all rows
    $trRegex = [regex]'(?s)<tr[^>]*>(.*?)</tr>'
    $trMatches = $trRegex.Matches($HtmlTable)
    $rowIndex = 0
    
    foreach ($trMatch in $trMatches) {
        $rowHtml = $trMatch.Groups[1].Value
        $rowData = @()
        
        # Check for td elements first
        $tdRegex = [regex]'(?s)<td[^>]*>(.*?)</td>'
        $tdMatches = $tdRegex.Matches($rowHtml)
        
        # If no td elements, this might be a header row we already processed, or empty row
        if ($tdMatches.Count -eq 0 -and $rowIndex -eq 0 -and $headers.Count -gt 0) {
            $rowIndex++
            continue
        }
        
        # If there are td elements, process them
        if ($tdMatches.Count -gt 0) {
            foreach ($tdMatch in $tdMatches) {
                $cellText = $tdMatch.Groups[1].Value
                # Clean up potential HTML inside cells
                $cellText = $cellText -replace '(?s)<[^>]+>', ' '
                $cellText = $cellText -replace '\s+', ' '
                $cellText = $cellText.Trim()
                $rowData += $cellText
            }
        }
        else {
            # Look for th elements in this row (could be a row with th cells in tbody)
            $thRegex = [regex]'(?s)<th[^>]*>(.*?)</th>'
            $thMatches = $thRegex.Matches($rowHtml)
            
            if ($thMatches.Count -gt 0 -and $rowIndex -gt 0) {
                foreach ($thMatch in $thMatches) {
                    $cellText = $thMatch.Groups[1].Value
                    # Clean up potential HTML inside cells
                    $cellText = $cellText -replace '(?s)<[^>]+>', ' '
                    $cellText = $cellText -replace '\s+', ' '
                    $cellText = $cellText.Trim()
                    $rowData += $cellText
                }
            }
            else {
                # Skip this row as it has no content
                $rowIndex++
                continue
            }
        }
        
        # Add row data to results
        if ($rowData.Count -gt 0) {
            if ($headers.Count -gt 0) {
                # Create object with headers as property names
                $rowObj = [ordered]@{}
                
                # Make sure we have enough headers (Wikipedia tables can be complex)
                while ($headers.Count -lt $rowData.Count) {
                    $headers += "Column$($headers.Count + 1)"
                }
                
                # Assign cell values to corresponding headers
                for ($j = 0; $j -lt $rowData.Count; $j++) {
                    $rowObj[$headers[$j]] = $rowData[$j]
                }
                $tableRows += [PSCustomObject]$rowObj
            }
            else {
                # No headers, just add data as array
                $tableRows += , $rowData
            }
        }
        
        $rowIndex++
    }
    
    # If we still don't have headers but do have rows, create generic column names
    if ($headers.Count -eq 0 -and $tableRows.Count -gt 0) {
        $firstRow = $tableRows[0]
        if ($firstRow -is [Array]) {
            $columnCount = $firstRow.Count
            for ($i = 1; $i -le $columnCount; $i++) {
                $headers += "Column$i"
            }
        }
    }
    
    # Create result object
    $result = [PSCustomObject]@{
        Index    = $TableIndex
        Headers  = $headers
        Rows     = $tableRows
        RowCount = $tableRows.Count
        Caption  = ""  # Initialize caption property
    }
    
    # Try to extract caption if present
    $captionRegex = [regex]'<caption[^>]*>(.*?)</caption>'
    $captionMatch = $captionRegex.Match($HtmlTable)
    if ($captionMatch.Success) {
        $captionText = $captionMatch.Groups[1].Value
        # Clean up HTML in caption
        $captionText = $captionText -replace '(?s)<[^>]+>', ' '
        $captionText = $captionText -replace '\s+', ' '
        $captionText = $captionText.Trim()
        $result.Caption = $captionText
    }
    
    return $result
}

# Export the main function
Export-ModuleMember -Function Invoke-WebScraper