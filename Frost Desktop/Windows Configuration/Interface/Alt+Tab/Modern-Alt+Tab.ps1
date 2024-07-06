# Set the registry key to disable the legacy Alt+Tab menu
$RegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
$RegName = "AltTabSettings"

# Remove the registry key
Remove-ItemProperty -Path $RegPath -Name $RegName -ErrorAction SilentlyContinue

# Restart Explorer to apply changes
Stop-Process -Name explorer -Force
Start-Process explorer

# Notify the user
Write-Output "The default Windows 10 Alt+Tab menu has been restored. The Explorer process has been restarted."
