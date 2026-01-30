<# : hybrid batch + powershell script
@powershell -noprofile -Window Hidden -c "$param='%*';$ScriptPath='%~f0';iex((Get-Content('%~f0') -Raw))"&exit/b
#>

# =========================================================
#  YOUTUBE TV INSTALLER v80.0 (SOLID BLUE BORDER)
#  Status: Visual Fix | Standard Window w/ Custom Border
# =========================================================

# --- [1. INITIAL SETUP] ---
$InstallDir = "$env:LOCALAPPDATA\ITG_YToTV"
$TempScript = "$env:TEMP\YToTV.ps1"
$GitHubRaw = "https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/branch"
$SelfURL = "$GitHubRaw/80.ps1"
$AppVersion = "2.0 Build 26.80"
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
[DllImport("user32.dll")] public static extern int GetWindowLong(IntPtr hWnd, int nIndex);
[DllImport("user32.dll")] public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);
'@
Add-Type -MemberDefinition $User32Def -Name "User32" -Namespace Win32

if (!$Silent) { [Win32.User32]::ShowWindow([Win32.User32]::GetConsoleWindow(), 5) | Out-Null }

# --- [3. ADMIN CHECK] ---
$Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = [Security.Principal.WindowsPrincipal]$Identity
if (-not $Silent -and -not $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Clear-Host
    Write-Host "`n==========================================" -ForegroundColor Yellow
    Write-Host "   ADMIN PRIVILEGES REQUIRED              " -ForegroundColor Red
    Write-Host "==========================================" -ForegroundColor Yellow
    Write-Host " This program needs Admin rights to install."
    Write-Host " Please press [ENTER] to continue..." -ForegroundColor Cyan
    Read-Host 
    $PassArgs = @()
    if ($Browser -ne "Ask") { $PassArgs += "-Browser"; $PassArgs += $Browser }
    if (!$IsLocal) {
        Write-Host " [INIT] Downloading script for elevation..." -ForegroundColor Yellow
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

if ($Silent) {
    [Win32.User32]::ShowWindow($ConsoleHandle, 0) | Out-Null
} else {
    $host.UI.RawUI.WindowTitle = "Installer Log Console"
    $host.UI.RawUI.BackgroundColor = "Black"
    $host.UI.RawUI.ForegroundColor = "Gray"
    Clear-Host
    [Win32.User32]::SetWindowPos($ConsoleHandle, [IntPtr]-1, [int]$StartX_Px, [int]$StartY_Px, [int]$ConsoleW_Px, [int]$ConsoleH_Px, 0x0040) | Out-Null
    
    $GWL_STYLE = -16; $WS_SYSMENU = 0x00080000
    $CurStyle = [Win32.User32]::GetWindowLong($ConsoleHandle, $GWL_STYLE)
    if ($CurStyle -ne 0) { [Win32.User32]::SetWindowLong($ConsoleHandle, $GWL_STYLE, ($CurStyle -band (-not $WS_SYSMENU))) | Out-Null }

    $GWL_EXSTYLE = -20; $WS_EX_TOOLWINDOW = 0x00000080
    $CurExStyle = [Win32.User32]::GetWindowLong($ConsoleHandle, $GWL_EXSTYLE)
    [Win32.User32]::SetWindowLong($ConsoleHandle, $GWL_EXSTYLE, ($CurExStyle -bor $WS_EX_TOOLWINDOW)) | Out-Null
    [Win32.User32]::SetWindowPos($ConsoleHandle, [IntPtr]0, 0, 0, 0, 0, 0x0027) | Out-Null 
    
    Write-Host "==========================================" -ForegroundColor Yellow
    Write-Host "   DOWNLOADING ASSETS...                  " -ForegroundColor Yellow
    Write-Host "==========================================" -ForegroundColor Yellow
}

# Assets
if (-not (Test-Path $InstallDir)) { New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null }
$Assets = @{
    "MenuIcon" = "$GitHubRaw/YouTube.ico"; "ConsoleIcon" = "https://itgroceries.blogspot.com/favicon.ico"
    "Chrome"="$GitHubRaw/IconFiles/Chrome.ico"; "Edge"="$GitHubRaw/IconFiles/Edge.ico"; "Brave"="$GitHubRaw/IconFiles/Brave.ico"
    "Vivaldi"="$GitHubRaw/IconFiles/Vivaldi.ico"; "Yandex"="$GitHubRaw/IconFiles/Yandex.ico"; "Chromium"="$GitHubRaw/IconFiles/Chromium.ico"; "Thorium"="$GitHubRaw/IconFiles/Thorium.ico"
}

function DL ($U, $N) { 
    $D="$InstallDir\$N"
    if(!(Test-Path $D) -or (Get-Item $D).Length -lt 100){ try{ (New-Object Net.WebClient).DownloadFile($U,$D) }catch{} }
    return $D
}
foreach($k in $Assets.Keys){ DL $Assets[$k] "$k.ico" | Out-Null }
$LocalIcon = "$InstallDir\MenuIcon.ico"; $ConsoleIcon = "$InstallDir\ConsoleIcon.ico"

# GUI XAML (v80 - SOLID BORDER FIX)
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
Title="YouTube TV Installer" Height="$BaseH" Width="$BaseW" WindowStartupLocation="Manual" ResizeMode="NoResize" Background="#181818" Topmost="True" WindowStyle="None" BorderBrush="#2196F3" BorderThickness="2">
    <Window.Resources>
        <Style x:Key="BlueSwitch" TargetType="{x:Type CheckBox}">
            <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="{x:Type CheckBox}">
                <Border x:Name="T" Width="44" Height="24" Background="#3E3E3E" CornerRadius="12" Cursor="Hand"><Border x:Name="D" Width="20" Height="20" Background="White" CornerRadius="10" HorizontalAlignment="Left" Margin="2,0,0,0"><Border.RenderTransform><TranslateTransform x:Name="Tr" X="0"/></Border.RenderTransform></Border></Border>
                <ControlTemplate.Triggers><Trigger Property="IsChecked" Value="True"><Trigger.EnterActions><BeginStoryboard><Storyboard><DoubleAnimation Storyboard.TargetName="Tr" Storyboard.TargetProperty="X" To="20" Duration="0:0:0.2"/><ColorAnimation Storyboard.TargetName="T" Storyboard.TargetProperty="Background.Color" To="#2196F3" Duration="0:0:0.2"/></Storyboard></BeginStoryboard></Trigger.EnterActions><Trigger.ExitActions><BeginStoryboard><Storyboard><DoubleAnimation Storyboard.TargetName="Tr" Storyboard.TargetProperty="X" To="0" Duration="0:0:0.2"/><ColorAnimation Storyboard.TargetName="T" Storyboard.TargetProperty="Background.Color" To="#3E3E3E" Duration="0:0:0.2"/></Storyboard></BeginStoryboard></Trigger.ExitActions></Trigger></ControlTemplate.Triggers>
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
                <TextBlock Text="Developed by IT Groceries Shop &#x2665;" Foreground="#FF0000" FontSize="14" FontWeight="Bold" Margin="2,5,0,0"/>
            </StackPanel>
            <Button x:Name="BAbt" Grid.Column="1" HorizontalAlignment="Right" VerticalAlignment="Top" Width="30" Height="30" Background="Transparent" BorderThickness="0" Cursor="Hand" Margin="0,5,0,0" ToolTip="About"><Viewbox Width="20" Height="20"><Path Fill="#AAAAAA" Data="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 17h-2v-2h2v2zm2.07-7.75l-.9.92C13.45 12.9 13 13.5 13 15h-2v-.5c0-1.1.45-2.1 1.17-2.83l1.24-1.26c.37-.36.59-.86.59-1.41 0-1.1-9-2-2-2s-2 .9-2 2H8c0-2.21 1.79-4 4-4s4 1.79 4 4c0 .88-.36 1.68-.93 2.25z"/></Viewbox></Button>
        </Grid>
        <Border Grid.Row="2" Background="#1E1E1E"><ScrollViewer VerticalScrollBarVisibility="Hidden"><StackPanel x:Name="List"/></ScrollViewer></Border>
        <Grid Grid.Row="3" Margin="0,20,0,0"><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
            <StackPanel Orientation="Horizontal" Grid.Column="0">
                 <Button x:Name="BF" Width="45" Height="45" Background="#1877F2" Style="{StaticResource Btn}" Margin="0,0,10,0" ToolTip="Facebook" Cursor="Hand"><TextBlock Text="f" Foreground="White" FontSize="26" FontWeight="Bold" Margin="0,-4,0,0"/></Button>
                 <Button x:Name="BG" Width="45" Height="45" Background="#333333" Style="{StaticResource Btn}" ToolTip="GitHub" Cursor="Hand"><Viewbox Width="24" Height="24"><Path Fill="White" Data="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12"/></Viewbox></Button>
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
$Window.Add_MouseLeftButtonDown({ $this.DragMove() })

$Window.Add_LocationChanged({
    if (!$Silent) {
        $ConsX = ($Window.Left * $Scale) - $ConsoleW_Px - ($Gap * $Scale)
        $ConsY = ($Window.Top * $Scale)
        $NewH = $Window.ActualHeight * $Scale
        [Win32.User32]::SetWindowPos($ConsoleHandle, [IntPtr]-1, [int]$ConsX, [int]$ConsY, [int]$ConsoleW_Px, [int]$NewH, 0x0040) | Out-Null
    }
})

$Window.Add_StateChanged({
    if (!$Silent) {
        if ($Window.WindowState -eq "Minimized") { [Win32.User32]::ShowWindow($ConsoleHandle, 0) | Out-Null }
        else { [Win32.User32]::ShowWindow($ConsoleHandle, 4) | Out-Null }
    }
})

# Browser Logic & List Building
$PF = $env:ProgramFiles; $PF86 = ${env:ProgramFiles(x86)}; $L = $env:LOCALAPPDATA
$Global:Browsers = @(
    @{N="Google Chrome"; E="chrome.exe"; K="Chrome"; URL="https://www.google.com/chrome/"; P=@("$PF\Google\Chrome\Application\chrome.exe","$PF86\Google\Chrome\Application\chrome.exe")}
    @{N="Microsoft Edge"; E="msedge.exe"; K="Edge"; URL="https://www.microsoft.com/edge"; P=@("$PF86\Microsoft\Edge\Application\msedge.exe","$PF\Microsoft\Edge\Application\msedge.exe")}
    @{N="Brave Browser"; E="brave.exe"; K="Brave"; URL="https://brave.com/download/"; P=@("$PF\BraveSoftware\Brave-Browser\Application\brave.exe","$PF86\BraveSoftware\Brave-Browser\Application\brave.exe")}
    @{N="Vivaldi"; E="vivaldi.exe"; K="Vivaldi"; URL="https://vivaldi.com/download/"; P=@("$L\Vivaldi\Application\vivaldi.exe","$PF\Vivaldi\Application\vivaldi.exe")}
    @{N="Yandex Browser"; E="browser.exe"; K="Yandex"; URL="https://browser.yandex.com/"; P=@("$L\Yandex\YandexBrowser\Application\browser.exe")}
    @{N="Chromium"; E="chrome.exe"; K="Chromium"; URL="https://download-chromium.appspot.com/"; P=@("$L\Chromium\Application\chrome.exe","$PF\Chromium\Application\chrome.exe")}
    @{N="Thorium"; E="thorium.exe"; K="Thorium"; URL="https://thorium.rocks/"; P=@("$L\Thorium\Application\thorium.exe","$PF\Thorium\Application\thorium.exe")}
)

$Stack = $Window.FindName("List"); $BA = $Window.FindName("BA"); $BC = $Window.FindName("BC"); $BF = $Window.FindName("BF"); $BG = $Window.FindName("BG"); $BAbt = $Window.FindName("BAbt")
if (Test-Path $LocalIcon) { $Window.FindName("Logo").Source = $LocalIcon }

foreach ($b in $Global:Browsers) {
    $FP=$null; foreach($p in $b.P){ if($p -and (Test-Path $p)){ $FP=$p; break } }
    $IconPath = "$InstallDir\$($b.K).ico"
    $Row = New-Object System.Windows.Controls.Grid; $Row.Height = 45; $Row.Margin = "0,5,0,5"
    $Row.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{Width=[System.Windows.GridLength]::Auto}))
    $Row.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{Width=[System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)}))
    $Row.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{Width=[System.Windows.GridLength]::Auto}))
    $Bor = New-Object System.Windows.Controls.Border; $Bor.CornerRadius = 8; $Bor.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#252526"); $Bor.Padding = "10"; $Bor.Child = $Row; $Bor.Cursor = "Hand"; $Bor.Tag = $b.URL
    $Img = New-Object System.Windows.Controls.Image; $Img.Width = 32; $Img.Height = 32; if (Test-Path $IconPath) { $Img.Source = $IconPath }
    [System.Windows.Controls.Grid]::SetColumn($Img,0); $Row.Children.Add($Img)|Out-Null
    $Txt = New-Object System.Windows.Controls.TextBlock; $Txt.Text = $b.N; $Txt.Foreground="White"; $Txt.FontSize=16; $Txt.FontWeight="SemiBold"; $Txt.VerticalAlignment="Center"; $Txt.Margin="15,0,0,0"
    $Chk = New-Object System.Windows.Controls.CheckBox; $Chk.Style=$Window.Resources["BlueSwitch"]; $Chk.VerticalAlignment="Center"; $Chk.Tag = $b.N
    if ($b.N -match "Brave") { $Txt.Text += " (Recommended)"; $Chk.IsChecked = $true }
    if (!$FP) { $Txt.Text += " (Click to Download)"; $Txt.Foreground="#55AAFF"; $Chk.IsEnabled=$false; $Bor.Opacity=0.8 }
    [System.Windows.Controls.Grid]::SetColumn($Txt,1); $Row.Children.Add($Txt)|Out-Null
    [System.Windows.Controls.Grid]::SetColumn($Chk,2); $Row.Children.Add($Chk)|Out-Null
    $Stack.Children.Add($Bor)|Out-Null
    $Bor.Add_MouseLeftButtonUp({ param($s, $e) $cb = $s.Child.Children[2]; if ($cb.IsEnabled) { $cb.IsChecked = -not $cb.IsChecked } else { if ($s.Tag) { Start-Process $s.Tag } } })
}

$BF.Add_Click({ Start-Process "https://www.facebook.com/Adm1n1straTOE" })
$BG.Add_Click({ Start-Process "https://github.com/itgroceries-sudo/Youtube-On-TV" })
$BC.Add_Click({ 
    if(!$Silent){ Write-Host "`n [EXIT] Clean & Bye !!" -ForegroundColor Cyan }
    [System.Windows.Forms.Application]::DoEvents(); Start-Sleep 2 
    if ($PSCommandPath -eq $TempScript) { Start-Process "cmd.exe" -ArgumentList "/c timeout /t 2 >nul & del `"$TempScript`"" -WindowStyle Hidden }
    $Window.Close() 
})
$BAbt.Add_Click({ [System.Windows.MessageBox]::Show("YouTube TV Installer v$AppVersion`n`nDeveloped by IT Groceries Shop", "About") | Out-Null })

$Window.ShowDialog() | Out-Null
