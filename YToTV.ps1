<# :
@echo off
:: ✅ Code: Polite Installer
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Get-Content -LiteralPath '%~f0' | Out-String | Invoke-Expression"
goto :EOF
: #>

# ==================================================================================
#  📺 YouTube TV Desktop Installer v7.0 (Ultimate Edition)
#  Engine: Tizen 9.0 (2025) | Mode: Hybrid (GUI + CLI)
# ==================================================================================

# 1. PARAMETER BLOCK (ส่วนรับคำสั่งเท่ๆ)
param(
    [string]$Browser = "Ask",  # Ask, Edge, Chrome, Brave
    [switch]$Silent            # Run without GUI popup at the end
)

# 2. HIDE CONSOLE (Ninja Mode)
if (-not $Silent) {
    $Win32 = Add-Type -MemberDefinition '[DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow(); [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);' -Name "Win32" -Namespace Win32 -PassThru
    $ConsolePtr = $Win32::GetConsoleWindow()
    if ($ConsolePtr -ne [IntPtr]::Zero) { $Win32::ShowWindow($ConsolePtr, 0) }
}

# 3. CONFIGURATION & ENGINE
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ShortcutName = "Youtube On TV.lnk"
$ForceURL = "https://youtube.com/tv"
$DesktopPath = [System.Environment]::GetFolderPath('Desktop')
$ShortcutPath = Join-Path $DesktopPath $ShortcutName
$IconPath = "$env:APPDATA\YoutubeTV_Icon.ico"
$IconUrl = "https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/refs/heads/main/YouTube.ico"

# --- TIZEN 9.0 ENGINE (2025) ---
$UA_Universal = "Mozilla/5.0 (SMART-TV; LINUX; Tizen 9.0) AppleWebKit/537.36 (KHTML, like Gecko) 120.0.6099.5/9.0 TV Safari/537.36"
$BackgroundFlags = "--disable-features=CalculateNativeWinOcclusion --disable-background-timer-throttling --disable-renderer-backgrounding --disable-backgrounding-occluded-windows"

# --- BROWSER PATHS ---
$BravePath = "$env:ProgramFiles\BraveSoftware\Brave-Browser\Application\brave.exe"
$ChromePath = "$env:ProgramFiles\Google\Chrome\Application\chrome.exe"
$EdgePathX86 = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
$EdgePathX64 = "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"

# 4. FUNCTION: CORE INSTALLER
function Install-TVMode ($TargetBrowserName, $TargetExeName, $TargetFullPath) {
    if (-not (Test-Path $TargetFullPath)) { 
        if (-not $Silent) { [System.Windows.Forms.MessageBox]::Show("$TargetBrowserName not found!", "Error", "OK", "Error") }
        return 
    }

    try {
        # Download Icon
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        if (-not (Test-Path $IconPath)) { (New-Object System.Net.WebClient).DownloadFile($IconUrl, $IconPath) }
    } catch {}

    try {
        $WScript = New-Object -ComObject WScript.Shell
        $s = $WScript.CreateShortcut($ShortcutPath)
        
        # Universal Killer Logic
        $s.TargetPath = "cmd.exe"
        $CmdArgs = "/c taskkill /f /im $TargetExeName /t >nul 2>&1 & start `"`" `"$TargetFullPath`" --profile-directory=Default --app=$ForceURL --user-agent=`"$UA_Universal`" --start-maximized $BackgroundFlags"
        $s.Arguments = $CmdArgs
        $s.WindowStyle = 7
        $s.Description = "From $TargetBrowserName (TV Mode)"
        
        if (Test-Path $IconPath) { $s.IconLocation = $IconPath }
        $s.Save()

        if (-not $Silent) { 
            [System.Windows.Forms.MessageBox]::Show("Success! YouTube TV installed for $TargetBrowserName", "Success") 
        } else {
            Write-Host " [OK] Installed for $TargetBrowserName" -ForegroundColor Green
        }
    } catch {
        if (-not $Silent) { [System.Windows.Forms.MessageBox]::Show("Error: $_", "Error") }
    }
}

# 5. LOGIC SWITCHER
if ($Browser -ne "Ask") {
    # --- AUTOMATION MODE (Hackerman Style) ---
    if ($Browser -match "Edge") { 
        if (Test-Path $EdgePathX64) { Install-TVMode "Microsoft Edge" "msedge.exe" $EdgePathX64 } else { Install-TVMode "Microsoft Edge" "msedge.exe" $EdgePathX86 }
    }
    elseif ($Browser -match "Chrome") { Install-TVMode "Google Chrome" "chrome.exe" $ChromePath }
    elseif ($Browser -match "Brave") { Install-TVMode "Brave Browser" "brave.exe" $BravePath }
    else { Write-Host "Unknown Browser: $Browser" -ForegroundColor Red }
    exit
}

# --- GUI MODE (User Friendly) ---
# (ทำงานเมื่อ User รันแบบปกติ ไม่ใส่ Parameter)
$form = New-Object System.Windows.Forms.Form
$form.Text = "YouTube TV Installer (v7.0)"
$form.Size = New-Object System.Drawing.Size(500, 320)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = "#1e1e1e"

try { $form.Icon = New-Object System.Drawing.Icon($IconPath) } catch {}

$fontHeader = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
$fontBody = New-Object System.Drawing.Font("Segoe UI", 10)
$fontBold = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$fontFooter = New-Object System.Drawing.Font("Consolas", 8)

$headerPanel = New-Object System.Windows.Forms.Panel; $headerPanel.Size = New-Object System.Drawing.Size(500, 60); $headerPanel.Location = New-Object System.Drawing.Point(0, 0); $headerPanel.BackColor = "#cc0000"
$headerLabel = New-Object System.Windows.Forms.Label; $headerLabel.Text = "YouTube TV Installer"; $headerLabel.Font = $fontHeader; $headerLabel.ForeColor = "White"; $headerLabel.AutoSize = $false; $headerLabel.Size = New-Object System.Drawing.Size(500, 60); $headerLabel.TextAlign = "MiddleCenter"
$headerPanel.Controls.Add($headerLabel); $form.Controls.Add($headerPanel)

$statusLabel = New-Object System.Windows.Forms.Label; $statusLabel.Text = "Select your browser to create shortcut"; $statusLabel.Font = $fontBody; $statusLabel.ForeColor = "#dddddd"; $statusLabel.AutoSize = $false; $statusLabel.Size = New-Object System.Drawing.Size(480, 30); $statusLabel.Location = New-Object System.Drawing.Point(10, 70); $statusLabel.TextAlign = "MiddleCenter"; $form.Controls.Add($statusLabel)

$browserLabel = New-Object System.Windows.Forms.Label; $browserLabel.Text = "Browser:"; $browserLabel.Font = $fontBold; $browserLabel.ForeColor = "#00ccff"; $browserLabel.AutoSize = $true; $browserLabel.Location = New-Object System.Drawing.Point(140, 115); $form.Controls.Add($browserLabel)

$browserDropdown = New-Object System.Windows.Forms.ComboBox; $browserDropdown.Size = New-Object System.Drawing.Size(180, 30); $browserDropdown.Location = New-Object System.Drawing.Point(210, 112); $browserDropdown.DropDownStyle = "DropDownList"; $browserDropdown.BackColor = "#333333"; $browserDropdown.ForeColor = "White"; $browserDropdown.Font = $fontBody

if (Test-Path $BravePath) { $browserDropdown.Items.Add("Brave Browser") | Out-Null }
if (Test-Path $ChromePath) { $browserDropdown.Items.Add("Google Chrome") | Out-Null }
if (Test-Path $EdgePathX64) { $browserDropdown.Items.Add("Microsoft Edge") | Out-Null } elseif (Test-Path $EdgePathX86) { $browserDropdown.Items.Add("Microsoft Edge") | Out-Null }

if ($browserDropdown.Items.Count -gt 0) { $browserDropdown.SelectedIndex = 0 }
$form.Controls.Add($browserDropdown)

$btnAction = New-Object System.Windows.Forms.Button; $btnAction.Text = "Create Shortcut"; $btnAction.Font = $fontBold; $btnAction.Size = New-Object System.Drawing.Size(200, 50); $btnAction.Location = New-Object System.Drawing.Point(150, 160); $btnAction.BackColor = "#333333"; $btnAction.ForeColor = "White"; $btnAction.FlatStyle = "Flat"; $btnAction.Cursor = [System.Windows.Forms.Cursors]::Hand; $form.Controls.Add($btnAction)

$footerLabel = New-Object System.Windows.Forms.Label; $footerLabel.Text = "Developed by IT Groceries Shop"; $footerLabel.Font = $fontFooter; $footerLabel.ForeColor = "#666666"; $footerLabel.AutoSize = $false; $footerLabel.Size = New-Object System.Drawing.Size(500, 30); $footerLabel.Location = New-Object System.Drawing.Point(0, 250); $footerLabel.TextAlign = "MiddleCenter"; $form.Controls.Add($footerLabel)

$btnAction.Add_Click({
    if ($btnAction.Text -eq "Close") { $form.Close(); return }
    if ($browserDropdown.Items.Count -eq 0) { [System.Windows.Forms.MessageBox]::Show("No compatible browser found!", "Error"); return }

    $btnAction.Enabled = $false; $statusLabel.Text = "Creating Shortcut..."
    
    $Selection = $browserDropdown.SelectedItem.ToString()
    if ($Selection -match "Brave") { Install-TVMode "Brave Browser" "brave.exe" $BravePath }
    elseif ($Selection -match "Chrome") { Install-TVMode "Google Chrome" "chrome.exe" $ChromePath }
    elseif ($Selection -match "Edge") { if (Test-Path $EdgePathX64) { Install-TVMode "Microsoft Edge" "msedge.exe" $EdgePathX64 } else { Install-TVMode "Microsoft Edge" "msedge.exe" $EdgePathX86 } }
    
    $statusLabel.Text = "Success! Shortcut created."; $statusLabel.ForeColor = "#00ff00"; $btnAction.Text = "Close"; $btnAction.Enabled = $true; $btnAction.BackColor = "#006600"
})

$form.ShowDialog() | Out-Null
