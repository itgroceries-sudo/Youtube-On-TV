<# :
@echo off
:: ---------------------------------------------------------
:: [WRAPPER] Batch Launcher
:: ---------------------------------------------------------
setlocal
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
$NewShortcutName = "Youtube On TV.lnk"
$ShortcutPattern = "YouTube*.lnk"
$ForceURL = "https://youtube.com/tv"
$DesktopPath = [System.Environment]::GetFolderPath('Desktop')

# --- USER AGENTS ---
# 1. LG WebOS (For Chrome & Brave)
$UA_LG = "Mozilla/5.0 (Web0S; Linux/SmartTV) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.5735.199 Safari/537.36 WebAppManager"

# 2. Samsung Tizen 7.0 (For Edge)
$UA_Samsung = "Mozilla/5.0 (SMART-TV; LINUX; Tizen 7.0) AppleWebKit/537.36 (KHTML, like Gecko) 94.0.4606.31/7.0 TV Safari/537.36"

# --- BACKGROUND PLAY FLAGS (Anti-Freeze) ---
$BackgroundFlags = "--disable-features=CalculateNativeWinOcclusion --disable-background-timer-throttling"

# --- ITG ICON ---
$IconUrl = "https://itgroceries.blogspot.com/favicon.ico"
$IconTempPath = "$env:TEMP\itg_gui_icon.ico"

# --- DETECT BROWSERS ---
$BravePath = "$env:ProgramFiles\BraveSoftware\Brave-Browser\Application\brave.exe"
$ChromePath = "$env:ProgramFiles\Google\Chrome\Application\chrome.exe"
$EdgePathX86 = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
$EdgePathX64 = "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"

# --- FORM SETUP ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "YouTube TV Installer"
$form.Size = New-Object System.Drawing.Size(500, 380)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = "#1e1e1e"

# Load Window Icon
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    if (-not (Test-Path $IconTempPath)) { (New-Object System.Net.WebClient).DownloadFile($IconUrl, $IconTempPath) }
    $form.Icon = New-Object System.Drawing.Icon($IconTempPath)
} catch {}

# --- GUI LAYOUT ---
$fontHeader = New-Object System.Drawing.Font("Segoe UI", 15, [System.Drawing.FontStyle]::Bold)
$fontBody = New-Object System.Drawing.Font("Segoe UI", 10)
$fontBold = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$fontFooter = New-Object System.Drawing.Font("Consolas", 8)

$headerPanel = New-Object System.Windows.Forms.Panel; $headerPanel.Size = New-Object System.Drawing.Size(500, 60); $headerPanel.Location = New-Object System.Drawing.Point(0, 0); $headerPanel.BackColor = "#cc0000"
$headerLabel = New-Object System.Windows.Forms.Label; $headerLabel.Text = "YouTube TV Installer"; $headerLabel.Font = $fontHeader; $headerLabel.ForeColor = "White"; $headerLabel.AutoSize = $false; $headerLabel.Size = New-Object System.Drawing.Size(500, 60); $headerLabel.TextAlign = "MiddleCenter"
$headerPanel.Controls.Add($headerLabel); $form.Controls.Add($headerPanel)

$statusLabel = New-Object System.Windows.Forms.Label; $statusLabel.Text = "Status: Please select a browser"; $statusLabel.Font = $fontBody; $statusLabel.ForeColor = "#dddddd"; $statusLabel.AutoSize = $false; $statusLabel.Size = New-Object System.Drawing.Size(480, 30); $statusLabel.Location = New-Object System.Drawing.Point(10, 70); $statusLabel.TextAlign = "MiddleCenter"; $form.Controls.Add($statusLabel)

# --- DROPDOWN (COMBOBOX) ---
$browserLabel = New-Object System.Windows.Forms.Label
$browserLabel.Text = "Select Browser:"
$browserLabel.Font = $fontBold
$browserLabel.ForeColor = "#00ccff"
$browserLabel.AutoSize = $true
$browserLabel.Location = New-Object System.Drawing.Point(130, 105)
$form.Controls.Add($browserLabel)

$browserDropdown = New-Object System.Windows.Forms.ComboBox
$browserDropdown.Size = New-Object System.Drawing.Size(180, 30)
$browserDropdown.Location = New-Object System.Drawing.Point(240, 102)
$browserDropdown.DropDownStyle = "DropDownList"
$browserDropdown.BackColor = "#333333"
$browserDropdown.ForeColor = "White"
$browserDropdown.Font = $fontBody

# Populate Dropdown
if (Test-Path $BravePath) { $browserDropdown.Items.Add("Brave Browser") | Out-Null }
if (Test-Path $ChromePath) { $browserDropdown.Items.Add("Google Chrome") | Out-Null }
if (Test-Path $EdgePathX64) { $browserDropdown.Items.Add("Microsoft Edge") | Out-Null }
elseif (Test-Path $EdgePathX86) { $browserDropdown.Items.Add("Microsoft Edge") | Out-Null }

if ($browserDropdown.Items.Count -gt 0) { $browserDropdown.SelectedIndex = 0 }

$form.Controls.Add($browserDropdown)

$instructionLabel = New-Object System.Windows.Forms.Label
$instructionLabel.Text = "(1) Click to Install Youtube On Apps (Address Bar).`n(2) Close Browser and Youtube Apps immediately.`nThen wait for the script to finish."
$instructionLabel.Font = $fontBody; $instructionLabel.ForeColor = "#aaaaaa"; $instructionLabel.AutoSize = $false; $instructionLabel.Size = New-Object System.Drawing.Size(480, 70); $instructionLabel.Location = New-Object System.Drawing.Point(10, 145); $instructionLabel.TextAlign = "MiddleCenter"
$form.Controls.Add($instructionLabel)

$btnAction = New-Object System.Windows.Forms.Button; $btnAction.Text = "Start Install"; $btnAction.Font = $fontBold; $btnAction.Size = New-Object System.Drawing.Size(200, 50); $btnAction.Location = New-Object System.Drawing.Point(150, 225); $btnAction.BackColor = "#333333"; $btnAction.ForeColor = "White"; $btnAction.FlatStyle = "Flat"; $btnAction.Cursor = [System.Windows.Forms.Cursors]::Hand; $form.Controls.Add($btnAction)

$footerLabel = New-Object System.Windows.Forms.Label; $footerLabel.Text = "Developed by IT Groceries Shop"; $footerLabel.Font = $fontFooter; $footerLabel.ForeColor = "#666666"; $footerLabel.AutoSize = $false; $footerLabel.Size = New-Object System.Drawing.Size(500, 30); $footerLabel.Location = New-Object System.Drawing.Point(0, 310); $footerLabel.TextAlign = "MiddleCenter"; $form.Controls.Add($footerLabel)

$timer = New-Object System.Windows.Forms.Timer; $timer.Interval = 1500

# --- VARIABLES (Script Scope) ---
$script:TargetBrowserPath = $null
$script:TargetUA = $null

# --- MAIN LOGIC ---
$btnAction.Add_Click({
    if ($btnAction.Text -eq "Close") { $form.Close(); return }
    if ($browserDropdown.Items.Count -eq 0) { [System.Windows.Forms.MessageBox]::Show("No compatible browser found!", "Error", "OK", "Error"); return }

    # Determine Selected Browser & UA
    $Selection = $browserDropdown.SelectedItem.ToString()
    
    if ($Selection -eq "Brave Browser") {
        $script:TargetBrowserPath = $BravePath
        $script:TargetUA = $UA_LG
    } elseif ($Selection -eq "Google Chrome") {
        $script:TargetBrowserPath = $ChromePath
        $script:TargetUA = $UA_LG
    } elseif ($Selection -eq "Microsoft Edge") {
        if (Test-Path $EdgePathX64) { $script:TargetBrowserPath = $EdgePathX64 } else { $script:TargetBrowserPath = $EdgePathX86 }
        $script:TargetUA = $UA_Samsung
        
        # [KILL EDGE - First Run Only] Ensure fresh start for UA to work
        $statusLabel.Text = "Closing Edge processes..."
        [System.Windows.Forms.Application]::DoEvents()
        Stop-Process -Name "msedge" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }

    Start-Process -FilePath $script:TargetBrowserPath -ArgumentList "https://www.youtube.com"
    
    $btnAction.Enabled = $false; $btnAction.Text = "Waiting..."; $statusLabel.Text = "Waiting for User Action..."; $statusLabel.ForeColor = "Yellow"; $timer.Start()
})

$timer.Add_Tick({
    $FoundFile = Get-ChildItem -Path $DesktopPath -Filter $ShortcutPattern | Where-Object { $_.Name -ne $NewShortcutName } | Select-Object -First 1
    
    if ($null -ne $FoundFile) {
        $timer.Stop()
        $statusLabel.Text = "File Detected! Processing..."
        
        Start-Sleep -Seconds 3
        
        try {
            $WScript = New-Object -ComObject WScript.Shell
            
            # 1. Rename
            $NewFullPath = Join-Path $DesktopPath $NewShortcutName
            if (Test-Path $NewFullPath) { Remove-Item $NewFullPath -Force }
            Rename-Item -Path $FoundFile.FullName -NewName $NewShortcutName
            
            # 2. Modify
            $s = $WScript.CreateShortcut($NewFullPath)
            $OriginalIcon = $s.IconLocation
            
            # Check if this is Edge
            $IsEdgeBrowser = $script:TargetBrowserPath -match "msedge.exe"
            
            # --- SPECIAL LOGIC FOR EDGE (KILLER SHORTCUT) ---
            if ($IsEdgeBrowser) {
                # Target: CMD to kill Edge first, then launch with args
                $s.TargetPath = "cmd.exe"
                # Combine: Kill -> Launch -> Args -> Background Flags
                $CmdArgs = "/c taskkill /f /im msedge.exe /t >nul 2>&1 & start `"`" `"$script:TargetBrowserPath`" --profile-directory=Default --app=$ForceURL --user-agent=`"$($script:TargetUA)`" --start-maximized $BackgroundFlags"
                $s.Arguments = $CmdArgs
                
                # Use Original Icon (Red YouTube)
                $s.IconLocation = $OriginalIcon
                $s.WindowStyle = 7 # Minimized CMD window
            } 
            else {
                # --- STANDARD LOGIC FOR CHROME/BRAVE ---
                # Fix Target Path (Proxy -> Exe)
                $Target = $s.TargetPath
                if ($Target -match "brave_proxy.exe") { $Target = $Target -replace "brave_proxy.exe", "brave.exe" }
                elseif ($Target -match "chrome_proxy.exe") { $Target = $Target -replace "chrome_proxy.exe", "chrome.exe" }
                elseif ($Target -match "_proxy.exe") { $Target = $Target -replace "_proxy.exe", ".exe" }
                
                if (Test-Path $Target) { $s.TargetPath = $Target } else { $s.TargetPath = $script:TargetBrowserPath }

                # Inject Arguments + Background Flags
                $NewArgs = "--app=$ForceURL --user-agent=`"$($script:TargetUA)`" --start-maximized $BackgroundFlags"
                if ($s.Arguments -match "(--profile-directory=[^ ]+)") { $ProfileArg = $matches[1]; $NewArgs = "$ProfileArg $NewArgs" }
                $s.Arguments = $NewArgs
                
                # Restore Icon
                $s.IconLocation = $OriginalIcon
            }
            
            $s.Save()

            # 3. Cleanup
            Start-Sleep -Seconds 1
            $GhostFiles = Get-ChildItem -Path $DesktopPath -Filter $ShortcutPattern | Where-Object { $_.Name -ne $NewShortcutName }
            if ($GhostFiles) { foreach ($g in $GhostFiles) { Remove-Item $g.FullName -Force } }

            # Finish
            $statusLabel.Text = "Installation Complete!"
            $statusLabel.ForeColor = "#00ff00"
            $instructionLabel.Text = "Shortcut created on Desktop.`n(Edge shortcut will auto-close old processes)"
            $btnAction.Text = "Close"; $btnAction.Enabled = $true; $btnAction.BackColor = "#006600"
            
        } catch {
            $statusLabel.Text = "Error: $_"; $statusLabel.ForeColor = "Red"; $timer.Stop(); $btnAction.Enabled = $true
        }
    }
})

$form.ShowDialog() | Out-Null
