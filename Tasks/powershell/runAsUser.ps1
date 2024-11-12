$CustomizationScriptsDir = "C:\DevBoxCustomizations"
$LockFile = "lockfile"

Write-Host "Starting the script as user"
Write-Host "DO NOT CLOSE THIS WINDOW"
Start-Sleep -Seconds 3

Remove-Item -Path "$($CustomizationScriptsDir)\$($LockFile)" -Force
