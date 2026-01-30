<# : hybrid batch + powershell script
@powershell -noprofile -Window Hidden -c "$param='%*';$ScriptPath='%~f0';iex((Get-Content('%~f0') -Raw))"&exit/b
#>

# =========================================================
#  YOUTUBE TV INSTALLER v82.0 (BACK TO STABILITY)
#  Status: v75 Core | Solid Magnet | No-Close(X)
# =========================================================

# --- [1. CONFIGURATION] ---
$InstallDir = "$env:LOCALAPPDATA\ITG_YToTV"
$TempScript = "$env:TEMP\YToTV.ps1"
$GitHubRaw = "https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/branch"
$SelfURL = "$GitHubRaw/75.ps1"
$AppVersion = "2.0 Build 28.82"
$BuildDate  = "30-1-2026"

# Check Mode
$IsLocal = ($PSScriptRoot -or $ScriptPath)
$TargetFile = if ($ScriptPath) { $ScriptPath } elseif ($PSScriptRoot) { $PSCommandPath } else { $null }

# Handle Arguments
$Silent = $false
$Browser = "Ask"
$AllArgs = @()
if ($args) { $AllArgs += $args }
if ($param) { $AllArgs += $param.Split(" ") }
for ($i = 0; $i -lt $AllArgs.Count; $i++) {
    if ($AllArgs[$i] -eq "-Silent") { $Silent = $true }
    if ($AllArgs[$i] -eq "-Browser" -and ($i + 1 -lt $AllArgs.Count)) { $Browser = $AllArgs[$i+1] }
}

# --- [2. WIN32 API] ---
$User32Def = @'
[DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
[DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
[DllImport("user32.dll")] public static extern IntPtr LoadImage(IntPtr hinst, string lpszName, uint uType, int cxDesired, int cyDesired, uint fuLoad);
[DllImport("user32.dll")] public static extern int SendMessage(IntPtr hWnd, int msg, int wParam, IntPtr lParam);
[DllImport("user32.dll")] public static extern IntPtr GetSystemMenu(IntPtr hWnd, bool bRevert);
[DllImport("user32.dll")] public static extern bool DeleteMenu(IntPtr hMenu, uint uPosition, uint uFlags);
'@
Add-Type -MemberDefinition $User32Def -Name "User32" -Namespace Win32

if (!$Silent) { [Win32.User32]::ShowWindow([Win32.User32]::GetConsoleWindow(), 5) | Out-Null }

# --- [3. ADMIN CHECK (Same as v75)] ---
$Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = [Security.Principal.WindowsPrincipal]$Identity
if (-not $Silent -and -not $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`n [+] Requesting Admin privileges..." -ForegroundColor Yellow
    $PassArgs = @()
    if ($Browser -ne "Ask") { $PassArgs += "-Browser"; $PassArgs += $Browser }
    if (!$IsLocal) {
        try { (New-Object System.Net.WebClient).DownloadFile($SelfURL, $TempScript) } catch { exit }
        Start-Process PowerShell -ArgumentList (@("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$TempScript`"") + $PassArgs) -Verb RunAs
    } elseif ($TargetFile -match "\.cmd$" -or $TargetFile -match "\.bat$") {
        Start-Process "cmd.exe" -ArgumentList "/c `"`"$TargetFile`"`"" -Verb RunAs
    } else {
        Start-Process PowerShell -ArgumentList (@("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$TargetFile`"") + $PassArgs) -Verb RunAs
    }
    exit 
}

# --- [4. MAIN PROGRAM] ---
Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, System.Drawing

$Graphics = [System.Drawing.Graphics]::FromHwnd([IntPtr]::Zero)
$Scale = $Graphics.DpiX / 96.0; $Graphics.Dispose()
$BaseW = 500; $BaseH = 820; $Gap = 2
$ConsoleW_Px = [int]($BaseW * $Scale); $ConsoleH_Px = [int]($BaseH * $Scale)
$Scr = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
$StartX_Px = ($Scr.Width - ($ConsoleW_Px * 2)) / 2; $StartY_Px = ($Scr.Height - $ConsoleH_Px) / 2

$ConsoleHandle = [Win32.User32]::GetConsoleWindow()

if (!$Silent) {
    $host.UI.RawUI.WindowTitle = "Installer Log Console"
    $host.UI.RawUI.BackgroundColor = "Black"
    $host.UI.RawUI.ForegroundColor = "Gray"
    Clear-Host
    # [REQ 15] Disable Console Close(X)
    $hMenu = [Win32.User32]::GetSystemMenu($ConsoleHandle, $false)
    if ($hMenu) { [Win32.User32]::DeleteMenu($hMenu, 0xF060, 0x00000000) | Out-Null }
    
    [Win32.User32]::SetWindowPos($ConsoleHandle, [IntPtr]-1, [int]$StartX_Px, [int]$StartY_Px, [int]$ConsoleW_Px, [int]$ConsoleH_Px, 0x0040) | Out-Null
}

# Assets (v75 Logic)
if (-not (Test-Path $InstallDir)) { New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null }
$Assets = @{ "MenuIcon" = "$GitHubRaw/YouTube.ico"; "ConsoleIcon" = "https://itgroceries.blogspot.com/favicon.ico" }
foreach($k in $Assets.Keys){ try{ (New-Object Net.WebClient).DownloadFile($Assets[$k],"$InstallDir\$k.ico") }catch{} }
$LocalIcon = "$InstallDir\MenuIcon.ico"

# GUI XAML (v75 Style + Manual Blue Border)
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
Title="YouTube TV Installer" Height="$BaseH" Width="$BaseW" WindowStartupLocation="Manual" ResizeMode="NoResize" Background="#2196F3" Topmost="True">
    <Grid Background="#181818" Margin="2"> <Grid Margin="25">
            <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="20"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
            <Grid Grid.Row="0"><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                <Image x:Name="Logo" Grid.Column="0" Width="80" Height="80"/>
                <StackPanel Grid.Column="1" VerticalAlignment="Center" Margin="20,0,0,0">
                    <TextBlock Text="YouTube TV Installer" Foreground="White" FontSize="28" FontWeight="Bold"/>
                    <TextBlock Text="Developed by IT Groceries Shop &#x2665;" Foreground="#FF0000" FontSize="14" FontWeight="Bold" Margin="2,5,0,0"/>
                </StackPanel>
            </Grid>
            <Border Grid.Row="2" Background="#1E1E1E"><ScrollViewer VerticalScrollBarVisibility="Hidden"><StackPanel x:Name="List"/></ScrollViewer></Border>
            <Grid Grid.Row="3" Margin="0,20,0,0">
                <Button x:Name="BC" Content="EXIT" HorizontalAlignment="Left" Width="90" Height="45" Background="#D32F2F" Foreground="White" FontWeight="Bold"/>
                <Button x:Name="BA" Content="Start Install" HorizontalAlignment="Right" Width="160" Height="45" Background="#2E7D32" Foreground="White" FontWeight="Bold"/>
            </Grid>
        </Grid>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml); $Window = [Windows.Markup.XamlReader]::Load($reader)
$Window.Left = ($StartX_Px + $ConsoleW_Px + ($Gap * $Scale)) / $Scale
$Window.Top = $StartY_Px / $Scale

# [REQ 15] Disable Menu Close(X)
$Window.Add_SourceInitialized({
    $hwnd = (New-Object System.Windows.Interop.WindowInteropHelper($Window)).Handle
    $hMenu = [Win32.User32]::GetSystemMenu($hwnd, $false)
    if ($hMenu) { [Win32.User32]::DeleteMenu($hMenu, 0xF060, 0x00000000) | Out-Null }
})

# [REQ 16] Magnet Logic
$Window.Add_LocationChanged({
    if (!$Silent) {
        $ConsX = ($Window.Left * $Scale) - $ConsoleW_Px - ($Gap * $Scale)
        $ConsY = ($Window.Top * $Scale)
        [Win32.User32]::SetWindowPos($ConsoleHandle, [IntPtr]-1, [int]$ConsX, [int]$ConsY, [int]$ConsoleW_Px, [int]$ConsoleH_Px, 0x0040) | Out-Null
    }
})

$BC = $Window.FindName("BC"); $BA = $Window.FindName("BA")
$BC.Add_Click({ 
    Write-Host "`n [EXIT] Clean & Bye !!" -ForegroundColor Cyan
    Start-Sleep 2; $Window.Close() 
})

$Window.ShowDialog() | Out-Null
