## Enabling modern authentication in Exchange Online, SharePoint Online, and Skype for Business Online

You will need to have MSOnline, Skype for Business Online Windows PowerShell, and Microsoft Online SharePoint PowerShell modules installed. **This script will automatically download and install these modules. Script will need to be executed as administrator to ensure PowerShell modules are installed.**

The Skype for Business Online module requires Microsoft .NET Framework 4.7 and Microsoft Visual C++ Redistributable for Visual Studio 2017 during installation this will require manual installation prior to running the script
- Microsoft Visual C++ Redistributable for Visual Studio 2017: https://visualstudio.microsoft.com/downloads/ - Other Tools and

### Installing/Loading Module Prompts
Do you want to check Office 365? [y/n]
- If answered yes, the MSOnline module will be installed and loaded
Do you want to check SharePoint Online? [y/n]
- If answered yes, the SharePoint Online PowerShell module will be downloaded, an installer will run, then the module will be loaded
Do you want to check Skype for Business Online?
- If Skype for Business module not found it will be downloaded and installed
Installing Skype for Business Online module will require system reboot! Proceed? [y/n]
- If answered yes, the Skype for Business Online PowerShell module will be downloaded, an installer will run, then the machine will prompt for reboot
A modern authentication window will ask for global admin credentials for O365 tenant
Enter your Office 365 domain

### Enabling Modern Auth/Disabling Basic Auth
If the script sees something different from the example output below, the user will be asked if they want to make the change:
Modern auth not enabled for O365. Enable now? [y/n]
Modern auth not enabled for SharePoint Online. Enable now? [y/n]
Basic auth for SharePoint Online is enabled. Disable now? [y/n]
Modern auth for Skype for Business Online is disabled. Enable now? [y/n]

### Example Output
Domain: example.onmicrosoft.com
Federation: Managed
O365 Modern Auth Enabled: True
Skype Modern Auth: Allowed
SharePoint Online Modern Auth Disabled: False
SharePoint Online Legacy Auth Enabled: False
