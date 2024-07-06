# Check if script is running as Administrator, re-launch with elevation if not
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Script is not running as Administrator. Attempting to re-launch with elevated permissions..."
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Disable Lock Screen
Write-Host "Disabling Lock Screen..."
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
$registryName = "NoLockScreen"
$registryValue = 1

if (-Not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}
Set-ItemProperty -Path $registryPath -Name $registryName -Value $registryValue

Write-Host "Lock Screen Disabled."

# Disable Password Requirement on Wakeup
Write-Host "Disabling Password Requirement on Wakeup..."
powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_NONE CONSOLELOCK 0
powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_NONE CONSOLELOCK 0
powercfg /Change monitor-timeout-dc 0
powercfg /Change monitor-timeout-ac 0

Write-Host "Password Requirement on Wakeup Disabled."

# Inform the user of completion
Write-Host "All settings have been applied. You may need to restart your computer for changes to take effect."
