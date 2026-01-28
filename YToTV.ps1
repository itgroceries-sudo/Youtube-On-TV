<# :
@echo off
:: ✅ Code: Hybrid Script" (Polyglot) 🧬
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command "Get-Content -LiteralPath '%~f0' | Out-String | Invoke-Expression"
goto :EOF
:: =========================================================
::  YOUTUBE TV INSTALLER v23.0 (LAYOUT REMASTERED)
::  Engine: Tizen 9.0 | UI: Header Side-by-Side
:: =========================================================
title IT Groceries Shop - Console
setlocal
cd /d %~dp0

:: Admin Check
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting Administrator privileges...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    goto :eof
)

:: Run PowerShell
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-Expression ($(Get-Content '%~f0' -Raw))"
goto :eof
#>

# =========================================================
#  POWERSHELL LOGIC
# =========================================================

# 1. SETUP
$host.UI.RawUI.WindowTitle = "Installer Log Console"
$host.UI.RawUI.BackgroundColor = "Black"
$host.UI.RawUI.ForegroundColor = "Green"
Clear-Host

Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, System.Drawing

# Trap Errors
trap {
    Write-Host "`n[CRITICAL ERROR] $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Script stopped. Press Enter to exit..." -ForegroundColor Gray
    Read-Host
    exit
}

# Win32 API
Add-Type -Name Win32 -Namespace Native -MemberDefinition '
[DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
[DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")] public static extern int SendMessage(IntPtr hWnd, int msg, int wParam, IntPtr lParam);
[DllImport("user32.dll")] public static extern IntPtr LoadImage(IntPtr hinst, string lpszName, uint uType, int cxDesired, int cyDesired, uint fuLoad);
'

# Temp Directory
$TempDir = "$env:TEMP\YT_Installer_Assets_v23"
if (-not (Test-Path $TempDir)) { New-Item -ItemType Directory -Force -Path $TempDir | Out-Null }

# --- ASSETS CONFIG ---
$BaseUrl = "https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles"
$Assets = @{
    "MenuIcon"    = "https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/YouTube.ico"
    "ConsoleIcon" = "https://itgroceries.blogspot.com/favicon.ico"
    "Chrome"      = "$BaseUrl/Chrome.ico"
    "Edge"        = "$BaseUrl/Edge.ico"
    "Brave"       = "$BaseUrl/Brave.ico"
    "Vivaldi"     = "$BaseUrl/Vivaldi.ico"
    "Yandex"      = "$BaseUrl/Yandex.ico"
    "Chromium"    = "$BaseUrl/Chromium.ico" 
    "Thorium"     = "$BaseUrl/Thorium.ico" 
}

# Download Helper
function Download-Asset ($Url, $Name) {
    $Dest = "$TempDir\$Name"
    if (-not (Test-Path $Dest)) {
        try { 
            [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
            (New-Object System.Net.WebClient).DownloadFile($Url, $Dest) 
            Write-Host " [DOWNLOAD] OK: $Name" -ForegroundColor DarkGray
        } catch {
            Write-Host " [DOWNLOAD] FAIL: $Name" -ForegroundColor DarkRed
        }
    } else {
        Write-Host " [CACHE] OK: $Name" -ForegroundColor DarkGray
    }
    return $Dest
}

# --- PRE-LOADER ---
Write-Host "==========================================================" -ForegroundColor Yellow
Write-Host "   DOWNLOADING ASSETS..." -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Yellow

foreach ($key in $Assets.Keys) { Download-Asset $Assets[$key] "$key.ico" | Out-Null }

$LocalMenuIcon = "$TempDir\MenuIcon.ico"
$LocalConsoleIcon = "$TempDir\ConsoleIcon.ico"

# Set Console Icon
if (Test-Path $LocalConsoleIcon) {
    try {
        $ConsoleHandle = [Native.Win32]::GetConsoleWindow()
        $hIcon = [Native.Win32]::LoadImage([IntPtr]::Zero, $LocalConsoleIcon, 1, 0, 0, 0x0010)
        if ($hIcon -ne [IntPtr]::Zero) {
            [Native.Win32]::SendMessage($ConsoleHandle, 0x80, 0, $hIcon) | Out-Null
            [Native.Win32]::SendMessage($ConsoleHandle, 0x80, 1, $hIcon) | Out-Null
        }
    } catch {}
}

# 2. WINDOW POSITION (Adjusted Height for Thorium)
$Screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
$WidthPerWindow = 500   
$HeightCommon = 820     # เพิ่มความสูงเป็น 820 เพื่อไม่ให้ Thorium ตกขอบ
$Gap = 10                
$TotalWidth = ($WidthPerWindow * 2) + $Gap
$StartX = ($Screen.Width - $TotalWidth) / 2
$StartY = ($Screen.Height - $HeightCommon) / 2

$ConsoleHandle = [Native.Win32]::GetConsoleWindow()
[Native.Win32]::MoveWindow($ConsoleHandle, $StartX, $StartY, $WidthPerWindow, $HeightCommon, $true) | Out-Null

Write-Host "`n=========================================================="
Write-Host "    YOUTUBE TV INSTALLER v23.0 (LAYOUT FIX)"
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "[INIT] Engine: Tizen 9.0 (2025)"
Write-Host "[INIT] Scanning installed browsers..."

# 3. CONFIG & BROWSER DETECTION
$DesktopPath = [System.Environment]::GetFolderPath('Desktop')
$ProgramFiles = $env:ProgramFiles
$ProgramFilesX86 = ${env:ProgramFiles(x86)}
$ForceURL = "https://youtube.com/tv"
$UA_Universal = "Mozilla/5.0 (SMART-TV; LINUX; Tizen 9.0) AppleWebKit/537.36 (KHTML, like Gecko) 120.0.6099.5/9.0 TV Safari/537.36"
$BackgroundFlags = "--disable-features=CalculateNativeWinOcclusion --disable-background-timer-throttling --disable-renderer-backgrounding --disable-backgrounding-occluded-windows"

$BrowserDefinitions = @(
    @{ Name="Google Chrome";   ExeName="chrome.exe";  IconKey="Chrome";  Paths=@("$ProgramFiles\Google\Chrome\Application\chrome.exe", "$ProgramFilesX86\Google\Chrome\Application\chrome.exe") },
    @{ Name="Microsoft Edge";  ExeName="msedge.exe";  IconKey="Edge";    Paths=@("$ProgramFilesX86\Microsoft\Edge\Application\msedge.exe", "$ProgramFiles\Microsoft\Edge\Application\msedge.exe") },
    @{ Name="Brave Browser";   ExeName="brave.exe";   IconKey="Brave";   Paths=@("$ProgramFiles\BraveSoftware\Brave-Browser\Application\brave.exe", "$ProgramFilesX86\BraveSoftware\Brave-Browser\Application\brave.exe") },
    @{ Name="Vivaldi";         ExeName="vivaldi.exe"; IconKey="Vivaldi"; Paths=@("$env:LOCALAPPDATA\Vivaldi\Application\vivaldi.exe", "$ProgramFiles\Vivaldi\Application\vivaldi.exe") },
    @{ Name="Yandex Browser";  ExeName="browser.exe"; IconKey="Yandex";  Paths=@("$env:LOCALAPPDATA\Yandex\YandexBrowser\Application\browser.exe") },
    @{ Name="Chromium";        ExeName="chrome.exe";  IconKey="Chromium"; Paths=@("$env:LOCALAPPDATA\Chromium\Application\chrome.exe", "$ProgramFiles\Chromium\Application\chrome.exe") },
    @{ Name="Thorium";         ExeName="thorium.exe"; IconKey="Thorium";  Paths=@("$env:LOCALAPPDATA\Thorium\Application\thorium.exe", "$ProgramFiles\Thorium\Application\thorium.exe") }
)

$DetectedBrowsers = @()

foreach ($b in $BrowserDefinitions) {
    $FoundPath = $null
    foreach ($p in $b.Paths) {
        if ($p -and (Test-Path $p)) { $FoundPath = $p; break }
    }
    
    $IconPath = "$TempDir\$($b.IconKey).ico"

    if ($FoundPath) {
        Write-Host " [FOUND] $($b.Name)" -ForegroundColor Green
        $DetectedBrowsers += @{ Name=$b.Name; Path=$FoundPath; Exe=$b.ExeName; Installed=$true; IconPath=$IconPath }
    } else {
        Write-Host " [MISS]  $($b.Name)" -ForegroundColor Gray
        $DetectedBrowsers += @{ Name=$b.Name; Path=$null; Exe=$b.ExeName; Installed=$false; IconPath=$IconPath }
    }
}

# 4. GUI WPF (XAML - Redesigned Header)
$GuiLeft = $StartX + $WidthPerWindow + $Gap 

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="YouTube TV Installer" Height="$HeightCommon" Width="$WidthPerWindow"
        WindowStartupLocation="Manual" Left="$GuiLeft" Top="$StartY"
        ResizeMode="NoResize" Background="#181818" Topmost="True">

    <Window.Resources>
        <Style x:Key="BlueSwitch" TargetType="{x:Type CheckBox}">
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="{x:Type CheckBox}">
                        <Border x:Name="SwitchTrack" Width="44" Height="24" Background="#3E3E3E" CornerRadius="12" Cursor="Hand">
                            <Border x:Name="SwitchThumb" Width="20" Height="20" Background="White" CornerRadius="10" HorizontalAlignment="Left" Margin="2,0,0,0">
                                <Border.RenderTransform><TranslateTransform x:Name="ThumbTransform" X="0"/></Border.RenderTransform>
                            </Border>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsChecked" Value="True">
                                <Trigger.EnterActions><BeginStoryboard><Storyboard>
                                    <DoubleAnimation Storyboard.TargetName="ThumbTransform" Storyboard.TargetProperty="X" To="20" Duration="0:0:0.2"/>
                                    <ColorAnimation Storyboard.TargetName="SwitchTrack" Storyboard.TargetProperty="Background.Color" To="#2196F3" Duration="0:0:0.2"/>
                                </Storyboard></BeginStoryboard></Trigger.EnterActions>
                                <Trigger.ExitActions><BeginStoryboard><Storyboard>
                                    <DoubleAnimation Storyboard.TargetName="ThumbTransform" Storyboard.TargetProperty="X" To="0" Duration="0:0:0.2"/>
                                    <ColorAnimation Storyboard.TargetName="SwitchTrack" Storyboard.TargetProperty="Background.Color" To="#3E3E3E" Duration="0:0:0.2"/>
                                </Storyboard></BeginStoryboard></Trigger.ExitActions>
                            </Trigger>
                            <Trigger Property="IsEnabled" Value="False">
                                <Setter Property="Opacity" Value="0.5"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style x:Key="ActionButton" TargetType="Button">
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border x:Name="border" Background="{TemplateBinding Background}" CornerRadius="22">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" TextElement.FontWeight="Bold"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="border" Property="Opacity" Value="0.8"/></Trigger>
                            <Trigger Property="IsEnabled" Value="False"><Setter Property="Background" Value="#333333"/><Setter Property="Foreground" Value="#777777"/></Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Grid Margin="25">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/> <RowDefinition Height="20"/>   <RowDefinition Height="*"/>    <RowDefinition Height="Auto"/> </Grid.RowDefinitions>

        <Grid Grid.Row="0">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="Auto"/> <ColumnDefinition Width="*"/>    </Grid.ColumnDefinitions>

            <Image x:Name="LogoImage" Grid.Column="0" Width="80" Height="80" RenderOptions.BitmapScalingMode="HighQuality"/>

            <StackPanel Grid.Column="1" VerticalAlignment="Center" Margin="20,0,0,0">
                <TextBlock Text="YouTube TV Installer" Foreground="White" FontSize="28" FontWeight="Bold">
                    <TextBlock.Effect><DropShadowEffect Color="#FF0000" BlurRadius="15" ShadowDepth="0" Opacity="0.6"/></TextBlock.Effect>
                </TextBlock>
                <StackPanel Orientation="Horizontal" Margin="2,5,0,0">
                    <TextBlock Text="Developed by" Foreground="#888888" FontSize="14" Margin="0,0,5,0"/>
                    <TextBlock Text="IT Groceries Shop &#x2665;&#x2665;&#x2665;" Foreground="#FF0000" FontSize="14" FontWeight="Bold"/>
                </StackPanel>
            </StackPanel>
        </Grid>

        <Border Grid.Row="2" Background="#1E1E1E">
            <ScrollViewer VerticalScrollBarVisibility="Hidden">
                <StackPanel x:Name="BrowserStackPanel"/>
            </ScrollViewer>
        </Border>

        <Grid Grid.Row="3" Margin="0,20,0,0">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>

            <StackPanel Orientation="Horizontal" Grid.Column="0">
                 <Button x:Name="BtnFB" Width="45" Height="45" Background="#1877F2" Style="{StaticResource ActionButton}" Margin="0,0,10,0" ToolTip="Facebook" Cursor="Hand">
                    <TextBlock Text="f" Foreground="White" FontSize="26" FontWeight="Bold" Margin="0,-4,0,0"/>
                 </Button>
                 
                 <Button x:Name="BtnGH" Width="45" Height="45" Background="#333333" Style="{StaticResource ActionButton}" ToolTip="GitHub" Cursor="Hand">
                    <Viewbox Width="24" Height="24">
                        <Path Fill="White" Data="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12"/>
                    </Viewbox>
                 </Button>
            </StackPanel>

            <StackPanel Orientation="Horizontal" Grid.Column="2">
                <Button x:Name="BtnCancel" Content="EXIT" Width="90" Height="45" Background="#D32F2F" Foreground="White" Style="{StaticResource ActionButton}" Margin="0,0,10,0" Cursor="Hand"/>
                <Button x:Name="BtnApply" Content="Start Install" Width="160" Height="45" Background="#2E7D32" Foreground="White" Style="{StaticResource ActionButton}" Cursor="Hand"/>
            </StackPanel>
        </Grid>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$Window = [Windows.Markup.XamlReader]::Load($reader)

# --- APPLY ICONS ---
$ImgDecoder = [System.Windows.Media.Imaging.BitmapFrame]

# 1. Window Icon & Logo (Side-by-Side Header)
if (Test-Path $LocalMenuIcon) {
    try {
        $Uri = New-Object Uri($LocalMenuIcon)
        $Bmp = $ImgDecoder::Create($Uri)
        $Window.Icon = $Bmp
        
        $LogoImage = $Window.FindName("LogoImage")
        if ($LogoImage) { $LogoImage.Source = $Bmp }
    } catch {}
}

# 2. Browser List Items (MANUAL BUILD)
$BrowserStackPanel = $Window.FindName("BrowserStackPanel")
$BtnApply = $Window.FindName("BtnApply")
$BtnCancel = $Window.FindName("BtnCancel")
$BtnFB = $Window.FindName("BtnFB")
$BtnGH = $Window.FindName("BtnGH")

$CheckBoxList = @()

foreach ($b in $DetectedBrowsers) {
    $Row = New-Object System.Windows.Controls.Grid
    $Row.Margin = "0,5,0,5"
    $Row.Height = 45
    
    $Col1 = New-Object System.Windows.Controls.ColumnDefinition; $Col1.Width = [System.Windows.GridLength]::Auto
    $Col2 = New-Object System.Windows.Controls.ColumnDefinition; $Col2.Width = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)
    $Col3 = New-Object System.Windows.Controls.ColumnDefinition; $Col3.Width = [System.Windows.GridLength]::Auto
    
    $Row.ColumnDefinitions.Add($Col1)
    $Row.ColumnDefinitions.Add($Col2)
    $Row.ColumnDefinitions.Add($Col3)
    
    $Border = New-Object System.Windows.Controls.Border
    $Border.CornerRadius = 8
    $Border.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#252526")
    $Border.Padding = "10"
    $Border.Child = $Row
    $Border.Cursor = "Hand"
    
    # 1. Image
    $Img = New-Object System.Windows.Controls.Image
    $Img.Width = 32
    $Img.Height = 32
    $Img.VerticalAlignment = "Center"
    
    if (Test-Path $b.IconPath) {
        try {
            $Uri = New-Object Uri($b.IconPath)
            $Img.Source = $ImgDecoder::Create($Uri)
        } catch {}
    }
    
    [System.Windows.Controls.Grid]::SetColumn($Img, 0)
    $Row.Children.Add($Img) | Out-Null
    
    # 2. Text
    $Txt = New-Object System.Windows.Controls.TextBlock
    $Txt.Text = $b.Name
    $Txt.Foreground = "White"
    $Txt.FontSize = 16
    $Txt.FontWeight = "SemiBold"
    $Txt.VerticalAlignment = "Center"
    $Txt.Margin = "15,0,0,0"
    
    if (-not $b.Installed) {
        $Txt.Text += " (Not Installed)"
        $Txt.Foreground = "#666666"
    }
    
    [System.Windows.Controls.Grid]::SetColumn($Txt, 1)
    $Row.Children.Add($Txt) | Out-Null
    
    # 3. Checkbox
    $Chk = New-Object System.Windows.Controls.CheckBox
    $Chk.Style = $Window.Resources["BlueSwitch"]
    $Chk.VerticalAlignment = "Center"
    $Chk.Tag = $b
    
    if ($b.Installed) {
        $Chk.IsChecked = $true
    } else {
        $Chk.IsEnabled = $false
        $Chk.IsChecked = $false
        $Border.Opacity = 0.5
    }
    
    [System.Windows.Controls.Grid]::SetColumn($Chk, 2)
    $Row.Children.Add($Chk) | Out-Null
    $CheckBoxList += $Chk
    
    $BrowserStackPanel.Children.Add($Border) | Out-Null
    
    if ($b.Installed) {
        $Border.Add_MouseLeftButtonUp({ 
            param($s,$e) 
            $Chk.IsChecked = -not $Chk.IsChecked 
        })
    }
}

# --- Actions ---
$BtnFB.Add_Click({ Start-Process "https://www.facebook.com/Adm1n1straTOE" })
$BtnGH.Add_Click({ Start-Process "https://github.com/itgroceries-sudo/Youtube-On-TV/tree/main" })
$BtnCancel.Add_Click({ $Window.Close() })

$BtnApply.Add_Click({
    $SelectedItems = $CheckBoxList | Where-Object { $_.IsChecked }
    if ($SelectedItems.Count -eq 0) { return }

    $BtnApply.IsEnabled = $false
    $BtnApply.Content = "Processing..."
    
    foreach ($cb in $SelectedItems) {
        $BrowserObj = $cb.Tag
        Write-Host "[TASK] Creating for: $($BrowserObj.Name)" -ForegroundColor Yellow
        try {
            $Suffix = $BrowserObj.Name.Replace(" ", "").Replace("Browser", "")
            $ShortcutFile = Join-Path $DesktopPath "Youtube On TV - $Suffix.lnk"
            
            $WScript = New-Object -ComObject WScript.Shell
            $s = $WScript.CreateShortcut($ShortcutFile)
            $s.TargetPath = "cmd.exe"
            
            $CmdArgs = "/c taskkill /f /im $($BrowserObj.Exe) /t >nul 2>&1 & start `"`" `"$($BrowserObj.Path)`" --profile-directory=Default --app=$ForceURL --user-agent=`"$UA_Universal`" --start-fullscreen $BackgroundFlags"
            
            $s.Arguments = $CmdArgs
            $s.WindowStyle = 3
            if (Test-Path $LocalMenuIcon) { $s.IconLocation = $LocalMenuIcon }
            $s.Save()
            Write-Host " [OK] Created." -ForegroundColor Green
        } catch { Write-Host " [ERR] $_" -ForegroundColor Red }
    }
    $BtnApply.Content = "Finished"
    [System.Console]::Beep(1000, 200)
    Start-Sleep 2
    $BtnApply.IsEnabled = $true
    $BtnApply.Content = "Start Install"
})

$Window.ShowDialog() | Out-Null
Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue
