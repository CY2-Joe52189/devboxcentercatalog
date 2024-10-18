## Powershell script to do cleanup in one instead of multiple tasks inside the config

## Remove cloned repo for team config
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
Remove-Item -Path "C:\src\devcenter-catalog\" -Recurse -Force

## Remove admin from logged on user
$username = $env:USERNAME
Remove-LocalGroupMember -Group "Administrators" -Member $username

## Reboot machine
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
shutdown /r /f