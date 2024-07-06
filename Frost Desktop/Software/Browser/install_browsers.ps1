& ".\wingetCheck.cmd"
if ($LASTEXITCODE -ne 0) { exit 1 }

Clear-Host
$ErrorActionPreference = 'SilentlyContinue'

[int] $global:column = 0
[int] $separate = 30
[int] $global:lastPos = 50
[int] $global:item_count = 0
[int] $global:index = 0
[array] $global:items = @()
[bool] $global:install = $false

function init_item{
    param(
        [string]$checkboxText,
        [string]$package
    )
    $global:items += , @($checkboxText, $package)
}

function generate_checkbox {
    param(
        [string]$checkboxText,
        [string]$package,
        [bool]$enabled = $true
    )
    $checkbox = new-object System.Windows.Forms.checkbox
    if($global:index -eq [math]::Ceiling($global:item_count / 2)){
        $global:column = 1
        $global:lastPos = 50
    }
    if($global:column -eq 0){
        $checkbox.Location = new-object System.Drawing.Size(30, $global:lastPos)
    }
    else{
        $checkbox.Location = new-object System.Drawing.Size(($global:column * 300), $global:lastPos)
    }
    $global:lastPos += $separate
    $checkbox.Size = new-object System.Drawing.Size(250, 18)
    $checkbox.Text = $checkboxText
    $checkbox.Name = $package
    $checkbox.Enabled = $enabled

    $checkbox
}

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")


$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Install Browsers | FrostOS" # Titlebar
$Form.ShowIcon = $false
$Form.MaximizeBox = $false
$Form.MinimizeBox = $false
$Form.Size = New-Object System.Drawing.Size(600, 210)
$Form.AutoSizeMode = 0
$Form.KeyPreview = $True
$Form.SizeGripStyle = 2


$Label = New-Object System.Windows.Forms.Label
$Label.Location = New-Object System.Drawing.Point(11, 15)
$Label.Size = New-Object System.Drawing.Size(255, 15)
$Label.Text = "This tool installs browsers."


$Form.Controls.Add($Label)


# https://winget.run/pkg/eloston/ungoogled-chromium
init_item "Ungoogled Chromium" "eloston.ungoogled-chromium"

# https://winget.run/pkg/Google/Chrome
init_item "Google Chrome" "Google" "Google LLC.google-chrome"

# https://winget.run/pkg/Mozilla/Firefox
init_item "Mozilla Firefox" "Mozilla.Firefox"

# https://winget.run/pkg/Waterfox/Waterfox
init_item "Waterfox" "Waterfox.Waterfox"

# https://winget.run/pkg/Brave/brave
init_item "Brave Browser" "Brave.Brave"

# https://winget.run/pkg/Google/Chrome
init_item "Google Chrome" "Google.Chrome"

# https://winget.run/pkg/LibreWolf/LibreWolf
init_item "LibreWolf" "LibreWolf.LibreWolf"

# https://winget.run/pkg/TorProject/TorBrowser
init_item "Tor Browser" "TorProject.TorBrowser"


$global:item_count = $global:items.Length

foreach($item in $global:items){
    if($global:index -eq ($global:item_count / 2)){
        $global:column = 1
    }
    $Form.Controls.Add((generate_checkbox $item[0] $item[1]))
    $global:index ++
}

if ($global:column -ne 0) {
    $global:lastPos += $separate
}

$Form.height = $global:lastPos + 80


function dark_mode {
    $Form.BackColor = [System.Drawing.Color]::FromArgb(26, 26, 26)
    $Form.ForeColor = [System.Drawing.Color]::White
    foreach ($control in $Form.Controls) {
        if ($control.GetType().Name -eq "Checkbox") {
            $control.BackColor = [System.Drawing.Color]::FromArgb(26, 26, 26)
            $control.ForeColor = [System.Drawing.Color]::White
        }
    }
}


$Form.Controls.Add($ToggleBtn)

# Install Button
$lastPosWidth = $form.Width - 80 - 31
$InstallButton = new-object System.Windows.Forms.Button
$InstallButton.Location = new-object System.Drawing.Size($lastPosWidth, $global:lastPos)
$InstallButton.Size = new-object System.Drawing.Size(80, 23)
$InstallButton.Text = "Install"
$InstallButton.Add_Click({
    $checkedBoxes = $Form.Controls | Where-Object { $_ -is [System.Windows.Forms.Checkbox] -and $_.Checked }
    if ($checkedBoxes.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Please select at least one browser to install.", "No browser selected", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    else {
        $global:install = $true
        $Form.Close()
    }
})
$Form.Controls.Add($InstallButton)

# Activate the form
$Form.Add_Shown({ $Form.Activate() })
[void] $Form.ShowDialog()

if ($global:install) {
    $installPackages = [System.Collections.ArrayList]::new()
    $Form.Controls | Where-Object { $_ -is [System.Windows.Forms.Checkbox] } | ForEach-Object {
        if ($_.Checked) {
            [void]$installPackages.Add($_.Name)
        }
    }

    if ($installPackages.count -ne 0) {
        Write-Host "Installing: " -ForegroundColor Yellow
        foreach ($a in $installPackages) {
            Write-Host "- " -NoNewline -ForegroundColor Blue
            Write-Host "$a"
        }
        Write-Host ""
        Start-Sleep 1
        foreach ($package in $installPackages) {
            & winget install -e --id $package --accept-package-agreements --accept-source-agreements --disable-interactivity --force -h
        }
        Write-Host ""
        pause
    }
}