# Check if running as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Script is not running as administrator. Re-launching with elevated privileges..."
    Start-Sleep -Seconds 2
    Start-Process powershell.exe -ArgumentList "-File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# Enable Animations (revert changes)
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'FontSmoothing' -Type String -Value '2'
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'UserPreferencesMask' -Type Binary -Value ([byte[]](0x90, 0x32, 0x03, 0x80, 0x10, 0x00, 0x00, 0x00))
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'DragFullWindows' -Type String -Value '1'
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop\WindowMetrics' -Name 'MinAnimate' -Type String -Value '1'
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ListviewAlphaSelect' -Type DWord -Value 1
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'IconsOnly' -Type DWord -Value 1
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarAnimations' -Type DWord -Value 1
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ListviewShadow' -Type DWord -Value 1
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects' -Name 'VisualFXSetting' -Type DWord -Value 0
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\DWM' -Name 'EnableAeroPeek' -Type DWord -Value 1
Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\DWM' -Name 'AlwaysHibernateThumbnails' -Type DWord -Value 1

# Function to log off the user

function Invoke-LogOff {
    $choice = Read-Host "Finished, would you like to log off to apply the changes? [Y/N]"
    if ($choice -eq 'Y' -or $choice -eq 'y') {
        shutdown.exe /l
    }
}

# Function to restart explorer
function Restart-Explorer {
    Stop-Process -Name explorer -Force
    Start-Process explorer
}

# Restart explorer to apply changes immediately
Restart-Explorer

# Prompt the user to log off
if ($args[0] -ne "/silent") {
    Invoke-LogOff
}
