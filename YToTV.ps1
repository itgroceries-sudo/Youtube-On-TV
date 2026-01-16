<# :
@echo off
:: ✅ Code: Polite Installer
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Get-Content -LiteralPath '%~f0' | Out-String | Invoke-Expression"
goto :EOF
: #>

# ---------------------------------------------------------
# [PAYLOAD] PowerShell GUI Script
# ---------------------------------------------------------
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- CONFIGURATION ---
$ShortcutName = "Youtube On TV.lnk"
$ForceURL = "https://youtube.com/tv"
$DesktopPath = [System.Environment]::GetFolderPath('Desktop')
$ShortcutPath = Join-Path $DesktopPath $ShortcutName

# --- UNIVERSAL USER AGENT (UPGRADED TO TIZEN 9.0 - 2025) ---
# Engine: Chromium 120 (Super Stable & Fast)
$UA_Universal = "Mozilla/5.0 (SMART-TV; LINUX; Tizen 9.0) AppleWebKit/537.36 (KHTML, like Gecko) 120.0.6099.5/9.0 TV Safari/537.36"

# --- BACKGROUND PLAY FLAGS ---
$BackgroundFlags = "--disable-features=CalculateNativeWinOcclusion --disable-background-timer-throttling --disable-renderer-backgrounding --disable-backgrounding-occluded-windows"

# --- CUSTOM ICON ---
$IconUrl = "https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/refs/heads/main/YouTube.ico"
$IconPath = "$env:APPDATA\YoutubeTV_Icon.ico" 

# --- DETECT BROWSERS ---
$BravePath = "$env:ProgramFiles\BraveSoftware\Brave-Browser\Application\brave.exe"
$ChromePath = "$env:ProgramFiles\Google\Chrome\Application\chrome.exe"
$EdgePathX86 = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
$EdgePathX64 = "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"

# --- FORM SETUP ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "YouTube TV Installer (v6.0 - 2025 Engine)"
$form.Size = New-Object System.Drawing.Size(500, 320)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = "#1e1e1e"

# Download Icon
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    if (-not (Test-Path $IconPath)) { (New-Object System.Net.WebClient).DownloadFile($IconUrl, $IconPath) }
    $form.Icon = New-Object System.Drawing.Icon($IconPath)
} catch {}

# --- GUI LAYOUT ---
$fontHeader = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
$fontBody = New-Object System.Drawing.Font("Segoe UI", 10)
$fontBold = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$fontFooter = New-Object System.Drawing.Font("Consolas", 8)

$headerPanel = New-Object System.Windows.Forms.Panel; $headerPanel.Size = New-Object System.Drawing.Size(500, 60); $headerPanel.Location = New-Object System.Drawing.Point(0, 0); $headerPanel.BackColor = "#cc0000"
$headerLabel = New-Object System.Windows.Forms.Label; $headerLabel.Text = "YouTube TV Installer"; $headerLabel.Font = $fontHeader; $headerLabel.ForeColor = "White"; $headerLabel.AutoSize = $false; $headerLabel.Size = New-Object System.Drawing.Size(500, 60); $headerLabel.TextAlign = "MiddleCenter"
$headerPanel.Controls.Add($headerLabel); $form.Controls.Add($headerPanel)

$statusLabel = New-Object System.Windows.Forms.Label; $statusLabel.Text = "Select your browser to create shortcut"; $statusLabel.Font = $fontBody; $statusLabel.ForeColor = "#dddddd"; $statusLabel.AutoSize = $false; $statusLabel.Size = New-Object System.Drawing.Size(480, 30); $statusLabel.Location = New-Object System.Drawing.Point(10, 70); $statusLabel.TextAlign = "MiddleCenter"; $form.Controls.Add($statusLabel)

# --- DROPDOWN ---
$browserLabel = New-Object System.Windows.Forms.Label
$browserLabel.Text = "Browser:"
$browserLabel.Font = $fontBold
$browserLabel.ForeColor = "#00ccff"
$browserLabel.AutoSize = $true
$browserLabel.Location = New-Object System.Drawing.Point(140, 115)
$form.Controls.Add($browserLabel)

$browserDropdown = New-Object System.Windows.Forms.ComboBox
$browserDropdown.Size = New-Object System.Drawing.Size(180, 30)
$browserDropdown.Location = New-Object System.Drawing.Point(210, 112)
$browserDropdown.DropDownStyle = "DropDownList"
$browserDropdown.BackColor = "#333333"
$browserDropdown.ForeColor = "White"
$browserDropdown.Font = $fontBody

if (Test-Path $BravePath) { $browserDropdown.Items.Add("Brave Browser") | Out-Null }
if (Test-Path $ChromePath) { $browserDropdown.Items.Add("Google Chrome") | Out-Null }
if (Test-Path $EdgePathX64) { $browserDropdown.Items.Add("Microsoft Edge") | Out-Null }
elseif (Test-Path $EdgePathX86) { $browserDropdown.Items.Add("Microsoft Edge") | Out-Null }

if ($browserDropdown.Items.Count -gt 0) { $browserDropdown.SelectedIndex = 0 }
$form.Controls.Add($browserDropdown)

$btnAction = New-Object System.Windows.Forms.Button; $btnAction.Text = "Create Shortcut"; $btnAction.Font = $fontBold; $btnAction.Size = New-Object System.Drawing.Size(200, 50); $btnAction.Location = New-Object System.Drawing.Point(150, 160); $btnAction.BackColor = "#333333"; $btnAction.ForeColor = "White"; $btnAction.FlatStyle = "Flat"; $btnAction.Cursor = [System.Windows.Forms.Cursors]::Hand; $form.Controls.Add($btnAction)

$footerLabel = New-Object System.Windows.Forms.Label; $footerLabel.Text = "Developed by IT Groceries Shop"; $footerLabel.Font = $fontFooter; $footerLabel.ForeColor = "#666666"; $footerLabel.AutoSize = $false; $footerLabel.Size = New-Object System.Drawing.Size(500, 30); $footerLabel.Location = New-Object System.Drawing.Point(0, 250); $footerLabel.TextAlign = "MiddleCenter"; $form.Controls.Add($footerLabel)

# --- MAIN LOGIC ---
$btnAction.Add_Click({
    if ($btnAction.Text -eq "Close") { $form.Close(); return }
    if ($browserDropdown.Items.Count -eq 0) { [System.Windows.Forms.MessageBox]::Show("No compatible browser found!", "Error", "OK", "Error"); return }

    $btnAction.Enabled = $false
    $statusLabel.Text = "Creating Shortcut..."
    
    try {
        # 1. Prepare Variables
        $Selection = $browserDropdown.SelectedItem.ToString()
        $TargetBrowser = $null
        $BrowserExe = ""
        
        # Select Browser Path
        if ($Selection -eq "Brave Browser") { 
            $TargetBrowser = $BravePath; $BrowserExe = "brave.exe"
        } elseif ($Selection -eq "Google Chrome") { 
            $TargetBrowser = $ChromePath; $BrowserExe = "chrome.exe"
        } elseif ($Selection -eq "Microsoft Edge") {
            if (Test-Path $EdgePathX64) { $TargetBrowser = $EdgePathX64 } else { $TargetBrowser = $EdgePathX86 }
            $BrowserExe = "msedge.exe"
        }

        # 2. Create Shortcut
        $WScript = New-Object -ComObject WScript.Shell
        $s = $WScript.CreateShortcut($ShortcutPath)
        
        # Universal Killer Logic (CMD Wrapper)
        $s.TargetPath = "cmd.exe"
        $CmdArgs = "/c taskkill /f /im $BrowserExe /t >nul 2>&1 & start `"`" `"$TargetBrowser`" --profile-directory=Default --app=$ForceURL --user-agent=`"$UA_Universal`" --start-maximized $BackgroundFlags"
        $s.Arguments = $CmdArgs
        $s.WindowStyle = 7 # Minimized
        $s.Description = "From $Selection (Tizen 9.0)"

        # 3. Apply Icon
        if (Test-Path $IconPath) { $s.IconLocation = $IconPath }
        
        # 4. Save
        $s.Save()

        $statusLabel.Text = "Success! Shortcut created on Desktop."
        $statusLabel.ForeColor = "#00ff00"
        $btnAction.Text = "Close"; $btnAction.Enabled = $true; $btnAction.BackColor = "#006600"
        
    } catch {
        $statusLabel.Text = "Error: $_"; $statusLabel.ForeColor = "Red"; $btnAction.Enabled = $true
    }
})

$form.ShowDialog() | Out-Null
