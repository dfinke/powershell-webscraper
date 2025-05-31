@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'WebScraper.psm1'
    
    # Version number of this module.
    ModuleVersion = '1.0.0'
    
    # ID used to uniquely identify this module
    GUID = '12345678-1234-1234-1234-123456789012'
    
    # Author of this module
    Author = 'AI PowerShell WebScraper'
    
    # Company or vendor of this module
    CompanyName = 'Unknown'
    
    # Copyright statement for this module
    Copyright = '(c) 2024 AI PowerShell WebScraper. All rights reserved.'
    
    # Description of the functionality provided by this module
    Description = 'A simple PowerShell web scraper module that can fetch and parse web content, extracting text, links, images, and other data in a PowerShell-friendly format.'
    
    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.1'
    
    # Functions to export from this module
    FunctionsToExport = @('Invoke-WebScraper')
    
    # Cmdlets to export from this module
    CmdletsToExport = @()
    
    # Variables to export from this module
    VariablesToExport = @()
    
    # Aliases to export from this module
    AliasesToExport = @()
    
    # Private data to pass to the module specified in RootModule/ModuleToProcess
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('WebScraper', 'HTML', 'Parser', 'Web', 'Scraping', 'HTTP')
            
            # A URL to the license for this module.
            # LicenseUri = ''
            
            # A URL to the main website for this project.
            # ProjectUri = ''
            
            # A URL to an icon representing this module.
            # IconUri = ''
            
            # ReleaseNotes of this module
            ReleaseNotes = 'Initial release of PowerShell WebScraper module with basic web scraping functionality.'
        }
    }
}