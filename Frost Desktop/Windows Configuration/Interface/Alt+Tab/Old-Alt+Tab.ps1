# Set the registry key to enable the legacy Alt+Tab menu
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
$RegName = "AltTabSettings"
$RegValue = 1

# Create or modify the registry key
New-ItemProperty -Path $RegPath -Name $RegName -Value $RegValue -PropertyType DWord -Force

# Restarts Explorer to apply changes
Stop-Process -Name explorer -Force
Start-Process explorer

# notification

Write-Output "The legacy Alt+Tab menu has been enabled. The Explorer process has been restarted."
