<# : hybrid batch + powershell script
@powershell -noprofile -Window Hidden -c "$param='%*';$ScriptPath='%~f0';iex((Get-Content('%~f0') -Raw))"&exit/b
#>

# =========================================================
#  YOUTUBE TV INSTALLER v75.7.2 (CORRECTED LOGIC)
#  Version: 2.0 Build 23.75.7.2
#  File: 7572.ps1 | Branch: branch
#  Status: PC Mode URL Fix | UI Re-ordered | Launcher Wait
# =========================================================

# ---------------------------------------------------------
# [1] CONFIGURATION
# ---------------------------------------------------------
$AppVersion = "2.0 Build 23.75.7.2"
$BuildDate  = "04-02-2026"
$InstallDir = "$env:LOCALAPPDATA\ITG_YToTV"
$TempScript = "$env:TEMP\YToTV.ps1"
$GitHubRaw  = "https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/branch"
$SelfURL    = "$GitHubRaw/7572.ps1"

$TargetFile = if ($ScriptPath) { $ScriptPath } elseif ($PSScriptRoot) { $PSCommandPath } else { $null }

$Silent = $false; $Browser = "Ask"; $AddStartMenu = $false
$AllArgs = @(); if ($args) { $AllArgs += $args }; if ($param) { $AllArgs += $param.Split(" ") }
for ($i = 0; $i -lt $AllArgs.Count; $i++) {
    if ($AllArgs[$i] -eq "-Silent") { $Silent = $true; $AddStartMenu = $true }
    if ($AllArgs[$i] -eq "-StartMenu") { $AddStartMenu = $true }
    if ($AllArgs[$i] -eq "-Browser" -and ($i + 1 -lt $AllArgs.Count)) { $Browser = $AllArgs[$i+1] }
}

# ---------------------------------------------------------
# [2] API & CONSOLE
# ---------------------------------------------------------
$User32 = Add-Type -MemberDefinition '[DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow(); [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow); [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags); [DllImport("user32.dll")] public static extern IntPtr LoadImage(IntPtr hinst, string lpszName, uint uType, int cxDesired, int cyDesired, uint fuLoad); [DllImport("user32.dll")] public static extern int SendMessage(IntPtr hWnd, int msg, int wParam, IntPtr lParam); [DllImport("user32.dll")] public static extern int GetWindowLong(IntPtr hWnd, int nIndex); [DllImport("user32.dll")] public static extern int SetWindowLong(IntPtr hWnd, int nIndex, int dwNewLong);' -Name "User32" -Namespace Win32 -PassThru
$ConsoleHandle = [Win32.User32]::GetConsoleWindow()

# ---------------------------------------------------------
# [3] IT GROCERIES LAUNCHER (SECURITY CHECK)
# ---------------------------------------------------------
$Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = [Security.Principal.WindowsPrincipal]$Identity
$IsAdmin = $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $Silent -and -not $IsAdmin) {
    [Win32.User32]::ShowWindow($ConsoleHandle, 5) | Out-Null
    $host.UI.RawUI.WindowTitle = "IT Groceries Launcher ($((Get-Random -Minimum 1000 -Maximum 9999)))"
    $host.UI.RawUI.BackgroundColor = "DarkBlue"
    $host.UI.RawUI.ForegroundColor = "White"
    Clear-Host
    
    # [UPDATE] Relevant Header Title
    Write-Host "`n================================================================================" -ForegroundColor DarkGray
    Write-Host "                  YouTube TV Installer [ Cloud Edition ]                        " -ForegroundColor Cyan -BackgroundColor DarkBlue
    Write-Host "                       Powered by IT Groceries Shop                             " -ForegroundColor DarkCyan -BackgroundColor DarkBlue
    Write-Host "================================================================================" -ForegroundColor DarkGray
    Write-Host ""
    
    # [KEEP] Preserved Text
    Write-Host "        This software is provided as FREEWARE for educational usage." -ForegroundColor Yellow
    Write-Host "             Crafted with dedication to streamline your workflow." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "        If you find this tool helpful, please Support Us by" -ForegroundColor Gray
    Write-Host "        Subscribing to our YouTube Channel: " -NoNewline -ForegroundColor Gray
    Write-Host "IT Groceries" -ForegroundColor Green
    Write-Host ""
    Write-Host "       Your support drives our future updates. Thank you!" -ForegroundColor Magenta
    Write-Host ""
    Write-Host ""
    
    # [UPDATE] Clear Instruction for Admin Rights
    Write-Host "      [ PERMISSION CHECK ] Press Enter, then click 'Yes' to continue: " -NoNewline -ForegroundColor White
    
    # Wait for user input
    $null = Read-Host
}

# ---------------------------------------------------------
# [4] ADMIN ELEVATION
# ---------------------------------------------------------
if (-not $Silent -and -not $IsAdmin) {
    $PassArgs = @(); if ($Browser -ne "Ask") { $PassArgs += "-Browser"; $PassArgs += $Browser }
    if ($AddStartMenu) { $PassArgs += "-StartMenu" }
    if ($Silent) { $PassArgs += "-Silent" }
    try {
        if ($TargetFile -and (Test-Path $TargetFile)) {
            Start-Process "powershell" -ArgumentList (@("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$TargetFile`"") + $PassArgs) -Verb RunAs
        } else {
            (New-Object System.Net.WebClient).DownloadFile($SelfURL, $TempScript)
            Start-Process "powershell" -ArgumentList (@("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$TempScript`"") + $PassArgs) -Verb RunAs
        }
    } catch { Write-Host "`n [ERROR] Failed to elevate: $_" -ForegroundColor Red; Read-Host }
    exit 
}

# ---------------------------------------------------------
# [5] GUI PREP
# ---------------------------------------------------------
if ($Silent) { [Win32.User32]::ShowWindow($ConsoleHandle, 0) | Out-Null } else {
    [Win32.User32]::ShowWindow($ConsoleHandle, 5) | Out-Null
    $GWL_STYLE = -16; $WS_SYSMENU = 0x00080000
    $CurrentStyle = [Win32.User32]::GetWindowLong($ConsoleHandle, $GWL_STYLE)
    if (($CurrentStyle -band $WS_SYSMENU) -eq $WS_SYSMENU) {
        [Win32.User32]::SetWindowLong($ConsoleHandle, $GWL_STYLE, ($CurrentStyle -band (-not $WS_SYSMENU))) | Out-Null
        [Win32.User32]::SetWindowPos($ConsoleHandle, [IntPtr]0, 0, 0, 0, 0, 0x0027) | Out-Null
    }
}

Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, System.Drawing
$Graphics = [System.Drawing.Graphics]::FromHwnd([IntPtr]::Zero); $Scale = $Graphics.DpiX / 96.0; $Graphics.Dispose()
$BaseW = 600; $BaseH = 920; # Expanded height for new footer layout
$ConsoleW_Px = [int]($BaseW * $Scale); $ConsoleH_Px = [int]($BaseH * $Scale)
$Scr = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
$StartX_Px = ($Scr.Width - ($ConsoleW_Px * 2)) / 2; $StartY_Px = ($Scr.Height - $ConsoleH_Px) / 2

if (!$Silent) {
    $host.UI.RawUI.WindowTitle = "Installer Log Console"; $host.UI.RawUI.BackgroundColor = "Black"; $host.UI.RawUI.ForegroundColor = "Gray"; Clear-Host
    [Win32.User32]::SetWindowPos($ConsoleHandle, [IntPtr]::Zero, [int]$StartX_Px, [int]$StartY_Px, [int]$ConsoleW_Px, [int]$ConsoleH_Px, 0x0040) | Out-Null
    Write-Host "==========================================" -ForegroundColor Yellow
    Write-Host "   DOWNLOADING ASSETS...                  " -ForegroundColor Yellow
    Write-Host "==========================================" -ForegroundColor Yellow
}

if (-not (Test-Path $InstallDir)) { New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null }
$Assets = @{
    "MenuIcon" = "$GitHubRaw/YouTube.ico"; "ConsoleIcon" = "https://itgroceries.blogspot.com/favicon.ico"
    "Chrome"="$GitHubRaw/IconFiles/Chrome.ico"; "Edge"="$GitHubRaw/IconFiles/Edge.ico"; "Brave"="$GitHubRaw/IconFiles/Brave.ico"
    "Vivaldi"="$GitHubRaw/IconFiles/Vivaldi.ico"; "Yandex"="$GitHubRaw/IconFiles/Yandex.ico"; "Chromium"="$GitHubRaw/IconFiles/Chromium.ico"; "Thorium"="$GitHubRaw/IconFiles/Thorium.ico"
}
function DL ($U, $N) { 
    $D="$InstallDir\$N"; if(!(Test-Path $D) -or (Get-Item $D).Length -lt 100){ try{ (New-Object Net.WebClient).DownloadFile($U,$D); if(!$Silent){ Write-Host " [DOWNLOAD] OK: $N" -ForegroundColor Green } }catch{} } else { if(!$Silent){ Write-Host " [CACHE]    OK: $N" -ForegroundColor DarkGray } }
    return $D
}
foreach($k in $Assets.Keys){ DL $Assets[$k] "$k.ico" | Out-Null }
$LocalIcon = "$InstallDir\MenuIcon.ico"; $ConsoleIcon = "$InstallDir\ConsoleIcon.ico"
if(!$Silent -and (Test-Path $ConsoleIcon)){ $h=[Win32.User32]::LoadImage([IntPtr]::Zero, $ConsoleIcon, 1, 0, 0, 0x10); if($h){ [Win32.User32]::SendMessage($ConsoleHandle,0x80,[IntPtr]0,$h)|Out-Null; [Win32.User32]::SendMessage($ConsoleHandle,0x80,[IntPtr]1,$h)|Out-Null } }
if(!$Silent){ Write-Host "`n==========================================" -ForegroundColor Green; Write-Host "   (V.2 Build 23.75.7.2 : $BuildDate)     " -ForegroundColor Green; Write-Host "==========================================" -ForegroundColor Green; Write-Host " [INIT] Scanning installed browsers..." -ForegroundColor Green }

# ---------------------------------------------------------
# [6] LOGIC
# ---------------------------------------------------------
$Desktop = [Environment]::GetFolderPath("Desktop")
$StartMenu = [Environment]::GetFolderPath("CommonStartMenu") + "\Programs"
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

function Play-Sound($Type) { try { switch ($Type) { "Click" { [System.Media.SystemSounds]::Beep.Play() } "Tick" { [System.Console]::Beep(2000, 20) } "Warn" { [System.Media.SystemSounds]::Hand.Play() } "Done" { [System.Media.SystemSounds]::Asterisk.Play() } } } catch {} }

function Install-Browser {
    param($NameKey, $Uninstall=$false, $UseStartMenu=$false, $UseDesktop=$true, $IsPCMode=$false) 
    $Obj = $Global:Browsers | Where-Object { $_.N -eq $NameKey }; if (!$Obj) { return }
    $LnkName = "YouTube On TV - $($Obj.N).lnk"
    
    $Targets = @(); if ($UseDesktop) { $Targets += $Desktop }; if ($UseStartMenu) { $Targets += $StartMenu }
    
    if ($Uninstall) { 
        foreach ($p in $Targets) { 
            $FullPath = Join-Path $p $LnkName
            if (Test-Path $FullPath) { Remove-Item $FullPath -Force; if(!$Silent){ Write-Host " [REMOVE] $FullPath" -ForegroundColor Red } } 
            else { if(!$Silent){ Write-Host " [SKIP]   Not found: $LnkName" -ForegroundColor DarkGray } }
        } 
        return 
    }

    if (!$Obj.Path) { return }
    
    # [CORRECTED LOGIC] PC Mode vs TV Mode
    $SmartUA = "Mozilla/5.0 (SMART-TV; LINUX; Tizen 5.5) AppleWebKit/537.36 (KHTML, like Gecko) 69.0.3497.106/5.5 TV Safari/537.36"
    
    # If PC Mode: Standard YouTube URL, No Special UA (Simulates Desktop App)
    # If TV Mode: TV URL + Tizen UA (Simulates Smart TV)
    if ($IsPCMode) {
        $AppUrl = "https://www.youtube.com"
        $UserAgentStr = "" # No custom UA for PC
    } else {
        $AppUrl = "https://youtube.com/tv"
        $UserAgentStr = "--user-agent=`"$SmartUA`""
    }

    $ArgList = "/c taskkill /f /im $($Obj.E) /t >nul 2>&1 & start `"`" `"$($Obj.Path)`" --profile-directory=Default --app=$AppUrl $UserAgentStr --start-fullscreen --disable-features=CalculateNativeWinOcclusion --disable-renderer-backgrounding --disable-background-timer-throttling"

    foreach ($TargetDir in $Targets) {
        if (!$TargetDir) { continue }; if (-not (Test-Path $TargetDir)) { continue }
        $Sut = Join-Path $TargetDir $LnkName; $Ws = New-Object -Com WScript.Shell; $s = $Ws.CreateShortcut($Sut)
        $s.TargetPath = "cmd.exe"; $s.Arguments = $ArgList
        $s.WindowStyle = 3; $s.Description = "Enjoy Youtube On TV by IT Groceries"; if(Test-Path $LocalIcon){ $s.IconLocation = $LocalIcon }
        $s.Save()
    }
    if(!$Silent){ Write-Host " [INSTALL] $($Obj.N)... DONE" -ForegroundColor Green }
}

if ($Silent -or ($Browser -ne "Ask")) { foreach($b in $Global:Browsers){ if($b.N -match $Browser -or $b.K -match $Browser){ $FP=$null; foreach($p in $b.P){if(Test-Path $p){$FP=$p;break}}; if($FP){ $b.Path=$FP; Install-Browser $b.N $false $AddStartMenu $true $false } } }; exit }

# ---------------------------------------------------------
# [7] XAML UI
# ---------------------------------------------------------
if(!$Silent){ Write-Host "`n [INIT] Launching GUI..." -ForegroundColor Yellow }

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
Title="YouTube TV Installer" Height="$BaseH" Width="$BaseW" WindowStartupLocation="Manual" ResizeMode="NoResize" Background="#181818" Topmost="True" WindowStyle="None" BorderBrush="#2196F3" BorderThickness="4">
    <Window.Resources>
        <Style x:Key="BlueSwitch" TargetType="{x:Type CheckBox}">
            <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="{x:Type CheckBox}"><Border x:Name="T" Width="44" Height="24" Background="#3E3E3E" CornerRadius="22" Cursor="Hand"><Border x:Name="D" Width="20" Height="20" Background="White" CornerRadius="20" HorizontalAlignment="Left" Margin="2,0,0,0"><Border.RenderTransform><TranslateTransform x:Name="Tr" X="0"/></Border.RenderTransform></Border></Border><ControlTemplate.Triggers><Trigger Property="IsChecked" Value="True"><Trigger.EnterActions><BeginStoryboard><Storyboard><DoubleAnimation Storyboard.TargetName="Tr" Storyboard.TargetProperty="X" To="20" Duration="0:0:0.2"/><ColorAnimation Storyboard.TargetName="T" Storyboard.TargetProperty="Background.Color" To="#2196F3" Duration="0:0:0.2"/></Storyboard></BeginStoryboard></Trigger.EnterActions><Trigger.ExitActions><BeginStoryboard><Storyboard><DoubleAnimation Storyboard.TargetName="Tr" Storyboard.TargetProperty="X" To="0" Duration="0:0:0.2"/><ColorAnimation Storyboard.TargetName="T" Storyboard.TargetProperty="Background.Color" To="#3E3E3E" Duration="0:0:0.2"/></Storyboard></BeginStoryboard></Trigger.ExitActions></Trigger><Trigger Property="IsEnabled" Value="False"><Setter Property="Opacity" Value="0.5"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Setter.Value></Setter>
        </Style>
        <Style x:Key="Btn" TargetType="Button"><Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button"><Border x:Name="b" Background="{TemplateBinding Background}" CornerRadius="22"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" TextElement.FontWeight="Bold"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="b" Property="Opacity" Value="0.8"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Setter.Value></Setter></Style>
        <Style x:Key="LabeledBtn" TargetType="Button"><Setter Property="Background" Value="#333333"/><Setter Property="BorderThickness" Value="0"/><Setter Property="Cursor" Value="Hand"/><Setter Property="Height" Value="40"/><Setter Property="Margin" Value="0,0,5,0"/><Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button"><Border x:Name="b" Background="{TemplateBinding Background}" CornerRadius="5" Padding="15,0,15,0"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" TextElement.FontWeight="Bold" TextElement.FontSize="14"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="b" Property="Opacity" Value="0.8"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Setter.Value></Setter></Style>
        <Style TargetType="{x:Type ComboBox}"><Setter Property="Template"><Setter.Value><ControlTemplate TargetType="ComboBox"><Grid><ToggleButton Name="ToggleButton" Template="{DynamicResource ComboBoxToggleButton}" Grid.Column="2" Focusable="false" IsChecked="{Binding Path=IsDropDownOpen,Mode=TwoWay,RelativeSource={RelativeSource TemplatedParent}}" ClickMode="Press"/><ContentPresenter Name="ContentSite" IsHitTestVisible="False" Content="{TemplateBinding SelectionBoxItem}" ContentTemplate="{TemplateBinding SelectionBoxItemTemplate}" ContentTemplateSelector="{TemplateBinding ItemTemplateSelector}" Margin="10,3,23,3" VerticalAlignment="Center" HorizontalAlignment="Left" /><TextBox x:Name="PART_EditableTextBox" Style="{x:Null}" Template="{DynamicResource ComboBoxTextBox}" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="3,3,23,3" Focusable="True" Background="Transparent" Visibility="Hidden" IsReadOnly="{TemplateBinding IsReadOnly}"/><Popup Name="Popup" Placement="Bottom" IsOpen="{TemplateBinding IsDropDownOpen}" AllowsTransparency="True" Focusable="False" PopupAnimation="Slide"><Grid Name="DropDown" SnapsToDevicePixels="True" MinWidth="{TemplateBinding ActualWidth}" MaxHeight="{TemplateBinding MaxDropDownHeight}"><Border x:Name="DropDownBorder" Background="#333333" BorderThickness="1" BorderBrush="#2196F3"/><ScrollViewer Margin="4,6,4,6" SnapsToDevicePixels="True"><StackPanel IsItemsHost="True" KeyboardNavigation.DirectionalNavigation="Contained" /></ScrollViewer></Grid></Popup></Grid></ControlTemplate></Setter.Value></Setter></Style>
        <ControlTemplate x:Key="ComboBoxToggleButton" TargetType="ToggleButton"><Border x:Name="Border" Grid.ColumnSpan="2" CornerRadius="5" Background="#333333" BorderBrush="#2196F3" BorderThickness="1"><Path x:Name="Arrow" Grid.Column="1" Fill="#2196F3" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="0,0,8,0" Data="M 0 0 L 4 4 L 8 0 Z"/></Border></ControlTemplate>
    </Window.Resources>
    
    <Grid Margin="25">
        <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="20"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
        
        <Grid Grid.Row="0">
            <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
            <Image x:Name="Logo" Grid.Column="0" Width="80" Height="80"/>
            <StackPanel Grid.Column="1" VerticalAlignment="Center" Margin="20,0,0,0">
                <TextBlock Text="YouTube TV Installer" Foreground="White" FontSize="28" FontWeight="Bold"><TextBlock.Effect><DropShadowEffect Color="#FF0000" BlurRadius="15" Opacity="0.6"/></TextBlock.Effect></TextBlock>
                <StackPanel Orientation="Horizontal" Margin="2,5,0,0"><TextBlock Text="Developed by IT Groceries Shop &#x2665;" Foreground="#FF0000" FontSize="14" FontWeight="Bold"/></StackPanel>
            </StackPanel>
            <ComboBox x:Name="ComboMode" Grid.Column="2" Width="150" Height="40" VerticalAlignment="Top" HorizontalAlignment="Right" Margin="0,10,0,0" Foreground="White" FontSize="16" FontWeight="Bold" Cursor="Hand">
                <ComboBoxItem Content="YouTube TV" IsSelected="True"/>
                <ComboBoxItem Content="YouTube PC"/>
            </ComboBox>
        </Grid>
        
        <Border Grid.Row="2" Background="#1E1E1E" CornerRadius="5"><ScrollViewer VerticalScrollBarVisibility="Hidden"><StackPanel x:Name="List"/></ScrollViewer></Border>

        <Grid Grid.Row="3" Margin="0,15,0,8">
            <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
            <StackPanel Orientation="Horizontal" Grid.Column="0">
                <Button x:Name="BDesk" Style="{StaticResource LabeledBtn}" ToolTip="Toggle Desktop Shortcut" Tag="On" Background="#0078D7">
                    <StackPanel Orientation="Horizontal">
                        <Viewbox Width="20" Height="20" Margin="0,0,8,0"><Path Fill="White" Data="M21 2H3c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h7v2H8v2h8v-2h-2v-2h7c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm0 14H3V4h18v12z"/></Viewbox>
                        <TextBlock Text="Desktop" Foreground="White" VerticalAlignment="Center"/>
                    </StackPanel>
                </Button>
                <Button x:Name="BWin" Style="{StaticResource LabeledBtn}" ToolTip="Toggle Start Menu Shortcut" Tag="Off">
                    <StackPanel Orientation="Horizontal">
                        <Viewbox Width="20" Height="20" Margin="0,0,8,0"><Path Fill="White" Data="M0 0h11.377v11.372H0V0zm12.623 0H24v11.372H12.623V0zM0 12.623h11.377V24H0V12.623zm12.623 0H24V24H12.623V12.623z"/></Viewbox>
                        <TextBlock Text="StartMenu" Foreground="White" VerticalAlignment="Center"/>
                    </StackPanel>
                </Button>
                <Button x:Name="BTrash" Style="{StaticResource LabeledBtn}" ToolTip="Toggle Uninstall Mode" Tag="Off">
                    <StackPanel Orientation="Horizontal">
                        <Viewbox Width="18" Height="18" Margin="0,0,8,0"><Path Fill="White" Data="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/></Viewbox>
                        <TextBlock Text="Uninstall" Foreground="White" VerticalAlignment="Center"/>
                    </StackPanel>
                </Button>
            </StackPanel>
            
            <StackPanel Orientation="Horizontal" Grid.Column="2" HorizontalAlignment="Right">
                <Button x:Name="BA" Content="Start Install" Width="140" Height="40" Background="#2E7D32" Foreground="White" Style="{StaticResource Btn}" Margin="0,0,0,0" Cursor="Hand"/>
            </StackPanel>
        </Grid>

        <Grid Grid.Row="4">
            <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
            <StackPanel Orientation="Horizontal" Grid.Column="0">
                 <Button x:Name="BF" Style="{StaticResource LabeledBtn}" ToolTip="Visit Facebook">
                    <StackPanel Orientation="Horizontal">
                        <TextBlock Text="f" Foreground="#1877F2" FontSize="24" FontWeight="Bold" Margin="0,-4,8,0" VerticalAlignment="Center"/>
                        <TextBlock Text="Facebook" Foreground="White" VerticalAlignment="Center"/>
                    </StackPanel>
                 </Button>
                 <Button x:Name="BG" Style="{StaticResource LabeledBtn}" ToolTip="Visit GitHub">
                    <StackPanel Orientation="Horizontal">
                        <Viewbox Width="20" Height="20" Margin="0,0,8,0"><Path Fill="White" Data="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12"/></Viewbox>
                        <TextBlock Text="GitHub" Foreground="White" VerticalAlignment="Center"/>
                    </StackPanel>
                 </Button>
                 <Button x:Name="BAbt" Style="{StaticResource LabeledBtn}" ToolTip="About Program" Background="#607D8B">
                    <StackPanel Orientation="Horizontal">
                        <Viewbox Width="20" Height="20" Margin="0,0,8,0"><Path Fill="White" Data="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 17h-2v-2h2v2zm2.07-7.75l-.9.92C13.45 12.9 13 13.5 13 15h-2v-.5c0-1.1.45-2.1 1.17-2.83l1.24-1.26c.37-.36.59-.86.59-1.41 0-1.1-9-2-2-2s-2 .9-2 2H8c0-2.21 1.79-4 4-4s4 1.79 4 4c0 .88-.36 1.68-.93 2.25z"/></Viewbox>
                        <TextBlock Text="About" Foreground="White" VerticalAlignment="Center"/>
                    </StackPanel>
                 </Button>
            </StackPanel>
            
            <StackPanel Orientation="Horizontal" Grid.Column="2" HorizontalAlignment="Right">
                <Button x:Name="BC" Content="EXIT" Width="90" Height="40" Background="#D32F2F" Foreground="White" Style="{StaticResource Btn}" Cursor="Hand"/>
            </StackPanel>
        </Grid>
    </Grid>
</Window>
"@

# ---------------------------------------------------------
# [8] EVENTS
# ---------------------------------------------------------
$reader = (New-Object System.Xml.XmlNodeReader $xaml); $Window = [Windows.Markup.XamlReader]::Load($reader)
try { $RightOfConsole_Px = $StartX_Px + $ConsoleW_Px + $Gap; $WPF_Left_DIU = $RightOfConsole_Px / $Scale; $WPF_Top_DIU = $StartY_Px / $Scale; $Window.Left = $WPF_Left_DIU; $Window.Top = $WPF_Top_DIU } catch {}
if (Test-Path $LocalIcon) { $Window.Icon = $LocalIcon; $Window.FindName("Logo").Source = $LocalIcon }

$Stack = $Window.FindName("List"); $BA = $Window.FindName("BA"); $BC = $Window.FindName("BC"); $BF = $Window.FindName("BF"); $BG = $Window.FindName("BG"); $BAbt = $Window.FindName("BAbt")
$BWin = $Window.FindName("BWin"); $BTrash = $Window.FindName("BTrash"); $BDesk = $Window.FindName("BDesk"); $ComboMode = $Window.FindName("ComboMode")

function Load-BrowserList {
    if (!$Silent) { Write-Host " [REFRESH] Re-scanning browsers..." -ForegroundColor Yellow }
    $Stack.Children.Clear()
    foreach ($b in $Global:Browsers) {
        $FP=$null; foreach ($p in $b.P) { if ($p -and (Test-Path $p)) { $FP = $p; break } }
        $IconPath = "$InstallDir\$($b.K).ico"
        $Row = New-Object System.Windows.Controls.Grid; $Row.Height = 45; $Row.Margin = "0,2,0,2"
        $Row.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{Width=[System.Windows.GridLength]::Auto}))
        $Row.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{Width=[System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)}))
        $Row.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{Width=[System.Windows.GridLength]::Auto}))
        $Bor = New-Object System.Windows.Controls.Border; $Bor.CornerRadius = 5; $Bor.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#252526"); $Bor.Padding = "10"; $Bor.Child = $Row; $Bor.Cursor = "Hand"; $Bor.Tag = $b.URL
        $Bor.Margin = "0,0,0,5"; $Bor.BorderThickness = "1"; $Bor.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#333333")
        $Img = New-Object System.Windows.Controls.Image; $Img.Width = 32; $Img.Height = 32; if (Test-Path $IconPath) { $Img.Source = $IconPath }
        [System.Windows.Controls.Grid]::SetColumn($Img,0); $Row.Children.Add($Img)|Out-Null
        $Txt = New-Object System.Windows.Controls.TextBlock; $Txt.Text = $b.N; $Txt.Foreground="White"; $Txt.FontSize=16; $Txt.FontWeight="SemiBold"; $Txt.VerticalAlignment="Center"; $Txt.Margin="15,0,0,0"
        $Chk = New-Object System.Windows.Controls.CheckBox; $Chk.Style=$Window.Resources["BlueSwitch"]; $Chk.VerticalAlignment="Center"; $Chk.Tag = $b.N 
        if ($b.N -match "Brave") { $Txt.Text += " (Recommended)"; $Chk.IsChecked = $true } else { $Chk.IsChecked = $false }
        if ($FP) { $b.Path = $FP; if(!$Silent){ Write-Host " [FOUND]   $($b.N)" -ForegroundColor Green } } else { $Txt.Text += " (Click to Download)"; $Txt.Foreground="#55AAFF"; $Chk.IsEnabled=$false; $Chk.IsChecked=$false; $Bor.Opacity=0.8 }
        [System.Windows.Controls.Grid]::SetColumn($Txt,1); $Row.Children.Add($Txt)|Out-Null
        [System.Windows.Controls.Grid]::SetColumn($Chk,2); $Row.Children.Add($Chk)|Out-Null
        $Stack.Children.Add($Bor)|Out-Null
        $Bor.Add_MouseLeftButtonUp({ param($sender, $e); Play-Sound "Tick"; $cb = $sender.Child.Children[2]; if ($cb.IsEnabled) { $cb.IsChecked = -not $cb.IsChecked } else { if ($sender.Tag) { Start-Process $sender.Tag } } })
    }
    
    # REFRESH CARD (GREEN)
    $RefRow = New-Object System.Windows.Controls.StackPanel; $RefRow.Orientation = "Horizontal"; $RefRow.HorizontalAlignment = "Center"
    $RefBor = New-Object System.Windows.Controls.Border; $RefBor.CornerRadius = 5; $RefBor.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#0F2810"); $RefBor.Padding = "10"; $RefBor.Child = $RefRow; $RefBor.Cursor = "Hand"
    $RefBor.Margin = "0,15,0,5"; $RefBor.BorderThickness = "1"; $RefBor.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#4CAF50")
    $RefPath = New-Object System.Windows.Shapes.Path; $RefPath.Data = [System.Windows.Media.Geometry]::Parse("M17.65 6.35C16.2 4.9 14.21 4 12 4c-4.42 0-7.99 3.58-7.99 8s3.57 8 7.99 8c3.73 0 6.84-2.55 7.73-6h-2.08c-.82 2.33-3.04 4-5.65 4-3.31 0-6-2.69-6-6s2.69-6 6-6c1.66 0 3.14.69 4.22 1.78L13 11h7V4l-2.35 2.35z"); $RefPath.Fill = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#4CAF50")
    $RefView = New-Object System.Windows.Controls.Viewbox; $RefView.Width=20; $RefView.Height=20; $RefView.Child = $RefPath; $RefView.Margin="0,0,10,0"
    $RefTxt = New-Object System.Windows.Controls.TextBlock; $RefTxt.Text = "Installed a new browser? Click Refresh"; $RefTxt.Foreground="#4CAF50"; $RefTxt.FontSize=15; $RefTxt.FontWeight="Bold"; $RefTxt.VerticalAlignment="Center"
    $RefRow.Children.Add($RefView)|Out-Null; $RefRow.Children.Add($RefTxt)|Out-Null; $Stack.Children.Add($RefBor)|Out-Null
    $RefBor.Add_MouseLeftButtonUp({ Play-Sound "Click"; Load-BrowserList })
}

Load-BrowserList
$BF.Add_Click({ Start-Process "https://www.facebook.com/Adm1n1straTOE"; Play-Sound "Click" })
$BG.Add_Click({ Start-Process "https://github.com/itgroceries-sudo/Youtube-On-TV/tree/main"; Play-Sound "Click" }) 
$BAbt.Add_Click({ Play-Sound "Click"; [System.Windows.MessageBox]::Show("YouTube TV Installer`nVersion: $AppVersion`n`nDeveloped by IT Groceries Shop", "About", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) | Out-Null })

$BDesk.Add_Click({ if ($BDesk.Tag -eq "Off") { $BDesk.Tag = "On"; $BDesk.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#0078D7"); Play-Sound "Click" } else { $BDesk.Tag = "Off"; $BDesk.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#333333"); Play-Sound "Click" } })
$BWin.Add_Click({ if ($BWin.Tag -eq "Off") { $BWin.Tag = "On"; $BWin.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#0078D7"); Play-Sound "Click" } else { $BWin.Tag = "Off"; $BWin.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#333333"); Play-Sound "Click" } })
$BTrash.Add_Click({ if ($BTrash.Tag -eq "Off") { $BTrash.Tag = "On"; $BTrash.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#D32F2F"); $BA.Content = "Uninstall Selected"; $BA.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#D32F2F"); Play-Sound "Warn" } else { $BTrash.Tag = "Off"; $BTrash.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#333333"); $BA.Content = "Start Install"; $BA.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#2E7D32"); Play-Sound "Click" } })
$BC.Add_Click({ Play-Sound "Click"; if(!$Silent){ Write-Host "`n [EXIT] Clean & Bye !!" -ForegroundColor Cyan }; [System.Windows.Forms.Application]::DoEvents(); Start-Sleep 1; if ($PSCommandPath -eq $TempScript) { Start-Process "cmd.exe" -ArgumentList "/c timeout /t 2 >nul & del `"$TempScript`"" -WindowStyle Hidden }; $Window.Close(); [Environment]::Exit(0) })

$BA.Add_Click({ 
    Play-Sound "Click"; $Sel = $Stack.Children | Where-Object { $_.Child.Children[2].IsChecked }; if ($Sel.Count -eq 0) { return }
    $BA.IsEnabled = $false; $BA.Content = "Processing..."; 
    $IsUninstall = ($BTrash.Tag -eq "On"); $UseStartMenu = ($BWin.Tag -eq "On"); $UseDesktop = ($BDesk.Tag -eq "On")
    
    # Check PC Mode
    $IsPCMode = ($ComboMode.Text -eq "YouTube PC")
    
    foreach ($i in $Sel) { Install-Browser $i.Child.Children[2].Tag $IsUninstall $UseStartMenu $UseDesktop $IsPCMode }
    $BA.Content = "Finished"; Play-Sound "Done"; Start-Sleep 2; $BA.IsEnabled = $true; if ($IsUninstall) { $BA.Content = "Uninstall Selected" } else { $BA.Content = "Start Install" } 
})
$Window.ShowDialog() | Out-Null
