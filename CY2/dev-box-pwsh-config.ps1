
# Add Updated VCLibs package
Add-AppxPackage 'https://aka.ms/Microsoft.VCLibs.x86.14.00.Desktop.appx'
Get-AppxPackage -Name "Microsoft.VC*" | Select Name, Architecture, Version | FT

#Write-Host "Checking for VCLibs UWP Desktop Update"
# Retrieve the current version of the VCLibs package if it exists
#$currentVCLibs = Get-AppxPackage -Name "Microsoft.VCLibs*" | Where-Object { $_.Architecture -eq "x86" } | Select-Object -ExpandProperty Version
# Define the version threshold
#$thresholdVersion = [Version]"14.0.33000.0"
#if ($currentVCLibs -and [Version]$currentVCLibs -ge $thresholdVersion) {
#    Write-Host "VCLibs version $currentVCLibs is already above $thresholdVersion. Skipping installation."
#} else {
#    Write-Host "Installing VCLibs UWP Desktop Update"
#    Add-AppxPackage 'https://aka.ms/Microsoft.VCLibs.x86.14.00.Desktop.appx'
#}
# Pause for user input
#Read-Host -Prompt "Press any key to continue..."

# Install Elastic Agent
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-8.15.3-windows-x86_64.zip -OutFile elastic-agent-8.15.3-windows-x86_64.zip
Expand-Archive .\elastic-agent-8.15.3-windows-x86_64.zip -DestinationPath .
cd elastic-agent-8.15.3-windows-x86_64
.\elastic-agent.exe install -f --url=https://b1d6944f978c4e718656dfead30f3395.fleet.eu-west-2.aws.cloud.es.io:443 --enrollment-token=Um1XVDJKSUJXTVE4MHpTdW5RNUk6aGRfbVptcU9TRjZmSEFHMjUzMS0wZw==

#Write-Host "Checking if Elastic Agent is already installed or running"
# Check if Elastic Agent is running as a process
#$elasticAgentProcess = Get-Process -Name "elastic-agent" -ErrorAction SilentlyContinue
#if ($elasticAgentProcess) {
#    Write-Host "Elastic Agent is already installed and running. Skipping installation."
#} else {
#    Write-Host "Elastic Agent not found or not running. Installing Elastic Agent..."
#    Write-Host "Elastic Agent not found. Installing Elastic Agent..."
    # Download and install Elastic Agent
#	$ProgressPreference = 'SilentlyContinue'
#      Invoke-WebRequest -Uri https://artifacts.elastic.co/downloads/beats/elastic-agent/elastic-agent-8.15.3-windows-x86_64.zip -OutFile elastic-agent-8.15.3-windows-x86_64.zip
#      Expand-Archive .\elastic-agent-8.15.3-windows-x86_64.zip -DestinationPath .
#      cd elastic-agent-8.15.3-windows-x86_64
#      .\elastic-agent.exe install -f --url=https://b1d6944f978c4e718656dfead30f3395.fleet.eu-west-2.aws.cloud.es.io:443 --enrollment-token=Um1XVDJKSUJXTVE4MHpTdW5RNUk6aGRfbVptcU9TRjZmSEFHMjUzMS0wZw==
#    Write-Host "Elastic Agent installation complete."
#}
# Pause for user input
#Read-Host -Prompt "Press any key to continue..."


# Install VSCode Extensions
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

#Write-Host "Checking if VSCode extensions are installed"
# List of VSCode extensions to check and install
#$extensions = @(
#    "ms-vscode.powershell",
#    "ms-azuretools.vscode-docker",
#    "ms-vscode.makefile-tools",
#    "redhat.vscode-yaml",
#    "onecentlin.laravel5-snippets",
#    "onecentlin.laravel-blade",
#    "DEVSENSE.phptools-vscode",
#    "ms-python.python",
#    "ms-python.debugpy",
#    "ms-vscode-remote.remote-wsl"
#)
# Get installed extensions
#$installedExtensions = code --list-extensions
# Loop through each extension to check if it is already installed
#foreach ($extension in $extensions) {
#    if ($installedExtensions -contains $extension) {
#        Write-Host "$extension is already installed. Skipping installation."
#    } else {
#        Write-Host "$extension not found. Installing $extension..."
#        code --install-extension $extension
#    }
#}
# Pause for user input
#Read-Host -Prompt "Press any key to continue..."


# Cleanup
# Add to docker-users group
$username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
Add-LocalGroupMember -Group "docker-users" -Member $username

# Remove admin permissions and force restart machine after 5 minutes for intune software to install
Remove-LocalGroupMember -Group "Administrators" -Member $username
Start-Sleep -Seconds 300
Restart-Computer -Force

<# Write-Host "Running Cleanup"
# Get the current username
$username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$dockerUserName = $username.Split('\')[-1]  # Extract the username part (e.g., JoeG)
# Check if the script is running with admin privileges
function Check-Admin {
    $isAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    return $isAdmin
}
# Proceed if the script is running as an admin
if (-not (Check-Admin)) {
    Write-Host "You need to run this script as an Administrator to make changes to local groups."
    exit
}
# Check if the user is already a member of the "docker-users" group
$dockerGroupMembers = Get-LocalGroupMember -Group "docker-users" | Select-Object -ExpandProperty Name
if ($dockerGroupMembers -contains $dockerUserName) {
    Write-Host "$dockerUserName is already a member of the docker-users group. Skipping adding to group."
    $dockerGroupChanged = $false
} else {
    Write-Host "Adding $dockerUserName to docker-users group..."
    try {
        Add-LocalGroupMember -Group "docker-users" -Member $username
        $dockerGroupChanged = $true
    } catch {
        Write-Host "Failed to add $dockerUserName to docker-users group: $_"
        $dockerGroupChanged = $false
    }
}

# Check if the user is part of the "Administrators" group before removing
$adminGroupMembers = Get-LocalGroupMember -Group "Administrators" | Select-Object -ExpandProperty Name
if ($adminGroupMembers -contains $dockerUserName) {
    Write-Host "Removing $dockerUserName from Administrators group..."
    try {
        Remove-LocalGroupMember -Group "Administrators" -Member $username
        $adminGroupChanged = $true
    } catch {
        Write-Host "Failed to remove $dockerUserName from Administrators group: $_"
        $adminGroupChanged = $false
    }
} else {
    Write-Host "$dockerUserName is not a member of the Administrators group. Skipping removal."
    $adminGroupChanged = $false
}
# If any changes were made, start the countdown for restart
if ($dockerGroupChanged -or $adminGroupChanged) {
    Write-Host "Changes were made, restarting the system..."
    $seconds = 300  # Countdown duration in seconds
    for ($i = $seconds; $i -gt 0; $i--) {
        Write-Host "Restarting in $i seconds..." -NoNewline
        Start-Sleep -Seconds 1
        Write-Host " `r"  # Return carriage to overwrite countdown line
    }
    # Force restart the machine
    Restart-Computer -Force
} else {
    Write-Host "No changes were made. Skipping restart."
} #>