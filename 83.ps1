<# : hybrid batch + powershell script
@powershell -noprofile -Window Hidden -c "$param='%*';$ScriptPath='%~f0';iex((Get-Content('%~f0') -Raw))"&exit/b
#>

# =========================================================
#  YOUTUBE TV INSTALLER v83.0 (BALANCED MASTER)
#  Status: Full UI Restored | Stable Window | Grey-out X
# =========================================================

# --- [1. CONFIGURATION] ---
$InstallDir = "$env:LOCALAPPDATA\ITG_YToTV"
$TempScript = "$env:TEMP\YToTV.ps1"
$GitHubRaw = "https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/branch"
$SelfURL = "$GitHubRaw/83.ps1"
$AppVersion = "2.0 Build 29.83"
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
[DllImport("user32.dll")] public static extern bool EnableMenuItem(IntPtr hMenu, uint uIDEnableItem, uint uEnable);
'@
Add-Type -MemberDefinition $User32Def -Name "User32" -Namespace Win32

if (!$Silent) { [Win32.User32]::ShowWindow([Win32.User32]::GetConsoleWindow(), 5) | Out-Null }

# --- [3. ADMIN CHECK] ---
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
$BaseW = 500; $BaseH = 820; $Gap = 5
$ConsoleW_Px = [int]($BaseW * $Scale); $ConsoleH_Px = [int]($BaseH * $Scale)
$Scr = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
$StartX_Px = ($Scr.Width - ($ConsoleW_Px * 2)) / 2; $StartY_Px = ($Scr.Height - $ConsoleH_Px) / 2

$ConsoleHandle = [Win32.User32]::GetConsoleWindow()

if (!$Silent) {
    $host.UI.RawUI.WindowTitle = "Installer Log Console"
    $host.UI.RawUI.BackgroundColor = "Black"
    $host.UI.RawUI.ForegroundColor = "Gray"
    Clear-Host
    # Disable Console Close(X) - Just Grey Out
    $hMenu = [Win32.User32]::GetSystemMenu($ConsoleHandle, $false)
    if ($hMenu) { [Win32.User32]::EnableMenuItem($hMenu, 0xF060, 0x00000001) | Out-Null }
    
    [Win32.User32]::SetWindowPos($ConsoleHandle, [IntPtr]-1, [int]$StartX_Px, [int]$StartY_Px, [int]$ConsoleW_Px, [int]$ConsoleH_Px, 0x0040) | Out-Null
}

# Assets
if (-not (Test-Path $InstallDir)) { New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null }
$Assets = @{ "MenuIcon" = "$GitHubRaw/YouTube.ico"; "ConsoleIcon" = "https://itgroceries.blogspot.com/favicon.ico"; "Chrome"="$GitHubRaw/IconFiles/Chrome.ico"; "Edge"="$GitHubRaw/IconFiles/Edge.ico"; "Brave"="$GitHubRaw/IconFiles/Brave.ico"; "Vivaldi"="$GitHubRaw/IconFiles/Vivaldi.ico"; "Yandex"="$GitHubRaw/IconFiles/Yandex.ico"; "Chromium"="$GitHubRaw/IconFiles/Chromium.ico"; "Thorium"="$GitHubRaw/IconFiles/Thorium.ico" }
foreach($k in $Assets.Keys){ try{ (New-Object Net.WebClient).DownloadFile($Assets[$k],"$InstallDir\$k.ico") }catch{} }
$LocalIcon = "$InstallDir\MenuIcon.ico"

# GUI XAML (v81 UI + v75 Stability)
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
Title="YouTube TV Installer" Height="$BaseH" Width="$BaseW" WindowStartupLocation="Manual" ResizeMode="NoResize" Background="#2196F3" Topmost="True">
    <Grid Background="#181818" Margin="2">
        <Grid Margin="25">
            <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="20"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
            <Grid Grid.Row="0"><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                <Image x:Name="Logo" Grid.Column="0" Width="80" Height="80"/>
                <StackPanel Grid.Column="1" VerticalAlignment="Center" Margin="20,0,0,0">
                    <TextBlock Text="YouTube TV Installer" Foreground="White" FontSize="28" FontWeight="Bold"><TextBlock.Effect><DropShadowEffect Color="#FF0000" BlurRadius="15" Opacity="0.6"/></TextBlock.Effect></TextBlock>
                    <TextBlock Text="Developed by IT Groceries Shop &#x2665;" Foreground="#FF0000" FontSize="14" FontWeight="Bold" Margin="2,5,0,0"/>
                </StackPanel>
            </Grid>
            <Border Grid.Row="2" Background="#1E1E1E"><ScrollViewer VerticalScrollBarVisibility="Hidden"><StackPanel x:Name="List"/></ScrollViewer></Border>
            <Grid Grid.Row="3" Margin="0,20,0,0"><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
                <StackPanel Orientation="Horizontal" Grid.Column="0">
                     <Button x:Name="BF" Width="45" Height="45" Background="#1877F2" Margin="0,0,10,0"><TextBlock Text="f" Foreground="White" FontSize="26" FontWeight="Bold" Margin="0,-4,0,0"/></Button>
                     <Button x:Name="BG" Width="45" Height="45" Background="#333333"><Viewbox Width="24" Height="24"><Path Fill="White" Data="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12"/></Viewbox></Button>
                </StackPanel>
                <StackPanel Orientation="Horizontal" Grid.Column="2">
                    <Button x:Name="BC" Content="EXIT" Width="90" Height="45" Background="#D32F2F" Foreground="White" FontWeight="Bold" Margin="0,0,10,0"/>
                    <Button x:Name="BA" Content="Start Install" Width="160" Height="45" Background="#2E7D32" Foreground="White" FontWeight="Bold"/>
                </StackPanel>
            </Grid>
        </Grid>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml); $Window = [Windows.Markup.XamlReader]::Load($reader)
$Window.Left = ($StartX_Px + $ConsoleW_Px + ($Gap * $Scale)) / $Scale
$Window.Top = $StartY_Px / $Scale
if (Test-Path $LocalIcon) { $Window.FindName("Logo").Source = $LocalIcon }

# Grey-out Menu Close(X)
$Window.Add_SourceInitialized({
    $hwnd = (New-Object System.Windows.Interop.WindowInteropHelper($Window)).Handle
    $hMenu = [Win32.User32]::GetSystemMenu($hwnd, $false)
    if ($hMenu) { [Win32.User32]::EnableMenuItem($hMenu, 0xF060, 0x00000001) | Out-Null }
})

# Magnet Logic
$Window.Add_LocationChanged({
    if (!$Silent) {
        $ConsX = ($Window.Left * $Scale) - $ConsoleW_Px - ($Gap * $Scale)
        $ConsY = ($Window.Top * $Scale)
        [Win32.User32]::SetWindowPos($ConsoleHandle, [IntPtr]-1, [int]$ConsX, [int]$ConsY, [int]$ConsoleW_Px, [int]$ConsoleH_Px, 0x0040) | Out-Null
    }
})

# List Building (Browsers)
$PF = $env:ProgramFiles; $PF86 = ${env:ProgramFiles(x86)}; $L = $env:LOCALAPPDATA
$Global:Browsers = @(
    @{N="Google Chrome"; E="chrome.exe"; K="Chrome"; P=@("$PF\Google\Chrome\Application\chrome.exe","$PF86\Google\Chrome\Application\chrome.exe")}
    @{N="Microsoft Edge"; E="msedge.exe"; K="Edge"; P=@("$PF86\Microsoft\Edge\Application\msedge.exe","$PF\Microsoft\Edge\Application\msedge.exe")}
    @{N="Brave Browser"; E="brave.exe"; K="Brave"; P=@("$PF\BraveSoftware\Brave-Browser\Application\brave.exe","$PF86\BraveSoftware\Brave-Browser\Application\brave.exe")}
    @{N="Vivaldi"; E="vivaldi.exe"; K="Vivaldi"; P=@("$L\Vivaldi\Application\vivaldi.exe","$PF\Vivaldi\Application\vivaldi.exe")}
    @{N="Yandex Browser"; E="browser.exe"; K="Yandex"; P=@("$L\Yandex\YandexBrowser\Application\browser.exe")}
)

$Stack = $Window.FindName("List"); $BA = $Window.FindName("BA"); $BC = $Window.FindName("BC")

foreach ($b in $Global:Browsers) {
    $FP=$null; foreach($p in $b.P){ if($p -and (Test-Path $p)){ $FP=$p; break } }
    $IconPath = "$InstallDir\$($b.K).ico"
    $Row = New-Object System.Windows.Controls.Grid; $Row.Height = 45; $Row.Margin = "0,5,0,5"
    $Row.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{Width=[System.Windows.GridLength]::Auto}))
    $Row.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{Width=[System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)}))
    $Row.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{Width=[System.Windows.GridLength]::Auto}))
    $Bor = New-Object System.Windows.Controls.Border; $Bor.CornerRadius = 8; $Bor.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#252526"); $Bor.Padding = "10"; $Bor.Child = $Row
    $Img = New-Object System.Windows.Controls.Image; $Img.Width = 32; $Img.Height = 32; if (Test-Path $IconPath) { $Img.Source = $IconPath }
    [System.Windows.Controls.Grid]::SetColumn($Img,0); $Row.Children.Add($Img)|Out-Null
    $Txt = New-Object System.Windows.Controls.TextBlock; $Txt.Text = $b.N; $Txt.Foreground="White"; $Txt.VerticalAlignment="Center"; $Txt.Margin="15,0,0,0"
    if (!$FP) { $Txt.Text += " (Not Installed)"; $Txt.Foreground="#666666"; $Bor.Opacity=0.5 }
    [System.Windows.Controls.Grid]::SetColumn($Txt,1); $Row.Children.Add($Txt)|Out-Null
    $Stack.Children.Add($Bor)|Out-Null
}

$BC.Add_Click({ Write-Host "`n [EXIT] Clean & Bye !!" -ForegroundColor Cyan; Start-Sleep 2; $Window.Close() })

$Window.ShowDialog() | Out-Null
