<# : hybrid batch + powershell script
@powershell -noprofile -Window Hidden -c "$param='%*';$ScriptPath='%~f0';iex((Get-Content('%~f0') -Raw))"&exit/b
#>

# =========================================================
#  YOUTUBE TV INSTALLER v55.0 (HYBRID FIXED)
#  Status: Admin Loop Fixed | Manual Arg Parsing
# =========================================================

$ErrorActionPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# --- [1. MANUAL ARGUMENT PARSING (NO PARAM BLOCK)] ---
# เราใช้การแกะ String แทน param() เพื่อความเสถียรในโหมด Hybrid
$Silent = $false
$Browser = "Ask"

if ($param) {
    if ($param -match "-Silent") { $Silent = $true }
    if ($param -match "-Browser\s+([^\s]+)") { $Browser = $matches[1] }
}

# --- [2. CONFIGURATION] ---
$GitHubRaw = "https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main"
$SelfURL   = "$GitHubRaw/YToTV.ps1"
$InstallDir = "$env:LOCALAPPDATA\ITG_YToTV"

# --- [3. WEB LAUNCH CHECK] ---
if (-not $PSScriptRoot -and -not $ScriptPath) {
    if (!$Silent) { Write-Host "[INIT] Web Mode Detected..." -ForegroundColor Cyan }
    $TempScript = "$env:TEMP\YToTV.ps1"
    try { (New-Object System.Net.WebClient).DownloadFile($SelfURL, $TempScript) } catch { exit }

    $ArgsList = "-NoProfile -ExecutionPolicy Bypass -File `"$TempScript`""
    if ($Silent) { $ArgsList += " -Silent" }
    if ($Browser -ne "Ask") { $ArgsList += " -Browser $Browser" }

    Start-Process PowerShell -ArgumentList $ArgsList -Verb RunAs
    exit
}

# --- [4. ADMIN CHECK] ---
$Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = [Security.Principal.WindowsPrincipal]$Identity
if (-not $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Determine correct script path
    $Target = if ($ScriptPath) { $ScriptPath } else { $PSCommandPath }
    
    # Construct args carefully
    $ArgsList = "-NoProfile -ExecutionPolicy Bypass -File `"$Target`""
    if ($Silent) { $ArgsList += " -Silent" }
    if ($Browser -ne "Ask") { $ArgsList += " -Browser $Browser" }
    
    # Elevate and Exit
    Start-Process PowerShell -ArgumentList $ArgsList -Verb RunAs
    exit
}

# =========================================================
#  MAIN PROGRAM (ADMIN GRANTED)
# =========================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Win32 API
$Win32 = Add-Type -MemberDefinition '
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")] public static extern IntPtr LoadImage(IntPtr hinst, string lpszName, uint uType, int cxDesired, int cyDesired, uint fuLoad);
    [DllImport("user32.dll")] public static extern int SendMessage(IntPtr hWnd, int msg, int wParam, IntPtr lParam);
' -Name "Utils" -Namespace Win32 -PassThru

# --- [5. CONSOLE & UI PREP] ---
# รีบโชว์ Console ก่อนเลย User จะได้รู้ว่าโปรแกรมทำงานแล้ว (ไม่เงียบหาย)
$ConsoleHandle = [Win32.Utils]::GetConsoleWindow()

# Setup Layout
$Scr = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
$W = 500; $H = 750; $Gap = 0
$TotalW = ($W * 2) + $Gap
$X = ($Scr.Width - $TotalW) / 2
$Y = ($Scr.Height - $H) / 2

if ($Silent) {
    [Win32.Utils]::ShowWindow($ConsoleHandle, 0) | Out-Null
} else {
    # 1. Setup Colors
    $host.UI.RawUI.WindowTitle = "Installer Console"
    $host.UI.RawUI.BackgroundColor = "Black"
    $host.UI.RawUI.ForegroundColor = "Green"
    Clear-Host
    
    # 2. Force Show & Move Console (Left)
    # SWP_SHOWWINDOW = 0x0040 (บังคับโชว์ทันที)
    [Win32.Utils]::SetWindowPos($ConsoleHandle, [IntPtr]::Zero, [int]$X, [int]$Y, [int]$W, [int]$H, 0x0040) | Out-Null
    
    Write-Host "`n    YOUTUBE TV INSTALLER v55.0" -ForegroundColor Cyan
    Write-Host "    [INIT] Loading Assets..." -ForegroundColor Yellow
}

# --- Environment & Assets ---
if (-not (Test-Path $InstallDir)) { New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null }

$Assets = @{
    "MenuIcon" = "$GitHubRaw/YouTube.ico"; "ConsoleIcon" = "https://itgroceries.blogspot.com/favicon.ico"
    "Chrome"="$GitHubRaw/IconFiles/Chrome.ico"; "Edge"="$GitHubRaw/IconFiles/Edge.ico"; "Brave"="$GitHubRaw/IconFiles/Brave.ico"
    "Vivaldi"="$GitHubRaw/IconFiles/Vivaldi.ico"; "Yandex"="$GitHubRaw/IconFiles/Yandex.ico"; "Chromium"="$GitHubRaw/IconFiles/Chromium.ico"; "Thorium"="$GitHubRaw/IconFiles/Thorium.ico"
}

function DL ($U, $N) { 
    $D="$InstallDir\$N"; if(!(Test-Path $D) -or (Get-Item $D).Length -eq 0){ try{ (New-Object Net.WebClient).DownloadFile($U,$D) }catch{} }; return $D
}

foreach($k in $Assets.Keys){ DL $Assets[$k] "$k.ico" | Out-Null }
$LocalIcon = "$InstallDir\MenuIcon.ico"; $ConsoleIcon = "$InstallDir\ConsoleIcon.ico"

# Update Console Icon (Now that assets are loaded)
if(!$Silent -and (Test-Path $ConsoleIcon)){ 
    $h=[Win32.Utils]::LoadImage([IntPtr]::Zero, $ConsoleIcon, 1, 0, 0, 0x10)
    if($h){ [Win32.Utils]::SendMessage($ConsoleHandle,0x80,[IntPtr]0,$h)|Out-Null; [Win32.Utils]::SendMessage($ConsoleHandle,0x80,[IntPtr]1,$h)|Out-Null } 
}

# --- Install Logic ---
$Desktop = [Environment]::GetFolderPath("Desktop")
$PF = $env:ProgramFiles; $PF86 = ${env:ProgramFiles(x86)}; $L = $env:LOCALAPPDATA

$Browsers = @(
    @{N="Google Chrome"; E="chrome.exe"; K="Chrome"; P=@("$PF\Google\Chrome\Application\chrome.exe","$PF86\Google\Chrome\Application\chrome.exe")}
    @{N="Microsoft Edge"; E="msedge.exe"; K="Edge"; P=@("$PF86\Microsoft\Edge\Application\msedge.exe","$PF\Microsoft\Edge\Application\msedge.exe")}
    @{N="Brave Browser"; E="brave.exe"; K="Brave"; P=@("$PF\BraveSoftware\Brave-Browser\Application\brave.exe","$PF86\BraveSoftware\Brave-Browser\Application\brave.exe")}
    @{N="Vivaldi"; E="vivaldi.exe"; K="Vivaldi"; P=@("$L\Vivaldi\Application\vivaldi.exe","$PF\Vivaldi\Application\vivaldi.exe")}
    @{N="Yandex Browser"; E="browser.exe"; K="Yandex"; P=@("$L\Yandex\YandexBrowser\Application\browser.exe")}
    @{N="Chromium"; E="chrome.exe"; K="Chromium"; P=@("$L\Chromium\Application\chrome.exe","$PF\Chromium\Application\chrome.exe")}
    @{N="Thorium"; E="thorium.exe"; K="Thorium"; P=@("$L\Thorium\Application\thorium.exe","$PF\Thorium\Application\thorium.exe")}
)

function Install ($Obj) {
    if(!$Obj.Path){return}
    $Sut = Join-Path $Desktop "Youtube On TV - $($Obj.N -replace ' ','').lnk"
    $Ws = New-Object -Com WScript.Shell
    $s = $Ws.CreateShortcut($Sut)
    $s.TargetPath = "cmd.exe"
    $s.Arguments = "/c taskkill /f /im $($Obj.E) /t >nul 2>&1 & start `"`" `"$($Obj.Path)`" --profile-directory=Default --app=https://youtube.com/tv --user-agent=`"Mozilla/5.0 (SMART-TV; LINUX; Tizen 9.0) AppleWebKit/537.36 (KHTML, like Gecko) 120.0.6099.5/9.0 TV Safari/537.36`" --start-fullscreen --disable-features=CalculateNativeWinOcclusion"
    $s.WindowStyle = 3
    if(Test-Path $LocalIcon){ $s.IconLocation = $LocalIcon }
    $s.Save()
    if(!$Silent){ Write-Host " [INSTALLED] $($Obj.N)" -ForegroundColor Green }
}

# --- CLI Mode Check ---
if ($Silent -or ($Browser -ne "Ask")) {
    if(!$Silent){ Write-Host "[CLI] Target: $Browser" -ForegroundColor Cyan }
    foreach($b in $Browsers){
        if($b.N -match $Browser -or $b.K -match $Browser){
            $FP=$null; foreach($p in $b.P){if(Test-Path $p){$FP=$p;break}}
            if($FP){ $b.Path=$FP; Install $b }
        }
    }
    exit
}

# =========================================================
#  GUI (WINFORMS) SETUP
# =========================================================

Write-Host "    [INIT] Launching UI..." -ForegroundColor Yellow

$Form = New-Object System.Windows.Forms.Form
$Form.Text = "YouTube TV Installer"
$Form.Size = New-Object System.Drawing.Size($W, $H)
$Form.StartPosition = "Manual"
$Form.Location = New-Object System.Drawing.Point(($X + $W), $Y) # Place right of Console
$Form.BackColor = [System.Drawing.Color]::FromArgb(24, 24, 24)
$Form.ForeColor = "White"
$Form.FormBorderStyle = "FixedSingle"
$Form.MaximizeBox = $false
if(Test-Path $LocalIcon){ $Form.Icon = New-Object System.Drawing.Icon($LocalIcon) }

# Header
$LblHeader = New-Object System.Windows.Forms.Label
$LblHeader.Text = "YouTube TV Installer"
$LblHeader.Font = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
$LblHeader.AutoSize = $true
$LblHeader.Location = New-Object System.Drawing.Point(20, 20)
$Form.Controls.Add($LblHeader)

$LblSub = New-Object System.Windows.Forms.Label
$LblSub.Text = "Developed by IT Groceries Shop"
$LblSub.ForeColor = "Red"
$LblSub.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$LblSub.AutoSize = $true
$LblSub.Location = New-Object System.Drawing.Point(22, 60)
$Form.Controls.Add($LblSub)

# Panel
$Panel = New-Object System.Windows.Forms.Panel
$Panel.Location = New-Object System.Drawing.Point(20, 100)
$Panel.Size = New-Object System.Drawing.Size(445, 530)
$Panel.AutoScroll = $true
$Form.Controls.Add($Panel)

$Y_Item = 0
foreach($b in $Browsers){
    $FP=$null; foreach($p in $b.P){if(Test-Path $p){$FP=$p;break}}
    
    $PnlItem = New-Object System.Windows.Forms.Panel
    $PnlItem.Size = New-Object System.Drawing.Size(420, 50)
    $PnlItem.Location = New-Object System.Drawing.Point(0, $Y_Item)
    $PnlItem.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
    
    $Pb = New-Object System.Windows.Forms.PictureBox
    $Pb.Size = New-Object System.Drawing.Size(32, 32)
    $Pb.Location = New-Object System.Drawing.Point(10, 9)
    $Pb.SizeMode = "StretchImage"
    $IcoPath="$InstallDir\$($b.K).ico"
    if(Test-Path $IcoPath){ $Pb.Image = [System.Drawing.Image]::FromFile($IcoPath) }
    $PnlItem.Controls.Add($Pb)
    
    $Chk = New-Object System.Windows.Forms.CheckBox
    $Chk.Text = ""
    $Chk.AutoSize = $true
    $Chk.Location = New-Object System.Drawing.Point(390, 15)
    $Chk.Tag = $b
    if($FP){ $b.Path=$FP; $Chk.Checked = $true; $Chk.Cursor = "Hand" } else { $Chk.Enabled = $false; $PnlItem.Enabled = $false }
    $PnlItem.Controls.Add($Chk)
    
    $Lbl = New-Object System.Windows.Forms.Label
    $Lbl.Text = $b.N
    $Lbl.Font = New-Object System.Drawing.Font("Segoe UI", 11)
    $Lbl.Location = New-Object System.Drawing.Point(50, 12)
    $Lbl.AutoSize = $true
    if(!$FP){ $Lbl.Text += " (Not Installed)"; $Lbl.ForeColor = "Gray" }
    $Lbl.Add_Click({ if($Chk.Enabled){ $Chk.Checked = -not $Chk.Checked } })
    $PnlItem.Controls.Add($Lbl)

    $Panel.Controls.Add($PnlItem)
    $Y_Item += 55
}

# Footer
$BtnExit = New-Object System.Windows.Forms.Button
$BtnExit.Text = "EXIT"
$BtnExit.Size = New-Object System.Drawing.Size(100, 40)
$BtnExit.Location = New-Object System.Drawing.Point(240, 650)
$BtnExit.FlatStyle = "Flat"
$BtnExit.BackColor = "Maroon"
$BtnExit.ForeColor = "White"
$BtnExit.Add_Click({ $Form.Close() })
$Form.Controls.Add($BtnExit)

$BtnStart = New-Object System.Windows.Forms.Button
$BtnStart.Text = "Start Install"
$BtnStart.Size = New-Object System.Drawing.Size(120, 40)
$BtnStart.Location = New-Object System.Drawing.Point(350, 650)
$BtnStart.FlatStyle = "Flat"
$BtnStart.BackColor = "Green"
$BtnStart.ForeColor = "White"
$BtnStart.Add_Click({
    $BtnStart.Enabled = $false; $BtnStart.Text = "Processing..."
    foreach($c in $Panel.Controls){
        $cb = $c.Controls[1]
        if($cb.Checked){ Install $cb.Tag }
    }
    $BtnStart.Text = "Finished"; Start-Sleep 1; $BtnStart.Enabled = $true; $BtnStart.Text = "Start Install"
})
$Form.Controls.Add($BtnStart)

$LnkFB = New-Object System.Windows.Forms.LinkLabel
$LnkFB.Text = "Facebook"
$LnkFB.LinkColor = "Cyan"
$LnkFB.Location = New-Object System.Drawing.Point(20, 660)
$LnkFB.Add_LinkClicked({ Start-Process "https://www.facebook.com/Adm1n1straTOE" })
$Form.Controls.Add($LnkFB)

[void]$Form.ShowDialog()
