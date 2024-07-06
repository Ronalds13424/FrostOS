# Check if script is running as Administrator, re-launch with elevation if not
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Script is not running as Administrator. Attempting to re-launch with elevated permissions..."
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Re-enable Lock Screen
Write-Host "Re-enabling Lock Screen..."
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
$registryName = "NoLockScreen"

if (Test-Path $registryPath) {
    Remove-ItemProperty -Path $registryPath -Name $registryName -ErrorAction SilentlyContinue
}

Write-Host "Lock Screen Re-enabled."

# Re-enable Password Requirement on Wakeup
Write-Host "Re-enabling Password Requirement on Wakeup..."
powercfg /SETDCVALUEINDEX SCHEME_CURRENT SUB_NONE CONSOLELOCK 1
powercfg /SETACVALUEINDEX SCHEME_CURRENT SUB_NONE CONSOLELOCK 1

Write-Host "Password Requirement on Wakeup Re-enabled."

# Inform the user of completion
Write-Host "All settings have been reverted. You may need to restart your computer for changes to take effect."
