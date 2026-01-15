<# :
@echo off
:: ---------------------------------------------------------
:: Batch Wrapper (Stable)
:: ---------------------------------------------------------
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "iex ((Get-Content '%~f0') -join \"`n\")"
if %errorlevel% NEQ 0 ( echo [ERROR] Script failed. & pause )
goto :EOF
: #>

# ---------------------------------------------------------
# PowerShell GUI Script
# ---------------------------------------------------------
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- CONFIGURATION ---
$NewShortcutName = "Youtube On TV.lnk"
$ShortcutPattern = "YouTube*.lnk"
$UserAgentString = "Mozilla/5.0 (Web0S; Linux/SmartTV) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.5735.199 Safari/537.36 WebAppManager"
$ForceURL = "https://youtube.com/tv"
$DesktopPath = [System.Environment]::GetFolderPath('Desktop')

# --- ITG ICON (GUI Title Only) ---
$IconUrl = "https://itgroceries.blogspot.com/favicon.ico"
$IconTempPath = "$env:TEMP\itg_gui_icon.ico"

# --- DETECT BROWSER ---
$BravePath = "$env:ProgramFiles\BraveSoftware\Brave-Browser\Application\brave.exe"
$ChromePath = "$env:ProgramFiles\Google\Chrome\Application\chrome.exe"
$SelectedBrowser = $null
$BrowserName = "Unknown"

if (Test-Path $BravePath) { 
    $SelectedBrowser = $BravePath
    $BrowserName = "Brave Browser"
} elseif (Test-Path $ChromePath) { 
    $SelectedBrowser = $ChromePath
    $BrowserName = "Google Chrome"
}

# --- FORM SETUP ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "YouTube TV Installer"
$form.Size = New-Object System.Drawing.Size(500, 380) # Increased height to fit text
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = "#1e1e1e"

# Load ITG Icon
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

$statusLabel = New-Object System.Windows.Forms.Label; $statusLabel.Text = "Status: Ready to install"; $statusLabel.Font = $fontBody; $statusLabel.ForeColor = "#dddddd"; $statusLabel.AutoSize = $false; $statusLabel.Size = New-Object System.Drawing.Size(480, 30); $statusLabel.Location = New-Object System.Drawing.Point(10, 80); $statusLabel.TextAlign = "MiddleCenter"; $form.Controls.Add($statusLabel)
$infoLabel = New-Object System.Windows.Forms.Label; $infoLabel.Text = "Detected: $BrowserName"; $infoLabel.Font = $fontBold; $infoLabel.ForeColor = "#00ccff"; $infoLabel.AutoSize = $false; $infoLabel.Size = New-Object System.Drawing.Size(480, 30); $infoLabel.Location = New-Object System.Drawing.Point(10, 110); $infoLabel.TextAlign = "MiddleCenter"; $form.Controls.Add($infoLabel)

# [KEY UPDATE] Customized instruction text
$instructionLabel = New-Object System.Windows.Forms.Label
$instructionLabel.Text = "(1) Click to Install Youtube On Apps (Address Bar).`n(2) Close Browser and Youtube Apps immediately.`nThen wait for the script to finish."
$instructionLabel.Font = $fontBody
$instructionLabel.ForeColor = "#aaaaaa"
$instructionLabel.AutoSize = $false
$instructionLabel.Size = New-Object System.Drawing.Size(480, 70) # Increased height
$instructionLabel.Location = New-Object System.Drawing.Point(10, 145)
$instructionLabel.TextAlign = "MiddleCenter"
$form.Controls.Add($instructionLabel)

$btnAction = New-Object System.Windows.Forms.Button; $btnAction.Text = "Start Install"; $btnAction.Font = $fontBold; $btnAction.Size = New-Object System.Drawing.Size(200, 50); $btnAction.Location = New-Object System.Drawing.Point(150, 225); $btnAction.BackColor = "#333333"; $btnAction.ForeColor = "White"; $btnAction.FlatStyle = "Flat"; $btnAction.Cursor = [System.Windows.Forms.Cursors]::Hand; $form.Controls.Add($btnAction)

$footerLabel = New-Object System.Windows.Forms.Label; $footerLabel.Text = "Developed by IT Groceries Shop"; $footerLabel.Font = $fontFooter; $footerLabel.ForeColor = "#666666"; $footerLabel.AutoSize = $false; $footerLabel.Size = New-Object System.Drawing.Size(500, 30); $footerLabel.Location = New-Object System.Drawing.Point(0, 310); $footerLabel.TextAlign = "MiddleCenter"; $form.Controls.Add($footerLabel)

$timer = New-Object System.Windows.Forms.Timer; $timer.Interval = 1500

# --- MAIN LOGIC ---
$btnAction.Add_Click({
    if ($btnAction.Text -eq "Close") { $form.Close(); return }
    if ($null -eq $SelectedBrowser) { [System.Windows.Forms.MessageBox]::Show("No compatible browser found!", "Error", "OK", "Error"); return }

    Start-Process -FilePath $SelectedBrowser -ArgumentList "https://www.youtube.com"
    $btnAction.Enabled = $false; $btnAction.Text = "Waiting..."; $statusLabel.Text = "Waiting for Installation..."; $statusLabel.ForeColor = "Yellow"; $timer.Start()
})

$timer.Add_Tick({
    # Find YouTube*.lnk file (excluding the one we already processed)
    $FoundFile = Get-ChildItem -Path $DesktopPath -Filter $ShortcutPattern | Where-Object { $_.Name -ne $NewShortcutName } | Select-Object -First 1
    
    if ($null -ne $FoundFile) {
        $timer.Stop()
        
        # Wait a moment for User to close the window as instructed (3 seconds)
        $statusLabel.Text = "File detected! Finishing up..."
        Start-Sleep -Seconds 3
        
        try {
            $WScript = New-Object -ComObject WScript.Shell
            
            # --- 1. Rename file ---
            $NewFullPath = Join-Path $DesktopPath $NewShortcutName
            if (Test-Path $NewFullPath) { Remove-Item $NewFullPath -Force }
            Rename-Item -Path $FoundFile.FullName -NewName $NewShortcutName
            
            # --- 2. Modify Shortcut (Desktop Only) ---
            $s = $WScript.CreateShortcut($NewFullPath)
            
            # Preservation: Save original icon (Red YouTube icon)
            $OriginalIcon = $s.IconLocation
            
            # Target Fix
            $Target = $s.TargetPath
            if ($Target -match "brave_proxy.exe") { $Target = $Target -replace "brave_proxy.exe", "brave.exe" }
            elseif ($Target -match "chrome_proxy.exe") { $Target = $Target -replace "chrome_proxy.exe", "chrome.exe" }
            elseif ($Target -match "_proxy.exe") { $Target = $Target -replace "_proxy.exe", ".exe" }
            
            if (Test-Path $Target) { $s.TargetPath = $Target } else { $s.TargetPath = $SelectedBrowser }

            # Arguments (TV Mode)
            $NewArgs = "--app=$ForceURL --user-agent=`"$UserAgentString`" --start-maximized"
            if ($s.Arguments -match "(--profile-directory=[^ ]+)") {
                $ProfileArg = $matches[1]
                $NewArgs = "$ProfileArg $NewArgs"
            }
            $s.Arguments = $NewArgs
            
            # Restore Icon
            $s.IconLocation = $OriginalIcon
            $s.Save()

            # --- 3. [CLEANUP] Remove ghost files (if Browser recreates them) ---
            Start-Sleep -Seconds 1
            $GhostFiles = Get-ChildItem -Path $DesktopPath -Filter $ShortcutPattern | Where-Object { $_.Name -ne $NewShortcutName }
            if ($GhostFiles) { foreach ($g in $GhostFiles) { Remove-Item $g.FullName -Force } }

            # --- Finish ---
            $statusLabel.Text = "Installation Complete!"
            $statusLabel.ForeColor = "#00ff00"
            $instructionLabel.Text = "Shortcut created on Desktop.`nYou can now Pin it to Taskbar manually."
            $btnAction.Text = "Close"; $btnAction.Enabled = $true; $btnAction.BackColor = "#006600"
            
        } catch {
            $statusLabel.Text = "Error: $_"; $statusLabel.ForeColor = "Red"; $timer.Stop(); $btnAction.Enabled = $true
        }
    }
})

$form.ShowDialog() | Out-Null
