
# Add Updated VCLibs package
Add-AppxPackage 'https://aka.ms/Microsoft.VCLibs.x86.14.00.Desktop.appx'
Get-AppxPackage -Name "Microsoft.VC*" | Select Name, Architecture, Version | F

# Install Elastic Agent
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-8.15.3-windows-x86_64.zip -OutFile elastic-agent-8.15.3-windows-x86_64.zip
Expand-Archive .\elastic-agent-8.15.3-windows-x86_64.zip -DestinationPath .
cd elastic-agent-8.15.3-windows-x86_64
.\elastic-agent.exe install -f --url=https://b1d6944f978c4e718656dfead30f3395.fleet.eu-west-2.aws.cloud.es.io:443 --enrollment-token=Um1XVDJKSUJXTVE4MHpTdW5RNUk6aGRfbVptcU9TRjZmSEFHMjUzMS0wZw==

# Install VSCode Extensions
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
code --install-extension ms-vscode.powershell
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-vscode.makefile-tools
code --install-extension redhat.vscode-yaml
code --install-extension onecentlin.laravel5-snippets
code --install-extension onecentlin.laravel-blade
code --install-extension DEVSENSE.phptools-vscode
code --install-extension ms-python.python
code --install-extension ms-python.debugpy
code --install-extension ms-vscode-remote.remote-wsl


# Additional Config
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
# Removes xbox app
get-appxpackage -allusers *xboxapp* | Remove-AppxPackage


# Cleanup
# Get Username of logged in user
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
$username = $env:USERNAME
          
# Add to docker-users group
$username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
Add-LocalGroupMember -Group "docker-users" -Member $username
          
# Remove temp files
Remove-Item -Path "C:\winget-configurations\" -Recurse -Force

# Remove admin permissions and force restart machine after 5 minutes for intune software to install
Remove-LocalGroupMember -Group "Administrators" -Member $username
Start-Sleep -Seconds 300
Restart-Computer -Force