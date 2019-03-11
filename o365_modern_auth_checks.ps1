
Skip to content

    Pull requests
    Issues
    Marketplace
    Explore

    @jstan12

0
1

    0

jstan12/O365-Modern-Authentication
Code
Issues 0
Pull requests 0
Projects 0
Wiki
Insights
Settings
O365-Modern-Authentication/o365_modern_auth_checks.ps1
@jstan12 jstan12 Create o365_modern_auth_checks.ps1 0398e7b on Jan 17
164 lines (148 sloc) 7.39 KB
#######
#### Requirements ####
## MSOnline Module: Install-Module MSOnline
## Skype for Business Online, Windows PowerShell Module required: https://www.microsoft.com/en-us/download/details.aspx?id=39366
## SharePoint Online PowerShell: https://download.microsoft.com/download/2/0/5/2050B39B-4DA5-48E0-B768-583533B42C3B/SkypeOnlinePowerShell.Exe
## Microsoft Visual C++ Redistributable for Visual Studio 2017 required for Skype Module: https://visualstudio.microsoft.com/downloads/
## - Other Tools and Frameworks > Download Microsoft Visual C++ Redistributable for Visual Studio 2017
#######
## Author: Joe Stanulis
## Date: 2019-1-3
#######

function o365_module {
    Import-Module MSOnline -ErrorAction SilentlyContinue
    ### Get MSOnline Module
    If (-not (Get-Module -Name 'MSOnline')) {
        Write-Host 'MSOnline module not found...'
        Write-Host 'Installing MSOnline module'
        Install-Module MSOnline -Force
        Import-Module MSOnline
    }
    Else {
        Write-Host 'MSOnline Module Loaded'
    }
}

function spo_module {
    Import-Module 'C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell' -ErrorAction SilentlyContinue
    ### Get SPO Management Shell Module
    If (-not (Get-Module -Name 'Microsoft.Online.SharePoint.PowerShell')) {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $spoConnector = 'https://download.microsoft.com/download/0/2/E/02E7E5BA-2190-44A8-B407-BC73CA0D6B87/SharePointOnlineManagementShell_8414-1200_x64_en-us.msi'
        $spoFile = 'SharePointOnlineManagementShell_8414-1200_x64_en-us.msi'
        $spoFilePath = $filePath + $spoFile
        Write-Host 'SharePointOnlineManagementShell not found...'
        Write-Host 'Downloading SharePointOnlineManagementShell_8414-1200_x64_en-us.msi'
        Invoke-WebRequest -Uri $spoConnector -OutFile $spoFilePath
        Write-Host 'Installing SharePointOnlineManagementShell_8414-1200_x64_en-us.msi'
        Start-Process $spoFilePath -Wait
        Remove-Item $spoFilePath
        Import-Module 'C:\Program Files\SharePoint Online Management Shell\Microsoft.Online.SharePoint.PowerShell'
    }
    Else {
        Write-Host 'SharePointOnline Module Loaded'
    }
}

function skype_module{
    Import-Module SkypeOnlineConnector -ErrorAction SilentlyContinue
    ### Get SkypeOnlineConnector Module
    If (-not (Get-Module -Name 'SkypeOnlineConnector')) {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $skypeConnector = 'https://download.microsoft.com/download/2/0/5/2050B39B-4DA5-48E0-B768-583533B42C3B/SkypeOnlinePowerShell.Exe'
        $skypeFile = 'SkypeOnlinePowerShell.exe'
        $skypeFilePath = $filePath + $skypeFile
        Write-Host 'SkypeOnlineConnector not found...'
        Write-Host 'Downloading SkypeOnlinePowerShell.exe'
        Invoke-WebRequest -Uri $skypeConnector -OutFile $skypeFilePath
        Write-Host 'Installing SkypeOnlinePowerShell.exe... Installation will require restart'
        Start-Process $skypeFilePath -Verb Open
        Exit
    }
    Else {
        Write-Host 'SkypOnlineConnector Module Loaded'
    }
}

$ProgressPreference=’SilentlyContinue’
$filePath = "$($env:USERPROFILE)\Desktop\"
$file =  $filePath + "modernAuthChecks.txt"

## Load modules
$o365Confirm = Read-Host "Do you want to check Office 365? [y/n]"
If ($o365Confirm -eq 'y'){o365_module}
$spoConfirm = Read-Host "Do you want to check SharePoint Online? [y/n]"
If ($spoConfirm -eq 'y'){spo_module}
Write-Host "Do you want to check Skype for Business Online?"
Write-Host "If Skype for Business module not found it will be downloaded and installed"
$skypeConfirm = Read-Host "Installing Skype for Business Online module will require system reboot! Proceed? [y/n]"
If ($skypeConfirm -eq 'y'){skype_module}

If ($o365Confirm -eq 'y'){
    ### O365 Federation Status
    $UserCredential = Get-Credential
    Connect-MsolService -Credential $UserCredential
    # Get domain federation status
    $dom = Read-Host -Prompt 'Enter your Office 365 domain'
    $federation = Get-MsolDomain -domain $dom

    ### O365 Modern Authentication Status
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
    Import-PSSession $Session -DisableNameChecking
    $o365ModernAuth = Get-OrganizationConfig
    
    If ($o365ModernAuth.OAuth2ClientProfileEnabled -ne $true){
        ## Enable modern auth prompt
        $o365EnableModernAuth = Read-Host "Modern auth not enabled for O365. Enable now? [y/n]"
        If ($o365EnableModernAuth -eq 'y'){
            Set-OrganizationConfig -OAuth2ClientProfileEnabled:$true
            }
    }
    Else {Write-Host "O365 modern auth enabled"}
    
    Remove-PSSession $Session
    $domain = 'Domain: ' + $federation.Name
    $fed = 'Federation: ' + $federation.Authentication
    $365 = 'O365 Modern Auth Enabled: ' + $o365modernAuth.OAuth2ClientProfileEnabled
}

If ($spoConfirm -eq 'y'){
    ### SharePoint Online Modern AUthentication Status
    # Build Sharepoint admin URL using regex
    $spoDom = $dom -replace '\.(.*)'
    [string]$spoDom = 'https://' + $spoDom + '-admin.sharepoint.com'

    Connect-SPOService -Url $spoDom -Credential $UserCredential
    $spoModernAuth = Get-SPOTenant
    If ($spoModernAuth.OfficeClientADALDisabled -ne $false){
        ## Enable modern auth
        $spoEnableModernAuth = Read-Host "Modern auth not enabled for SharePoint Online. Enable now? [y/n]"
        If ($spoEnableModernAuth -eq 'y'){
            Set-SPOTenant -OfficeClientADALDisabled $false
            }
    }
    Else {Write-Host "SharePoint Online modern auth enabled"}

<#
    If ($spoModernAuth.LegacyAuthProtocolsEnabled -eq $true){
        ## Do you want to disable basic auth?
        # Set-SPOTenant -LegacyAuthProtocolsEnabled $false
        $spoDisableBasicAuth = Read-Host "Basic auth for SharePoint Online is enabled. Disable now? [y/n]"
        If ($spoDisableBasicAuth -eq 'y'){
            Set-SPOTenant -LegacyAuthProtocolsEnabled $false
            }
    }
    Else {Write-Host "SharePoint Online basic auth disabled"}
    Disconnect-SPOService
    $spoADAL = 'SharePoint Online Modern Auth Disabled: ' + $spoModernAuth.OfficeClientADALDisabled
    $spoLegacy = 'SharePoint Online Legacy Auth Enabled: ' + $spoModernAuth.LegacyAuthProtocolsEnabled
}
#>

If ($skypeConfirm -eq 'y'){
    ### Skype Modern Authentication Status
    ## Login with basic auth if modern auth login fails
    # $UserName = Read-Host -Prompt 'Enter your Office 365 username: '
    # $cssession = New-CsOnlineSession -UserName $UserName

    $cssession = New-CsOnlineSession –Credential $UserCredential
    Import-PSSession $cssession
    $skypeModernAuth = Get-CsOAuthConfiguration
    If ($skypeModernAuth.ClientAdalAuthOverride -ne 'Allowed'){
        ## Set Modern auth to allowed?
        $skypeEnableModernAuth = Read-Host "Modern auth for Skype for Business Online is disabled. Enable now? [y/n]"
        If ($skypeEnableModernAuth -eq 'y'){
            Set-CsOAuthConfiguration -ClientAdalAuthOverride Allowed
            }
    }
    Else {Write-Host "Skype for Business Online modern auth allowed"}
    Remove-PSSession $cssession
    $skype = 'Skype Modern Auth: ' + $skypeModernAuth.ClientAdalAuthOverride
}

Write-Output $domain $fed $365 $skype $spoADAL $spoLegacy >> $file
Write-Host 'Configuration checks written to' $file
