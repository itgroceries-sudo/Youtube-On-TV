<# :
@echo off
:: ✅ Code: Hybrid Script" (Polyglot) 🧬
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Get-Content -LiteralPath '%~f0' | Out-String | Invoke-Expression"
goto :EOF
: #>

# ==================================================================================
#  📺 YouTube TV Desktop Installer v7.1 (Multi-Instance Edition)
#  Engine: Tizen 9.0 (2025) | Naming: Dynamic per Browser
# ==================================================================================

# 1. PARAMETER BLOCK
param(
    [string]$Browser = "Ask",
    [switch]$Silent
)

# 2. HIDE CONSOLE (Ninja Mode)
if (-not $Silent) {
    $Win32 = Add-Type -MemberDefinition '[DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow(); [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);' -Name "Win32" -Namespace Win32 -PassThru
    $ConsolePtr = $Win32::GetConsoleWindow()
    if ($ConsolePtr -ne [IntPtr]::Zero) { $Win32::ShowWindow($ConsolePtr, 0) }
}

# 3. CONFIGURATION
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$DesktopPath = [System.Environment]::GetFolderPath('Desktop')
$IconPath = "$env:APPDATA\YoutubeTV_Icon.ico"
$IconUrl = "https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/refs/heads/main/YouTube.ico"
$ForceURL = "https://youtube.com/tv"

# --- ENGINE ---
$UA_Universal = "Mozilla/5.0 (SMART-TV; LINUX; Tizen 9.0) AppleWebKit/537.36 (KHTML, like Gecko) 120.0.6099.5/9.0 TV Safari/537.36"
$BackgroundFlags = "--disable-features=CalculateNativeWinOcclusion --disable-background-timer-throttling --disable-renderer-backgrounding --disable-backgrounding-occluded-windows"

# --- PATHS ---
$BravePath = "$env:ProgramFiles\BraveSoftware\Brave-Browser\Application\brave.exe"
$ChromePath = "$env:ProgramFiles\Google\Chrome\Application\chrome.exe"
$EdgePathX86 = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
$EdgePathX64 = "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"

# 4. INSTALL FUNCTION (Dynamic Naming)
function Install-TVMode ($TargetBrowserName, $TargetExeName, $TargetFullPath, $ShortNameSuffix) {
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
        # --- DYNAMIC SHORTCUT NAME ---
        # Filename changes based on browser, e.g., "Youtube On TV - Chrome.lnk"
        $DynamicName = "Youtube On TV - $ShortNameSuffix.lnk"
        $CurrentShortcutPath = Join-Path $DesktopPath $DynamicName

        $WScript = New-Object -ComObject WScript.Shell
        $s = $WScript.CreateShortcut($CurrentShortcutPath)
        
        $s.TargetPath = "cmd.exe"
        $CmdArgs = "/c taskkill /f /im $TargetExeName /t >nul 2>&1 & start `"`" `"$TargetFullPath`" --profile-directory=Default --app=$ForceURL --user-agent=`"$UA_Universal`" --start-maximized $BackgroundFlags"
        $s.Arguments = $CmdArgs
        $s.WindowStyle = 7
        $s.Description = "TV Mode for $TargetBrowserName"
        
        if (Test-Path $IconPath) { $s.IconLocation = $IconPath }
        $s.Save()

        if (-not $Silent) { 
            # Play a short beep to indicate completion (since the program stays open)
            [System.Console]::Beep(1000, 200) 
            return $true
        } else {
            Write-Host " [OK] Installed: $DynamicName" -ForegroundColor Green
        }
    } catch {
        if (-not $Silent) { [System.Windows.Forms.MessageBox]::Show("Error: $_", "Error") }
        return $false
    }
}

# 5. LOGIC SWITCHER (CLI)
if ($Browser -ne "Ask") {
    if ($Browser -match "Edge") { 
        if (Test-Path $EdgePathX64) { Install-TVMode "Microsoft Edge" "msedge.exe" $EdgePathX64 "Edge" } else { Install-TVMode "Microsoft Edge" "msedge.exe" $EdgePathX86 "Edge" }
    }
    elseif ($Browser -match "Chrome") { Install-TVMode "Google Chrome" "chrome.exe" $ChromePath "Chrome" }
    elseif ($Browser -match "Brave") { Install-TVMode "Brave Browser" "brave.exe" $BravePath "Brave" }
    exit
}

# --- GUI MODE (Multi-Install Interface) ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "YouTube TV Installer (Multi-Instance)"
$form.Size = New-Object System.Drawing.Size(500, 360) # Increased height for Exit button
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = "#1e1e1e"

try { $form.Icon = New-Object System.Drawing.Icon($IconPath) } catch {}

$fontHeader = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
$fontBody = New-Object System.Drawing.Font("Segoe UI", 10)
$fontBold = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$fontFooter = New-Object System.Drawing.Font("Consolas", 8)

# Header
$headerPanel = New-Object System.Windows.Forms.Panel; $headerPanel.Size = New-Object System.Drawing.Size(500, 60); $headerPanel.Location = New-Object System.Drawing.Point(0, 0); $headerPanel.BackColor = "#cc0000"
$headerLabel = New-Object System.Windows.Forms.Label; $headerLabel.Text = "YouTube TV Installer"; $headerLabel.Font = $fontHeader; $headerLabel.ForeColor = "White"; $headerLabel.AutoSize = $false; $headerLabel.Size = New-Object System.Drawing.Size(500, 60); $headerLabel.TextAlign = "MiddleCenter"
$headerPanel.Controls.Add($headerLabel); $form.Controls.Add($headerPanel)

# Status
$statusLabel = New-Object System.Windows.Forms.Label; $statusLabel.Text = "Select browser(s) to install shortcuts."; $statusLabel.Font = $fontBody; $statusLabel.ForeColor = "#dddddd"; $statusLabel.AutoSize = $false; $statusLabel.Size = New-Object System.Drawing.Size(480, 30); $statusLabel.Location = New-Object System.Drawing.Point(10, 70); $statusLabel.TextAlign = "MiddleCenter"; $form.Controls.Add($statusLabel)

# Dropdown
$browserLabel = New-Object System.Windows.Forms.Label; $browserLabel.Text = "Target:"; $browserLabel.Font = $fontBold; $browserLabel.ForeColor = "#00ccff"; $browserLabel.AutoSize = $true; $browserLabel.Location = New-Object System.Drawing.Point(140, 115); $form.Controls.Add($browserLabel)

$browserDropdown = New-Object System.Windows.Forms.ComboBox; $browserDropdown.Size = New-Object System.Drawing.Size(180, 30); $browserDropdown.Location = New-Object System.Drawing.Point(200, 112); $browserDropdown.DropDownStyle = "DropDownList"; $browserDropdown.BackColor = "#333333"; $browserDropdown.ForeColor = "White"; $browserDropdown.Font = $fontBody

if (Test-Path $BravePath) { $browserDropdown.Items.Add("Brave Browser") | Out-Null }
if (Test-Path $ChromePath) { $browserDropdown.Items.Add("Google Chrome") | Out-Null }
if (Test-Path $EdgePathX64) { $browserDropdown.Items.Add("Microsoft Edge") | Out-Null } elseif (Test-Path $EdgePathX86) { $browserDropdown.Items.Add("Microsoft Edge") | Out-Null }

if ($browserDropdown.Items.Count -gt 0) { $browserDropdown.SelectedIndex = 0 }
$form.Controls.Add($browserDropdown)

# --- BUTTONS ---
# Create Button (Green)
$btnCreate = New-Object System.Windows.Forms.Button; $btnCreate.Text = "Create Shortcut"; $btnCreate.Font = $fontBold; $btnCreate.Size = New-Object System.Drawing.Size(180, 45); $btnCreate.Location = New-Object System.Drawing.Point(80, 170); $btnCreate.BackColor = "#006600"; $btnCreate.ForeColor = "White"; $btnCreate.FlatStyle = "Flat"; $btnCreate.Cursor = [System.Windows.Forms.Cursors]::Hand; $form.Controls.Add($btnCreate)

# Exit Button (Red)
$btnExit = New-Object System.Windows.Forms.Button; $btnExit.Text = "Exit"; $btnExit.Font = $fontBold; $btnExit.Size = New-Object System.Drawing.Size(120, 45); $btnExit.Location = New-Object System.Drawing.Point(280, 170); $btnExit.BackColor = "#990000"; $btnExit.ForeColor = "White"; $btnExit.FlatStyle = "Flat"; $btnExit.Cursor = [System.Windows.Forms.Cursors]::Hand; $form.Controls.Add($btnExit)

$footerLabel = New-Object System.Windows.Forms.Label; $footerLabel.Text = "Developed by IT Groceries Shop"; $footerLabel.Font = $fontFooter; $footerLabel.ForeColor = "#666666"; $footerLabel.AutoSize = $false; $footerLabel.Size = New-Object System.Drawing.Size(500, 30); $footerLabel.Location = New-Object System.Drawing.Point(0, 280); $footerLabel.TextAlign = "MiddleCenter"; $form.Controls.Add($footerLabel)

# --- EVENTS ---

# Exit Button -> Close Application
$btnExit.Add_Click({ $form.Close() })

# Create Button -> Create Shortcut without closing
$btnCreate.Add_Click({
    if ($browserDropdown.Items.Count -eq 0) { [System.Windows.Forms.MessageBox]::Show("No compatible browser found!", "Error"); return }

    $btnCreate.Enabled = $false
    $statusLabel.Text = "Installing..."
    $form.Refresh() # Force redraw the UI immediately

    $Selection = $browserDropdown.SelectedItem.ToString()
    $Result = $false

    if ($Selection -match "Brave") { $Result = Install-TVMode "Brave Browser" "brave.exe" $BravePath "Brave" }
    elseif ($Selection -match "Chrome") { $Result = Install-TVMode "Google Chrome" "chrome.exe" $ChromePath "Chrome" }
    elseif ($Selection -match "Edge") { if (Test-Path $EdgePathX64) { $Result = Install-TVMode "Microsoft Edge" "msedge.exe" $EdgePathX64 "Edge" } else { $Result = Install-TVMode "Microsoft Edge" "msedge.exe" $EdgePathX86 "Edge" } }

    # Reset state after creation to allow further actions
    if ($Result) {
        $statusLabel.Text = "Success! Created: Youtube On TV - $Selection"
        $statusLabel.ForeColor = "#00ff00"
    }
    
    Start-Sleep -Milliseconds 500
    $btnCreate.Enabled = $true
})

$form.ShowDialog() | Out-Null
