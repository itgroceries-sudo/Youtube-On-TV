<# : hybrid batch + powershell script
@powershell -noprofile -Window Hidden -c "$param='%*';$ScriptPath='%~f0';iex((Get-Content('%~f0') -Raw))"&exit/b
#>

# =========================================================
#  YOUTUBE TV INSTALLER v75.5.4 (REFINED VECTOR UI)
#  File: 7554.ps1 | Branch: branch
#  Status: Vector Refresh/About @ Bottom Left | Stable Core
# =========================================================

# --- [1. WIN32 GHOSTING] ---
$User32Def = @'
[DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
'@
if (-not ([PowerShell].Assembly.GetType('Win32.Win32Ghost'))) {
    Add-Type -MemberDefinition $User32Def -Name "Win32Ghost" -Namespace Win32 -ErrorAction SilentlyContinue
}
[Win32.Win32Ghost]::ShowWindow([Win32.Win32Ghost]::GetConsoleWindow(), 0) | Out-Null

# --- [2. SETUP & ARGS] ---
$InstallDir = "$env:LOCALAPPDATA\ITG_YToTV"
$TempScript = "$env:TEMP\7554.ps1"
# [FIX] Pointing to 'branch' and '7554.ps1'
$GitHubRaw = "https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/branch"
$SelfURL = "$GitHubRaw/7554.ps1"
$AppVersion = "2.0 Build 23.75.5.4"
$BuildDate  = "03-02-2026"

$IsLocal = ($PSScriptRoot -or $ScriptPath)
$TargetFile = if ($ScriptPath) { $ScriptPath } elseif ($PSScriptRoot) { $PSCommandPath } else { $null }

$AllArgs = @(); if ($args) { $AllArgs += $args }; if ($param) { $AllArgs += $param.Split(" ") }
$Silent = $AllArgs -contains "-Silent"
$Browser = "Ask"
for ($i = 0; $i -lt $AllArgs.Count; $i++) {
    if ($AllArgs[$i] -eq "-Browser" -and ($i + 1 -lt $AllArgs.Count)) { $Browser = $AllArgs[$i+1] }
}

# --- [3. ADMIN CHECK] ---
$Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = [Security.Principal.WindowsPrincipal]$Identity

if (-not $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $PassArgs = @(); if ($Silent) { $PassArgs += "-Silent" }
    if ($Browser -ne "Ask") { $PassArgs += "-Browser"; $PassArgs += $Browser }

    if (!$IsLocal) {
        try { (New-Object System.Net.WebClient).DownloadFile($SelfURL, $TempScript) } catch { exit }
        Start-Process PowerShell -ArgumentList (@("-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-File", "`"$TempScript`"") + $PassArgs) -Verb RunAs
    } 
    elseif ($TargetFile -match "\.cmd$" -or $TargetFile -match "\.bat$") {
        Start-Process "cmd.exe" -ArgumentList "/c `"`"$TargetFile`"`"" -WindowStyle Hidden -Verb RunAs
    } 
    else {
        Start-Process PowerShell -ArgumentList (@("-NoProfile", "-ExecutionPolicy", "Bypass", "-WindowStyle", "Hidden", "-File", "`"$TargetFile`"") + $PassArgs) -Verb RunAs
    }
    exit 
}

# --- [4. CORE LOGIC] ---
Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, System.Drawing

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

function Install-BrowserLogic($NameKey) {
    $Obj = $Global:Browsers | Where-Object { $_.N -match $NameKey -or $_.K -match $NameKey }
    if (!$Obj) { return $false }
    
    $FP = $null; foreach($p in $Obj.P){ if(Test-Path $p){ $FP=$p; break } }
    if($FP){
        $ShortcutName = "YouTube On TV - $($Obj.N).lnk"
        $Sut = Join-Path ([Environment]::GetFolderPath("Desktop")) $ShortcutName
        $Ws = New-Object -Com WScript.Shell
        $s = $Ws.CreateShortcut($Sut)
        $s.TargetPath = "cmd.exe"
        $s.Arguments = "/c taskkill /f /im $($Obj.E) /t >nul 2>&1 & start `"`" `"$FP`" --profile-directory=Default --app=https://youtube.com/tv --user-agent=`"Mozilla/5.0 (SMART-TV; LINUX; Tizen 9.0) AppleWebKit/537.36 (KHTML, like Gecko) 120.0.6099.5/9.0 TV Safari/537.36`" --start-fullscreen --disable-features=CalculateNativeWinOcclusion --disable-renderer-backgrounding --disable-background-timer-throttling"
        $s.WindowStyle = 3
        if(Test-Path "$InstallDir\MenuIcon.ico"){ $s.IconLocation = "$InstallDir\MenuIcon.ico" }
        $s.Save()
        return $true
    }
    return $false
}

# --- [5. SILENT EXECUTION] ---
if ($Silent) {
    if (-not (Test-Path $InstallDir)) { New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null }
    try { (New-Object System.Net.WebClient).DownloadFile("$GitHubRaw/YouTube.ico", "$InstallDir\MenuIcon.ico") } catch {}
    
    $Target = if ($Browser -eq "Ask") { "Brave" } else { $Browser }
    Install-BrowserLogic $Target | Out-Null
    
    if ($PSCommandPath -eq $TempScript) { Start-Process "cmd.exe" -ArgumentList "/c timeout /t 1 >nul & del `"$TempScript`"" -WindowStyle Hidden }
    exit
}

# --- [6. GUI MODE] ---
if (-not (Test-Path $InstallDir)) { New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null }

# Logging Helper
function Write-Log($msg, $color="Gray") {
    if ($Global:LogBox) {
        $Global:LogBox.Text += "`n$msg"
        $Global:LogScroll.ScrollToEnd()
        [System.Windows.Forms.Application]::DoEvents()
    }
}

function DL ($U, $N) { 
    $D="$InstallDir\$N"
    if(!(Test-Path $D) -or (Get-Item $D).Length -lt 100){ 
        try{ (New-Object Net.WebClient).DownloadFile($U,$D); Write-Log "[DOWNLOAD] OK: $N" "Green" }catch{} 
    } else { Write-Log "[CACHE]    OK: $N" "Gray" }
    return $D
}

# XAML
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
Title="YouTube TV Installer" Height="860" Width="520" WindowStartupLocation="CenterScreen" ResizeMode="NoResize" Background="#181818" Topmost="True" WindowStyle="None" BorderBrush="#2196F3" BorderThickness="2">
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
        
        <Style x:Key="VectorBtn" TargetType="Button">
            <Setter Property="Background" Value="#333333"/>
            <Setter Property="BorderThickness" Value="0"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Width" Value="45"/>
            <Setter Property="Height" Value="45"/>
            <Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button">
                <Border x:Name="b" Background="{TemplateBinding Background}" CornerRadius="22">
                    <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                </Border>
                <ControlTemplate.Triggers>
                    <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="b" Property="Opacity" Value="0.8"/></Trigger>
                </ControlTemplate.Triggers>
            </ControlTemplate></Setter.Value></Setter>
        </Style>
    </Window.Resources>
    <Grid Margin="25">
        <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="20"/><RowDefinition Height="*"/><RowDefinition Height="120"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
        
        <Grid Grid.Row="0"><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
            <Image x:Name="Logo" Grid.Column="0" Width="80" Height="80"/>
            <StackPanel Grid.Column="1" VerticalAlignment="Center" Margin="20,0,0,0">
                <TextBlock Text="YouTube TV Installer" Foreground="White" FontSize="28" FontWeight="Bold"><TextBlock.Effect><DropShadowEffect Color="#FF0000" BlurRadius="15" Opacity="0.6"/></TextBlock.Effect></TextBlock>
                <StackPanel Orientation="Horizontal" Margin="2,5,0,0"><TextBlock Text="Developed by IT Groceries Shop &#x2665;" Foreground="#FF0000" FontSize="14" FontWeight="Bold"/></StackPanel>
            </StackPanel>
        </Grid>
        
        <Border Grid.Row="2" Background="#1E1E1E"><ScrollViewer VerticalScrollBarVisibility="Hidden"><StackPanel x:Name="List"/></ScrollViewer></Border>
        
        <Border Grid.Row="3" Background="Black" Margin="0,10,0,0" CornerRadius="5" BorderBrush="#333333" BorderThickness="1">
            <ScrollViewer x:Name="LogScroll" VerticalScrollBarVisibility="Auto">
                <TextBlock x:Name="LogBox" Foreground="#00FF00" FontFamily="Consolas" FontSize="12" Margin="10" TextWrapping="Wrap" Text="[INIT] System Ready..."/>
            </ScrollViewer>
        </Border>

        <Grid Grid.Row="4" Margin="0,20,0,0"><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
            
            <StackPanel Orientation="Horizontal" Grid.Column="0">
                 <Button x:Name="BF" Width="45" Height="45" Background="#1877F2" Style="{StaticResource Btn}" Margin="0,0,10,0" ToolTip="Facebook" Cursor="Hand"><TextBlock Text="f" Foreground="White" FontSize="26" FontWeight="Bold" Margin="0,-4,0,0"/></Button>
                 <Button x:Name="BG" Width="45" Height="45" Background="#333333" Style="{StaticResource Btn}" Margin="0,0,10,0" ToolTip="GitHub" Cursor="Hand"><Viewbox Width="24" Height="24"><Path Fill="White" Data="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12"/></Viewbox></Button>
                 <Button x:Name="BRefresh" Style="{StaticResource VectorBtn}" Margin="0,0,10,0" ToolTip="Re-Scan Browsers">
                    <Viewbox Width="24" Height="24"><Path Fill="White" Data="M17.65 6.35C16.2 4.9 14.21 4 12 4c-4.42 0-7.99 3.58-7.99 8s3.57 8 7.99 8c3.73 0 6.84-2.55 7.73-6h-2.08c-.82 2.33-3.04 4-5.65 4-3.31 0-6-2.69-6-6s2.69-6 6-6c1.66 0 3.14.69 4.22 1.78L13 11h7V4l-2.35 2.35z"/></Viewbox>
                 </Button>
                 <Button x:Name="BAbt" Style="{StaticResource VectorBtn}" ToolTip="About">
                    <Viewbox Width="24" Height="24"><Path Fill="White" Data="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 17h-2v-2h2v2zm2.07-7.75l-.9.92C13.45 12.9 13 13.5 13 15h-2v-.5c0-1.1.45-2.1 1.17-2.83l1.24-1.26c.37-.36.59-.86.59-1.41 0-1.1-9-2-2-2s-2 .9-2 2H8c0-2.21 1.79-4 4-4s4 1.79 4 4c0 .88-.36 1.68-.93 2.25z"/></Viewbox>
                 </Button>
            </StackPanel>
            
            <StackPanel Orientation="Horizontal" Grid.Column="2" HorizontalAlignment="Right">
                <Button x:Name="BC" Content="EXIT" Width="90" Height="45" Background="#D32F2F" Foreground="White" Style="{StaticResource Btn}" Margin="0,0,10,0" Cursor="Hand"/>
                <Button x:Name="BA" Content="Start Install" Width="160" Height="45" Background="#2E7D32" Foreground="White" Style="{StaticResource Btn}" Cursor="Hand"/>
            </StackPanel>
        </Grid>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml); $Window = [Windows.Markup.XamlReader]::Load($reader)
$Window.Add_MouseLeftButtonDown({ $this.DragMove() })

$Stack = $Window.FindName("List"); $BA = $Window.FindName("BA"); $BC = $Window.FindName("BC"); $BF = $Window.FindName("BF"); $BG = $Window.FindName("BG"); $BAbt = $Window.FindName("BAbt")
$BRefresh = $Window.FindName("BRefresh")
$Global:LogBox = $Window.FindName("LogBox"); $Global:LogScroll = $Window.FindName("LogScroll")

foreach($k in $Assets.Keys){ DL $Assets[$k] "$k.ico" | Out-Null }
if (Test-Path "$InstallDir\MenuIcon.ico") { $Window.FindName("Logo").Source = "$InstallDir\MenuIcon.ico" }

Write-Log "------------------------------------------"
Write-Log "   (V.2 Build 23.75.5.4 : $BuildDate)"
Write-Log "------------------------------------------"

# --- Function to Re-scan and Re-draw List ---
function Load-BrowserList {
    if (!$Silent) { Write-Log "[REFRESH] Re-scanning browsers..." "Yellow" }
    $Stack.Children.Clear()
    
    foreach ($b in $Global:Browsers) {
        $FP=$null; foreach ($p in $b.P) { if ($p -and (Test-Path $p)) { $FP = $p; break } }
        $IconPath = "$InstallDir\$($b.K).ico"
        
        $Row = New-Object System.Windows.Controls.Grid; $Row.Height = 45; $Row.Margin = "0,5,0,5"
        $Row.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{Width=[System.Windows.GridLength]::Auto}))
        $Row.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{Width=[System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)}))
        $Row.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -Property @{Width=[System.Windows.GridLength]::Auto}))
        
        $Bor = New-Object System.Windows.Controls.Border; $Bor.CornerRadius = 8; $Bor.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#252526"); $Bor.Padding = "10"; $Bor.Child = $Row; $Bor.Cursor = "Hand"; $Bor.Tag = $b.N
        
        $Img = New-Object System.Windows.Controls.Image; $Img.Width = 32; $Img.Height = 32; 
        if (Test-Path $IconPath) { $Img.Source = $IconPath }
        [System.Windows.Controls.Grid]::SetColumn($Img,0); $Row.Children.Add($Img)|Out-Null
        
        $Txt = New-Object System.Windows.Controls.TextBlock; $Txt.Text = $b.N; $Txt.Foreground="White"; $Txt.FontSize=16; $Txt.FontWeight="SemiBold"; $Txt.VerticalAlignment="Center"; $Txt.Margin="15,0,0,0"; 
        $Chk = New-Object System.Windows.Controls.CheckBox; $Chk.Style=$Window.Resources["BlueSwitch"]; $Chk.VerticalAlignment="Center"; $Chk.Tag = $b.N 
        
        if ($b.N -match "Brave") { $Txt.Text += " (Recommended)"; $Chk.IsChecked = $true } else { $Chk.IsChecked = $false }
        
        if ($FP) { 
            Write-Log "[FOUND]   $($b.N)" "Green"
        } else {
            $Txt.Text += " (Click to Download)"; $Txt.Foreground="#55AAFF"; $Chk.IsEnabled=$false; $Chk.IsChecked=$false; $Bor.Opacity=0.8
            $Bor.Tag = $b.URL
        }
        
        [System.Windows.Controls.Grid]::SetColumn($Txt,1); $Row.Children.Add($Txt)|Out-Null
        [System.Windows.Controls.Grid]::SetColumn($Chk,2); $Row.Children.Add($Chk)|Out-Null
        $Stack.Children.Add($Bor)|Out-Null

        $Bor.Add_MouseLeftButtonUp({
            param($sender, $e)
            $cb = $sender.Child.Children[2]
            if ($cb.IsEnabled) { $cb.IsChecked = -not $cb.IsChecked } 
            else { if ($sender.Tag -match "http") { Start-Process $sender.Tag } }
        })
    }
}

# Initial Load
Load-BrowserList

$BRefresh.Add_Click({ 
    Load-BrowserList 
    [System.Console]::Beep(1500, 100) 
})

$BF.Add_Click({ Start-Process "https://www.facebook.com/Adm1n1straTOE" }); $BG.Add_Click({ Start-Process "https://github.com/itgroceries-sudo/Youtube-On-TV/tree/main" }); 
$BC.Add_Click({ 
    Write-Log "[EXIT] Clean & Bye !!" "Cyan"
    [System.Windows.Forms.Application]::DoEvents(); Start-Sleep 2 
    if ($PSCommandPath -eq $TempScript) { Start-Process "cmd.exe" -ArgumentList "/c timeout /t 2 >nul & del `"$TempScript`"" -WindowStyle Hidden }
    $Window.Close() 
})
$BA.Add_Click({
    $Sel = $Stack.Children | Where-Object { $_.Child.Children[2].IsChecked }; if ($Sel.Count -eq 0) { return }
    $BA.IsEnabled = $false; $BA.Content = "Processing..."
    
    foreach ($i in $Sel) { 
        $TargetName = $i.Child.Children[2].Tag
        if (Install-BrowserLogic $TargetName) {
            Write-Log "[INSTALL] $TargetName... DONE" "Green"
        } else {
            Write-Log "[ERROR] $TargetName Not Found!" "Red"
        }
    }
    
    $BA.Content = "Finished"; [System.Console]::Beep(1000, 200); Start-Sleep 2; $BA.IsEnabled = $true; $BA.Content = "Start Install"
})
$BAbt.Add_Click({ [System.Windows.MessageBox]::Show("YouTube TV Installer`nVersion: $AppVersion`n`nDeveloped by IT Groceries Shop", "About", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information) | Out-Null })

$Window.ShowDialog() | Out-Null
