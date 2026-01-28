<# : hybrid batch + powershell script
@powershell -noprofile -Window Hidden -c "$param='%*';$ScriptPath='%~f0';iex((Get-Content('%~f0') -Raw))"&exit/b
#>

# =========================================================
#  YOUTUBE TV INSTALLER v57.0 (WPF DPI-SYNC)
#  Status: WPF Restored | DPI Scaling Fix | Admin Fixed
# =========================================================

# --- [1. MANUAL ARGUMENT PARSING] ---
$Silent = $false
$Browser = "Ask"
$ErrorActionPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$AllArgs = @()
if ($args) { $AllArgs += $args }
if ($param) { $AllArgs += $param.Split(" ") }

for ($i = 0; $i -lt $AllArgs.Count; $i++) {
    if ($AllArgs[$i] -eq "-Silent") { $Silent = $true }
    if ($AllArgs[$i] -eq "-Browser" -and ($i + 1 -lt $AllArgs.Count)) { $Browser = $AllArgs[$i+1] }
}

# --- [2. CONFIGURATION] ---
$GitHubRaw = "https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main"
$SelfURL   = "$GitHubRaw/YToTV.ps1"
$InstallDir = "$env:LOCALAPPDATA\ITG_YToTV"

# --- [3. WEB LAUNCH CHECK] ---
if (-not $PSScriptRoot -and -not $ScriptPath) {
    if (!$Silent) { Write-Host "[INIT] Web Mode Detected. Downloading..." -ForegroundColor Cyan }
    $TempScript = "$env:TEMP\YToTV.ps1"
    try { (New-Object System.Net.WebClient).DownloadFile($SelfURL, $TempScript) } catch { exit }

    $PassArgs = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$TempScript`"")
    if ($Silent) { $PassArgs += "-Silent" }
    if ($Browser -ne "Ask") { $PassArgs += "-Browser"; $PassArgs += $Browser }

    Start-Process PowerShell -ArgumentList $PassArgs -Verb RunAs
    exit
}

# --- [4. ADMIN CHECK] ---
$Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = [Security.Principal.WindowsPrincipal]$Identity
if (-not $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $Target = if ($ScriptPath) { $ScriptPath } else { $PSCommandPath }
    $PassArgs = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$Target`"")
    if ($Silent) { $PassArgs += "-Silent" }
    if ($Browser -ne "Ask") { $PassArgs += "-Browser"; $PassArgs += $Browser }
    Start-Process PowerShell -ArgumentList $PassArgs -Verb RunAs
    exit
}

# =========================================================
#  MAIN PROGRAM (ADMIN)
# =========================================================

Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, System.Drawing

# Win32 API
$Win32 = Add-Type -MemberDefinition '
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")] public static extern IntPtr LoadImage(IntPtr hinst, string lpszName, uint uType, int cxDesired, int cyDesired, uint fuLoad);
    [DllImport("user32.dll")] public static extern int SendMessage(IntPtr hWnd, int msg, int wParam, IntPtr lParam);
' -Name "Utils" -Namespace Win32 -PassThru

# --- [5. DPI & LAYOUT CALCULATION (THE FIX)] ---
# คำนวณ Scaling Factor ของหน้าจอ (เช่น 100% = 1.0, 125% = 1.25)
$Graphics = [System.Drawing.Graphics]::FromHwnd([IntPtr]::Zero)
$DPI = $Graphics.DpiX
$Graphics.Dispose()
$Scale = $DPI / 96.0

# กำหนดขนาดพื้นฐาน (WPF Units)
$BaseW = 500
$BaseH = 820
$Gap = 0

# แปลงเป็น Physical Pixels สำหรับ Console (เพื่อให้เท่ากับ WPF)
$ConsoleW_Px = [int]($BaseW * $Scale)
$ConsoleH_Px = [int]($BaseH * $Scale)

# คำนวณตำแหน่งกึ่งกลาง (Based on Pixels)
$Scr = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
$TotalWidth_Px = ($ConsoleW_Px * 2) + $Gap
$StartX_Px = ($Scr.Width - $TotalWidth_Px) / 2
$StartY_Px = ($Scr.Height - $ConsoleH_Px) / 2

# --- [6. CONSOLE SETUP] ---
$ConsoleHandle = [Win32.Utils]::GetConsoleWindow()

if ($Silent) {
    [Win32.Utils]::ShowWindow($ConsoleHandle, 0) | Out-Null
} else {
    $host.UI.RawUI.WindowTitle = "Installer Console"
    $host.UI.RawUI.BackgroundColor = "Black"
    $host.UI.RawUI.ForegroundColor = "Green"
    Clear-Host
    
    # Force Show & Resize Console (ใช้ค่า Pixel ที่คำนวณแล้ว)
    [Win32.Utils]::SetWindowPos($ConsoleHandle, [IntPtr]::Zero, [int]$StartX_Px, [int]$StartY_Px, [int]$ConsoleW_Px, [int]$ConsoleH_Px, 0x0040) | Out-Null
    
    Write-Host "`n    YOUTUBE TV INSTALLER v57.0" -ForegroundColor Cyan
    Write-Host "    [INIT] DPI Scale: $Scale x" -ForegroundColor DarkGray
    Write-Host "    [INIT] Loading Assets..." -ForegroundColor Yellow
}

# --- Assets ---
if (-not (Test-Path $InstallDir)) { New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null }
$Assets = @{
    "MenuIcon" = "$GitHubRaw/YouTube.ico"; "ConsoleIcon" = "https://itgroceries.blogspot.com/favicon.ico"
    "Chrome"="$GitHubRaw/IconFiles/Chrome.ico"; "Edge"="$GitHubRaw/IconFiles/Edge.ico"; "Brave"="$GitHubRaw/IconFiles/Brave.ico"
    "Vivaldi"="$GitHubRaw/IconFiles/Vivaldi.ico"; "Yandex"="$GitHubRaw/IconFiles/Yandex.ico"; "Chromium"="$GitHubRaw/IconFiles/Chromium.ico"; "Thorium"="$GitHubRaw/IconFiles/Thorium.ico"
}
function DL ($U, $N) { $D="$InstallDir\$N"; if(!(Test-Path $D) -or (Get-Item $D).Length -eq 0){ try{ (New-Object Net.WebClient).DownloadFile($U,$D) }catch{} }; return $D }
foreach($k in $Assets.Keys){ DL $Assets[$k] "$k.ico" | Out-Null }
$LocalIcon = "$InstallDir\MenuIcon.ico"; $ConsoleIcon = "$InstallDir\ConsoleIcon.ico"

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
#  GUI (WPF RESTORED)
# =========================================================

Write-Host "    [INIT] Launching GUI..." -ForegroundColor Yellow

$DetectedBrowsers = @()
function Create-ImageObject ($FilePath) {
    try { if(!(Test-Path $FilePath)){return $null}; $Uri=New-Object Uri($FilePath); $B=New-Object System.Windows.Media.Imaging.BitmapImage; $B.BeginInit(); $B.UriSource=$Uri; $B.CacheOption="OnLoad"; $B.EndInit(); $B.Freeze(); return $B } catch { return $null }
}

foreach ($b in $Browsers) {
    $FoundPath = $null; foreach ($p in $b.P) { if ($p -and (Test-Path $p)) { $FoundPath = $p; break } }
    $ReadyImage = Create-ImageObject "$InstallDir\$($b.K).ico"
    if ($FoundPath) { $DetectedBrowsers += @{ Name=$b.N; Path=$FoundPath; Exe=$b.E; Installed=$true; IconObj=$ReadyImage } }
    else { $DetectedBrowsers += @{ Name=$b.N; Path=$null; Exe=$b.E; Installed=$false; IconObj=$ReadyImage } }
}

# XAML (The Beautiful Version)
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
Title="YT Installer" Height="$BaseH" Width="$BaseW" WindowStartupLocation="Manual" ResizeMode="NoResize" Background="#181818" Topmost="True">
    <Window.Resources>
        <Style x:Key="BlueSwitch" TargetType="{x:Type CheckBox}">
            <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="{x:Type CheckBox}">
                <Border x:Name="T" Width="44" Height="24" Background="#3E3E3E" CornerRadius="12" Cursor="Hand"><Border x:Name="D" Width="20" Height="20" Background="White" CornerRadius="10" HorizontalAlignment="Left" Margin="2,0,0,0"><Border.RenderTransform><TranslateTransform x:Name="Tr" X="0"/></Border.RenderTransform></Border></Border>
                <ControlTemplate.Triggers><Trigger Property="IsChecked" Value="True">
                    <Trigger.EnterActions><BeginStoryboard><Storyboard><DoubleAnimation Storyboard.TargetName="Tr" Storyboard.TargetProperty="X" To="20" Duration="0:0:0.2"/><ColorAnimation Storyboard.TargetName="T" Storyboard.TargetProperty="Background.Color" To="#2196F3" Duration="0:0:0.2"/></Storyboard></BeginStoryboard></Trigger.EnterActions>
                    <Trigger.ExitActions><BeginStoryboard><Storyboard><DoubleAnimation Storyboard.TargetName="Tr" Storyboard.TargetProperty="X" To="0" Duration="0:0:0.2"/><ColorAnimation Storyboard.TargetName="T" Storyboard.TargetProperty="Background.Color" To="#3E3E3E" Duration="0:0:0.2"/></Storyboard></BeginStoryboard></Trigger.ExitActions>
                </Trigger><Trigger Property="IsEnabled" Value="False"><Setter Property="Opacity" Value="0.5"/></Trigger></ControlTemplate.Triggers>
            </ControlTemplate></Setter.Value></Setter>
        </Style>
        <Style x:Key="Btn" TargetType="Button"><Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button"><Border x:Name="b" Background="{TemplateBinding Background}" CornerRadius="22"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" TextElement.FontWeight="Bold"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="b" Property="Opacity" Value="0.8"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Setter.Value></Setter></Style>
    </Window.Resources>
    <Grid Margin="25">
        <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="20"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
        <Grid Grid.Row="0"><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
            <Image x:Name="Logo" Grid.Column="0" Width="80" Height="80"/>
            <StackPanel Grid.Column="1" VerticalAlignment="Center" Margin="20,0,0,0">
                <TextBlock Text="YouTube TV Installer" Foreground="White" FontSize="28" FontWeight="Bold"><TextBlock.Effect><DropShadowEffect Color="#FF0000" BlurRadius="15" Opacity="0.6"/></TextBlock.Effect></TextBlock>
                <StackPanel Orientation="Horizontal" Margin="2,5,0,0"><TextBlock Text="Developed by IT Groceries Shop &#x2665;" Foreground="#FF0000" FontSize="14" FontWeight="Bold"/></StackPanel>
            </StackPanel>
        </Grid>
        <Border Grid.Row="2" Background="#1E1E1E"><ScrollViewer VerticalScrollBarVisibility="Hidden"><StackPanel x:Name="List"/></ScrollViewer></Border>
        <Grid Grid.Row="3" Margin="0,20,0,0"><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
            <StackPanel Orientation="Horizontal" Grid.Column="0">
                 <Button x:Name="BF" Width="45" Height="45" Background="#1877F2" Style="{StaticResource Btn}" Margin="0,0,10,0" ToolTip="Facebook" Cursor="Hand"><TextBlock Text="f" Foreground="White" FontSize="26" FontWeight="Bold" Margin="0,-4,0,0"/></Button>
                 <Button x:Name="BG" Width="45" Height="45" Background="#333333" Style="{StaticResource Btn}" ToolTip="GitHub" Cursor="Hand">
                    <Viewbox Width="24" Height="24"><Path Fill="White" Data="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12"/></Viewbox>
                 </Button>
            </StackPanel>
            <StackPanel Orientation="Horizontal" Grid.Column="2">
                <Button x:Name="BC" Content="EXIT" Width="90" Height="45" Background="#D32F2F" Foreground="White" Style="{StaticResource Btn}" Margin="0,0,10,0" Cursor="Hand"/>
                <Button x:Name="BA" Content="Start Install" Width="160" Height="45" Background="#2E7D32" Foreground="White" Style="{StaticResource Btn}" Cursor="Hand"/>
            </StackPanel>
        </Grid>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml); $Window = [Windows.Markup.XamlReader]::Load($reader)

# Position WPF (Calculate X using Scale to match Console's Right Edge)
try { 
    $RightOfConsole_Px = $StartX_Px + $ConsoleW_Px + $Gap
    # Note: WPF .Left uses DIUs, not Pixels. So we assume WPF handles its own scaling for position usually,
    # but here we might need to be careful. Let's try placing it based on pixel calc converted back to DIU if needed.
    # For now, let's trust WPF to scale the position if we give it units.
    # Actually, simpler: Let's assume standard behavior.
    
    # Position WPF Right of Console
    # We must convert the Pixel position back to DIU for WPF Window.Left
    $WPF_Left_DIU = $RightOfConsole_Px / $Scale
    $WPF_Top_DIU  = $StartY_Px / $Scale
    
    $Window.Left = $WPF_Left_DIU
    $Window.Top = $WPF_Top_DIU
} catch {}

if (Test-Path $LocalIcon) { $Obj = Create-ImageObject $LocalIcon; $Window.Icon = $Obj; $Window.FindName("Logo").Source = $Obj }

$Stack = $Window.FindName("List"); $BA = $Window.FindName("BA"); $BC = $Window.FindName("BC"); $BF = $Window.FindName("BF"); $BG = $Window.FindName("BG")

foreach ($b in $DetectedBrowsers) {
    $Row = New-Object System.Windows.Controls.Grid; $Row.Height = 45; $Row.Margin = "0,5,0,5"
    $Row.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{Width=[System.Windows.GridLength]::Auto}))
    $Row.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{Width=[System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)}))
    $Row.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{Width=[System.Windows.GridLength]::Auto}))
    
    $Bor = New-Object System.Windows.Controls.Border; $Bor.CornerRadius = 8; $Bor.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#252526"); $Bor.Padding = "10"; $Bor.Child = $Row; $Bor.Cursor = "Hand"
    
    $Img = New-Object System.Windows.Controls.Image; $Img.Width = 32; $Img.Height = 32; if($b.IconObj){$Img.Source=$b.IconObj}; [System.Windows.Controls.Grid]::SetColumn($Img,0); $Row.Children.Add($Img)|Out-Null
    $Txt = New-Object System.Windows.Controls.TextBlock; $Txt.Text = $b.Name; $Txt.Foreground="White"; $Txt.FontSize=16; $Txt.FontWeight="SemiBold"; $Txt.VerticalAlignment="Center"; $Txt.Margin="15,0,0,0"; if(!$b.Installed){$Txt.Text+=" (Not Installed)";$Txt.Foreground="#666666"}; [System.Windows.Controls.Grid]::SetColumn($Txt,1); $Row.Children.Add($Txt)|Out-Null
    $Chk = New-Object System.Windows.Controls.CheckBox; $Chk.Style=$Window.Resources["BlueSwitch"]; $Chk.VerticalAlignment="Center"; $Chk.Tag=$b; if($b.Installed){$Chk.IsChecked=$true}else{$Chk.IsEnabled=$false;$Chk.IsChecked=$false;$Bor.Opacity=0.5}; [System.Windows.Controls.Grid]::SetColumn($Chk,2); $Row.Children.Add($Chk)|Out-Null
    
    $Stack.Children.Add($Bor)|Out-Null
    if($b.Installed){ $Bor.Add_MouseLeftButtonUp({param($s,$e)$Chk.IsChecked = -not $Chk.IsChecked}) }
}

$BF.Add_Click({ Start-Process "https://www.facebook.com/Adm1n1straTOE" }); $BG.Add_Click({ Start-Process "https://github.com/itgroceries-sudo/Youtube-On-TV/tree/main" }); $BC.Add_Click({ $Window.Close() })
$BA.Add_Click({
    $Sel = $Stack.Children | Where-Object { $_.Child.Children[2].IsChecked }; if ($Sel.Count -eq 0) { return }
    $BA.IsEnabled = $false; $BA.Content = "Processing..."; foreach ($i in $Sel) { Install $i.Child.Children[2].Tag }; 
    $BA.Content = "Finished"; [System.Console]::Beep(1000, 200); Start-Sleep 2; $BA.IsEnabled = $true; $BA.Content = "Start Install"
})

$Window.ShowDialog() | Out-Null
