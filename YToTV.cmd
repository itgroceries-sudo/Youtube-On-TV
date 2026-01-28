<# : batch portion
@powershell -noprofile -Window Hidden -c "$param='%*';$ScriptPath='%~f0';iex((Get-Content('%~f0') -Raw))"&exit/b
#>

# =========================================================
#  YOUTUBE TV INSTALLER (CORE)
#  Architecture: Hybrid Polyglot (VMD Style)
# =========================================================

# 1. PARSE PARAMETERS (From Batch Wrapper)
$Silent = $param -match "-Silent"
if ($param -match "-Browser\s+(\w+)") { $Browser = $matches[1] } else { $Browser = "Ask" }

# 2. CHECK ADMIN (Force Elevation if run directly)
$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $IsAdmin) {
    Start-Process -FilePath $ScriptPath -ArgumentList $param -Verb RunAs
    exit
}

# 3. ENVIRONMENT SETUP
$TempDir = "$env:TEMP\YT_Installer_Assets"
if (-not (Test-Path $TempDir)) { New-Item -ItemType Directory -Force -Path $TempDir | Out-Null }

Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, System.Drawing

# Win32 API (Window Control)
$Win32 = Add-Type -MemberDefinition '
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")] public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);
    [DllImport("user32.dll")] public static extern IntPtr LoadImage(IntPtr hinst, string lpszName, uint uType, int cxDesired, int cyDesired, uint fuLoad);
    [DllImport("user32.dll")] public static extern int SendMessage(IntPtr hWnd, int msg, int wParam, IntPtr lParam);
' -Name "Win32Utils" -Namespace Win32 -PassThru

# Console Logic
$ConsoleHandle = $Win32::GetConsoleWindow()
if ($Silent) {
    $Win32::ShowWindow($ConsoleHandle, 0) | Out-Null # Hide Console
} else {
    $Win32::ShowWindow($ConsoleHandle, 5) | Out-Null # Show Console
    $host.UI.RawUI.WindowTitle = "Installer Log Console"
    $host.UI.RawUI.BackgroundColor = "Black"
    $host.UI.RawUI.ForegroundColor = "Green"
    Clear-Host
}

# 4. ASSETS
$BaseUrl = "https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/IconFiles"
$Assets = @{
    "MenuIcon" = "$BaseUrl/YouTube.ico"; "ConsoleIcon" = "https://itgroceries.blogspot.com/favicon.ico"
    "Chrome"="$BaseUrl/Chrome.ico"; "Edge"="$BaseUrl/Edge.ico"; "Brave"="$BaseUrl/Brave.ico"
    "Vivaldi"="$BaseUrl/Vivaldi.ico"; "Yandex"="$BaseUrl/Yandex.ico"; "Chromium"="$BaseUrl/Chromium.ico"; "Thorium"="$BaseUrl/Thorium.ico"
}

function DL ($U, $N) { 
    $D="$TempDir\$N"; if(!(Test-Path $D)){ try{(New-Object Net.WebClient).DownloadFile($U,$D); if(!$Silent){Write-Host " [OK] $N" -Fg DarkGray}}catch{} } 
}

if(!$Silent){Write-Host "Checking Assets..." -Fg Yellow}
foreach($k in $Assets.Keys){ DL $Assets[$k] "$k.ico" }
$LocalIcon = "$TempDir\MenuIcon.ico"; $ConsoleIcon = "$TempDir\ConsoleIcon.ico"

# 5. BROWSER & INSTALL LOGIC
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
    if(Test-Path $LocalIcon){$s.IconLocation=$LocalIcon}
    $s.Save()
    if(!$Silent){Write-Host " [INSTALLED] $($Obj.N)" -Fg Green}
}

# --- CLI MODE ---
if ($Browser -ne "Ask") {
    if(!$Silent){Write-Host "[CLI MODE] Target: $Browser" -Fg Cyan}
    foreach($b in $Browsers){
        if($b.N -match $Browser -or $b.K -match $Browser){
            $FP=$null; foreach($p in $b.P){if(Test-Path $p){$FP=$p;break}}
            if($FP){ $b.Path=$FP; Install $b }
        }
    }
    exit
}

# 6. GUI MODE (Manual Build)
if(Test-Path $ConsoleIcon){ $h=$Win32::LoadImage(0,$ConsoleIcon,1,0,0,16); if($h){$Win32::SendMessage($ConsoleHandle,0x80,0,$h);$Win32::SendMessage($ConsoleHandle,0x80,1,$h)} }

try {
    $Scr=[Windows.Forms.Screen]::PrimaryScreen.Bounds; $W=500; $H=820; $Gap=10
    $X=if($Scr.Width){($Scr.Width-($W*2)-$Gap)/2}else{100}; $Y=if($Scr.Height){($Scr.Height-$H)/2}else{100}
    $Win32::MoveWindow($ConsoleHandle, [int]$X, [int]$Y, [int]$W, [int]$H, $true) | Out-Null
} catch {}

if(!$Silent){Write-Host "`n    YOUTUBE TV INSTALLER v36.0 (FINAL)" -Fg Cyan; Write-Host "[INIT] Ready..."}

# Prepare List
$List=@(); foreach($b in $Browsers){
    $FP=$null; foreach($p in $b.P){if(Test-Path $p){$FP=$p;break}}
    $Uri=New-Object Uri("$TempDir\$($b.K).ico"); $Bmp=New-Object System.Windows.Media.Imaging.BitmapImage; $Bmp.BeginInit(); $Bmp.UriSource=$Uri; $Bmp.CacheOption="OnLoad"; $Bmp.EndInit(); $Bmp.Freeze()
    if($FP){$List+=@{N=$b.N;Path=$FP;Exe=$b.E;Inst=$true;Img=$Bmp}} else {$List+=@{N=$b.N;Path=$null;Exe=$b.E;Inst=$false;Img=$Bmp}}
}

# XAML
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="YT Installer" Height="$H" Width="$W" WindowStartupLocation="Manual" ResizeMode="NoResize" Background="#181818" Topmost="True">
    <Window.Resources>
        <Style x:Key="Sw" TargetType="{x:Type CheckBox}"><Setter Property="Template"><Setter.Value><ControlTemplate TargetType="{x:Type CheckBox}">
            <Border x:Name="T" Width="44" Height="24" Background="#3E3E3E" CornerRadius="12" Cursor="Hand"><Border x:Name="D" Width="20" Height="20" Background="White" CornerRadius="10" HorizontalAlignment="Left" Margin="2,0,0,0"><Border.RenderTransform><TranslateTransform x:Name="Tr" X="0"/></Border.RenderTransform></Border></Border>
            <ControlTemplate.Triggers><Trigger Property="IsChecked" Value="True"><Trigger.EnterActions><BeginStoryboard><Storyboard><DoubleAnimation Storyboard.TargetName="Tr" Storyboard.TargetProperty="X" To="20" Duration="0:0:0.2"/><ColorAnimation Storyboard.TargetName="T" Storyboard.TargetProperty="Background.Color" To="#2196F3" Duration="0:0:0.2"/></Storyboard></BeginStoryboard></Trigger.EnterActions><Trigger.ExitActions><BeginStoryboard><Storyboard><DoubleAnimation Storyboard.TargetName="Tr" Storyboard.TargetProperty="X" To="0" Duration="0:0:0.2"/><ColorAnimation Storyboard.TargetName="T" Storyboard.TargetProperty="Background.Color" To="#3E3E3E" Duration="0:0:0.2"/></Storyboard></BeginStoryboard></Trigger.ExitActions></Trigger><Trigger Property="IsEnabled" Value="False"><Setter Property="Opacity" Value="0.5"/></Trigger></ControlTemplate.Triggers>
        </ControlTemplate></Setter.Value></Setter></Style>
        <Style x:Key="Bn" TargetType="Button"><Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button"><Border x:Name="b" Background="{TemplateBinding Background}" CornerRadius="22"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" TextElement.FontWeight="Bold"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="b" Property="Opacity" Value="0.8"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Setter.Value></Setter></Style>
    </Window.Resources>
    <Grid Margin="25"><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="20"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
        <Grid Grid.Row="0"><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
            <Image x:Name="Logo" Grid.Column="0" Width="80" Height="80"/>
            <StackPanel Grid.Column="1" VerticalAlignment="Center" Margin="20,0,0,0"><TextBlock Text="YouTube TV Installer" Foreground="White" FontSize="28" FontWeight="Bold"><TextBlock.Effect><DropShadowEffect Color="#FF0000" BlurRadius="15" Opacity="0.6"/></TextBlock.Effect></TextBlock><StackPanel Orientation="Horizontal" Margin="2,5,0,0"><TextBlock Text="Developed by IT Groceries Shop &#x2665;" Foreground="#FF0000" FontSize="14" FontWeight="Bold"/></StackPanel></StackPanel></Grid>
        <Border Grid.Row="2" Background="#1E1E1E"><ScrollViewer VerticalScrollBarVisibility="Hidden"><StackPanel x:Name="List"/></ScrollViewer></Border>
        <Grid Grid.Row="3" Margin="0,20,0,0"><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
            <StackPanel Orientation="Horizontal" Grid.Column="0"><Button x:Name="BF" Width="45" Height="45" Background="#1877F2" Style="{StaticResource Bn}" Margin="0,0,10,0" ToolTip="Facebook" Cursor="Hand"><TextBlock Text="f" Foreground="White" FontSize="26" FontWeight="Bold" Margin="0,-4,0,0"/></Button><Button x:Name="BG" Width="45" Height="45" Background="#333333" Style="{StaticResource Bn}" ToolTip="GitHub" Cursor="Hand"><TextBlock Text="G" Foreground="White" FontSize="20" FontWeight="Bold"/></Button></StackPanel>
            <StackPanel Orientation="Horizontal" Grid.Column="2"><Button x:Name="BC" Content="EXIT" Width="90" Height="45" Background="#D32F2F" Foreground="White" Style="{StaticResource Bn}" Margin="0,0,10,0" Cursor="Hand"/><Button x:Name="BA" Content="Start Install" Width="160" Height="45" Background="#2E7D32" Foreground="White" Style="{StaticResource Bn}" Cursor="Hand"/></StackPanel></Grid></Grid></Window>
"@

$r=(New-Object System.Xml.XmlNodeReader $xaml); $Win=[Windows.Markup.XamlReader]::Load($r)
try{$Win.Left=[int]$X+[int]$W+[int]$Gap; $Win.Top=[int]$Y}catch{}
if(Test-Path $LocalIcon){$O=Create-ImageObject $LocalIcon; $Win.Icon=$O; $Win.FindName("Logo").Source=$O}

$Lst=$Win.FindName("List"); $BA=$Win.FindName("BA"); $BC=$Win.FindName("BC"); $BF=$Win.FindName("BF"); $BG=$Win.FindName("BG")

foreach($b in $List){
    $Row=New-Object System.Windows.Controls.Grid; $Row.Height=45; $Row.Margin="0,5,0,5"
    $Row.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -P @{Width=[System.Windows.GridLength]::Auto})); $Row.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -P @{Width=[System.Windows.GridLength]::new(1,[System.Windows.GridUnitType]::Star)})); $Row.ColumnDefinitions.Add((New-Object System.Windows.Controls.ColumnDefinition -P @{Width=[System.Windows.GridLength]::Auto}))
    $Bor=New-Object System.Windows.Controls.Border; $Bor.CornerRadius=8; $Bor.Background=[System.Windows.Media.BrushConverter]::new().ConvertFromString("#252526"); $Bor.Padding=10; $Bor.Child=$Row; $Bor.Cursor="Hand"
    
    $Img=New-Object System.Windows.Controls.Image; $Img.Width=32; $Img.Height=32; if($b.Img){$Img.Source=$b.Img}; [System.Windows.Controls.Grid]::SetColumn($Img,0); $Row.Children.Add($Img)|Out-Null
    $Txt=New-Object System.Windows.Controls.TextBlock; $Txt.Text=$b.N; $Txt.Foreground="White"; $Txt.FontSize=16; $Txt.FontWeight="SemiBold"; $Txt.VerticalAlignment="Center"; $Txt.Margin="15,0,0,0"; if(!$b.Inst){$Txt.Text+=" (Not Installed)";$Txt.Foreground="#666666"}; [System.Windows.Controls.Grid]::SetColumn($Txt,1); $Row.Children.Add($Txt)|Out-Null
    $Chk=New-Object System.Windows.Controls.CheckBox; $Chk.Style=$Win.Resources["Sw"]; $Chk.VerticalAlignment="Center"; $Chk.Tag=$b; if($b.Inst){$Chk.IsChecked=$true}else{$Chk.IsEnabled=$false;$Chk.IsChecked=$false;$Bor.Opacity=0.5}; [System.Windows.Controls.Grid]::SetColumn($Chk,2); $Row.Children.Add($Chk)|Out-Null
    
    $Lst.Children.Add($Bor)|Out-Null
    if($b.Inst){$Bor.Add_MouseLeftButtonUp({param($s,$e)$Chk.IsChecked = -not $Chk.IsChecked})}
}

$BF.Add_Click({Start-Process "https://www.facebook.com/Adm1n1straTOE"}); $BG.Add_Click({Start-Process "https://github.com/itgroceries-sudo/Youtube-On-TV/tree/main"}); $BC.Add_Click({$Win.Close()})
$BA.Add_Click({
    $Sel=$Lst.Children|Where-Object{$_.Child.Children[2].IsChecked}; if($Sel.Count -eq 0){return}
    $BA.IsEnabled=$false; $BA.Content="Processing..."; foreach($i in $Sel){Install $i.Child.Children[2].Tag}
    $BA.Content="Finished"; [Console]::Beep(1000,200); Start-Sleep 2; $BA.IsEnabled=$true; $BA.Content="Start Install"
})
$Win.ShowDialog()|Out-Null; Remove-Item -Recurse -Force $TempDir -ErrorAction SilentlyContinue
