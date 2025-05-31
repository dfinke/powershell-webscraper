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
    The format to return the data in. Options: 'Text', 'Links', 'Images', 'All', 'Raw'
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
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Url,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('Text', 'Links', 'Images', 'All', 'Raw')]
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
            # Parse the HTML content
            $htmlContent = $webRequest.Content
            
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
                'All' {
                    $result = [PSCustomObject]@{
                        Url = $Url
                        Title = Get-PageTitle -HtmlContent $htmlContent
                        TextContent = Get-TextContent -HtmlContent $htmlContent
                        Links = Get-Links -WebRequest $webRequest
                        Images = Get-Images -WebRequest $webRequest
                        StatusCode = $webRequest.StatusCode
                        ContentLength = $htmlContent.Length
                        LastModified = $webRequest.Headers['Last-Modified']
                        ContentType = $webRequest.Headers['Content-Type']
                    }
                    return $result
                }
            }
        } else {
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
                Text = $link.innerText
                Href = $link.href
                AbsoluteUri = if ($link.href -match '^https?://') { $link.href } else { 
                    try { 
                        $uri = New-Object System.Uri([System.Uri]$WebRequest.BaseResponse.ResponseUri, $link.href)
                        $uri.ToString()
                    } catch { 
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
                Alt = $image.alt
                Src = $image.src
                AbsoluteUri = if ($image.src -match '^https?://') { $image.src } else { 
                    try { 
                        $uri = New-Object System.Uri([System.Uri]$WebRequest.BaseResponse.ResponseUri, $image.src)
                        $uri.ToString()
                    } catch { 
                        $image.src 
                    }
                }
            }
            $images += $imageObj
        }
    }
    
    return $images
}

# Export the main function
Export-ModuleMember -Function Invoke-WebScraper