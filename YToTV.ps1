<# : hybrid batch + powershell script
@powershell -noprofile -Window Hidden -c "$param='%*';$ScriptPath='%~f0';iex((Get-Content('%~f0') -Raw))"&exit/b
#>

# =========================================================
#  YOUTUBE TV INSTALLER v52.0 (VMD CLONE)
#  Architecture: Single File .ps1 (Polyglot Hybrid)
# =========================================================

$ErrorActionPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# --- [CONFIG] ---
# ลิ้งค์นี้ต้องตรงกับไฟล์ที่คุณอัปโหลดบน GitHub เป๊ะๆ
$GitHubRaw = "https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main"
$SelfURL   = "$GitHubRaw/YToTV.ps1" 

# Parse Parameters
if ($param -match "-Silent") { $Silent = $true }
if ($param -match "-Browser\s+(\w+)") { $Browser = $matches[1] } else { $Browser = "Ask" }

# --- [1. SELF-DOWNLOAD (WEB IEX MODE)] ---
# เช็คว่ารันจากไฟล์จริงหรือไม่? (ถ้ารันผ่าน IEX ค่า $PSScriptRoot จะว่างเปล่า)
if (-not $PSScriptRoot) {
    if (!$Silent) { Write-Host "[INIT] Web Mode Detected. Downloading..." -ForegroundColor Cyan }
    $TempScript = "$env:TEMP\YToTV.ps1"
    
    try {
        (New-Object System.Net.WebClient).DownloadFile($SelfURL, $TempScript)
    } catch {
        Write-Host "[ERROR] Download Failed. Check URL: $SelfURL" -ForegroundColor Red
        Start-Sleep 3; exit
    }

    # สร้าง Argument สำหรับส่งต่อ
    $ArgsList = "-NoProfile -ExecutionPolicy Bypass -File `"$TempScript`""
    if ($Silent) { $ArgsList += " -Silent" }
    if ($Browser -ne "Ask") { $ArgsList += " -Browser $Browser" }

    # สั่งรันไฟล์ที่โหลดมา (แบบ Admin) แล้วปิดตัวนี้ทิ้งทันที
    Start-Process PowerShell -ArgumentList $ArgsList -Verb RunAs
    exit
}

# --- [2. ADMIN CHECK (FILE MODE)] ---
$Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = [Security.Principal.WindowsPrincipal]$Identity
if (-not $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # ถ้าไม่ใช่ Admin ให้เรียกตัวเองใหม่
    $ArgsList = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    if ($Silent) { $ArgsList += " -Silent" }
    if ($Browser -ne "Ask") { $ArgsList += " -Browser $Browser" }
    
    Start-Process PowerShell -ArgumentList $ArgsList -Verb RunAs
    exit
}

# =========================================================
#  MAIN PROGRAM (ADMIN GRANTED)
# =========================================================

# --- [3. WIN32 API & SETUP] ---
Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, System.Drawing

$Win32 = Add-Type -MemberDefinition '
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")] public static extern IntPtr LoadImage(IntPtr hinst, string lpszName, uint uType, int cxDesired, int cyDesired, uint fuLoad);
    [DllImport("user32.dll")] public static extern int SendMessage(IntPtr hWnd, int msg, int wParam, IntPtr lParam);
    [DllImport("user32.dll")] public static extern IntPtr GetSystemMenu(IntPtr hWnd, bool bRevert);
    [DllImport("user32.dll")] public static extern bool DeleteMenu(IntPtr hMenu, uint uPosition, uint uFlags);
' -Name "Utils" -Namespace Win32 -PassThru

# Persistent Directory (แก้ปัญหา Icon หาย)
$InstallDir = "$env:LOCALAPPDATA\ITG_YToTV"
if (-not (Test-Path $InstallDir)) { New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null }

# Assets Config
$Assets = @{
    "MenuIcon" = "$GitHubRaw/YouTube.ico" 
    "ConsoleIcon" = "https://itgroceries.blogspot.com/favicon.ico"
    "Chrome"="$GitHubRaw/IconFiles/Chrome.ico"; "Edge"="$GitHubRaw/IconFiles/Edge.ico"; 
    "Brave"="$GitHubRaw/IconFiles/Brave.ico"; "Vivaldi"="$GitHubRaw/IconFiles/Vivaldi.ico"; 
    "Yandex"="$GitHubRaw/IconFiles/Yandex.ico"; "Chromium"="$GitHubRaw/IconFiles/Chromium.ico"; 
    "Thorium"="$GitHubRaw/IconFiles/Thorium.ico"
}

# Downloader
function DL ($U, $N) { 
    $D="$InstallDir\$N"
    if(!(Test-Path $D) -or (Get-Item $D).Length -eq 0){ try{ (New-Object Net.WebClient).DownloadFile($U,$D) }catch{} }
    return $D
}

# Pre-load Assets
foreach($k in $Assets.Keys){ DL $Assets[$k] "$k.ico" | Out-Null }
$LocalIcon = "$InstallDir\MenuIcon.ico"; $ConsoleIcon = "$InstallDir\ConsoleIcon.ico"

# --- [4. CONSOLE MANAGEMENT] ---
$ConsoleHandle = [Win32.Utils]::GetConsoleWindow()

if ($Silent) {
    # ถ้า Silent ซ่อน Console ไปเลย
    [Win32.Utils]::ShowWindow($ConsoleHandle, 0) | Out-Null
} else {
    # ถ้าโหมดปกติ จัดหน้าจอให้สวยงาม
    $host.UI.RawUI.WindowTitle = "IT Groceries Console"
    $host.UI.RawUI.BackgroundColor = "Black"
    $host.UI.RawUI.ForegroundColor = "Green"
    Clear-Host
    
    # คำนวณตำแหน่ง (ซ้าย-ขวา)
    $Scr = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
    $W = 500; $H = 820; $Gap = 10
    $TotalWidth = ($W * 2) + $Gap
    
    $X_Con = ($Scr.Width - $TotalWidth) / 2
    $Y_Pos = ($Scr.Height - $H) / 2
    
    # ใส่ Icon ให้ Console
    if(Test-Path $ConsoleIcon){ 
        $h=[Win32.Utils]::LoadImage([IntPtr]::Zero, $ConsoleIcon, 1, 0, 0, 0x10)
        if($h){ [Win32.Utils]::SendMessage($ConsoleHandle,0x80,[IntPtr]0,$h)|Out-Null; [Win32.Utils]::SendMessage($ConsoleHandle,0x80,[IntPtr]1,$h)|Out-Null } 
    }

    # FORCE SHOW & MOVE (ใช้ 0x0040 แบบ VMD เพื่อดีดหน้าต่างขึ้นมา)
    [Win32.Utils]::SetWindowPos($ConsoleHandle, [IntPtr]::Zero, [int]$X_Con, [int]$Y_Pos, [int]$W, [int]$H, 0x0040) | Out-Null
    
    Write-Host "`n    YOUTUBE TV INSTALLER v52.0" -ForegroundColor Cyan
    Write-Host "    [INIT] Ready..." -ForegroundColor Yellow
}

# --- [5. BROWSER LOGIC] ---
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
    # Taskkill แบบ User Mode (ไม่ต้อง Admin ก็ปิดของตัวเองได้)
    $s.Arguments = "/c taskkill /f /im $($Obj.E) /t >nul 2>&1 & start `"`" `"$($Obj.Path)`" --profile-directory=Default --app=https://youtube.com/tv --user-agent=`"Mozilla/5.0 (SMART-TV; LINUX; Tizen 9.0) AppleWebKit/537.36 (KHTML, like Gecko) 120.0.6099.5/9.0 TV Safari/537.36`" --start-fullscreen --disable-features=CalculateNativeWinOcclusion"
    $s.WindowStyle = 3
    
    # ใช้ Icon จาก AppData (ถาวร)
    if(Test-Path $LocalIcon){ $s.IconLocation = $LocalIcon }
    
    $s.Save()
    if(!$Silent){ Write-Host " [INSTALLED] $($Obj.N)" -ForegroundColor Green }
}

# CLI Mode Check
if ($Browser -ne "Ask") {
    if(!$Silent){ Write-Host "[CLI] Target: $Browser" -ForegroundColor Cyan }
    foreach($b in $Browsers){
        if($b.N -match $Browser -or $b.K -match $Browser){
            $FP=$null; foreach($p in $b.P){if(Test-Path $p){$FP=$p;break}}
            if($FP){ $b.Path=$FP; Install $b }
        }
    }
    exit
}

# --- [6. GUI SETUP] ---
$List=@(); foreach($b in $Browsers){
    $FP=$null; foreach($p in $b.P){if(Test-Path $p){$FP=$p;break}}
    $ImgObj=$null; $IcoPath="$InstallDir\$($b.K).ico"
    if(Test-Path $IcoPath){ try{ $U=New-Object Uri($IcoPath); $Bm=New-Object System.Windows.Media.Imaging.BitmapImage; $Bm.BeginInit(); $Bm.UriSource=$U; $Bm.CacheOption="OnLoad"; $Bm.EndInit(); $Bm.Freeze(); $ImgObj=$Bm }catch{} }
    if($FP){$List+=@{N=$b.N;Path=$FP;Exe=$b.E;Inst=$true;Img=$ImgObj}} else {$List+=@{N=$b.N;Path=$null;Exe=$b.E;Inst=$false;Img=$ImgObj}}
}

# XAML
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="YouTube TV Installer" Height="$H" Width="500" WindowStartupLocation="Manual" ResizeMode="NoResize" Background="#181818" Topmost="True">
    <Window.Resources>
        <Style x:Key="Sw" TargetType="{x:Type CheckBox}"><Setter Property="Template"><Setter.Value><ControlTemplate TargetType="{x:Type CheckBox}">
            <Border x:Name="T" Width="44" Height="24" Background="#3E3E3E" CornerRadius="12" Cursor="Hand"><Border x:Name="D" Width="20" Height="20" Background="White" CornerRadius="10" HorizontalAlignment="Left" Margin="2,0,0,0"><Border.RenderTransform><TranslateTransform x:Name="Tr" X="0"/></Border.RenderTransform></Border></Border>
            <ControlTemplate.Triggers><Trigger Property="IsChecked" Value="True"><Trigger.EnterActions><BeginStoryboard><Storyboard><DoubleAnimation Storyboard.TargetName="Tr" Storyboard.TargetProperty="X" To="20" Duration="0:0:0.2"/><ColorAnimation Storyboard.TargetName="T" Storyboard.TargetProperty="Background.Color" To="#2196F3" Duration="0:0:0.2"/></Storyboard></BeginStoryboard></Trigger.EnterActions><Trigger.ExitActions><BeginStoryboard><Storyboard><DoubleAnimation Storyboard.TargetName="Tr" Storyboard.TargetProperty="X" To="0" Duration="0:0:0.2"/><ColorAnimation Storyboard.TargetName="T" Storyboard.TargetProperty="Background.Color" To="#3E3E3E" Duration="0:0:0.2"/></Storyboard></BeginStoryboard></Trigger.ExitActions></Trigger><Trigger Property="IsEnabled" Value="False"><Setter Property="Opacity" Value="0.5"/></Trigger></ControlTemplate.Triggers>
        </ControlTemplate></Setter.Value></Setter>
        </Style>
        <Style x:Key="Bn" TargetType="Button"><Setter Property="Template"><Setter.Value><ControlTemplate TargetType="Button"><Border x:Name="b" Background="{TemplateBinding Background}" CornerRadius="22"><ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" TextElement.FontWeight="Bold"/></Border><ControlTemplate.Triggers><Trigger Property="IsMouseOver" Value="True"><Setter TargetName="b" Property="Opacity" Value="0.8"/></Trigger></ControlTemplate.Triggers></ControlTemplate></Setter.Value></Setter></Style>
    </Window.Resources>
    <Grid Margin="25"><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="20"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
        <Grid Grid.Row="0"><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
            <Image x:Name="Logo" Grid.Column="0" Width="80" Height="80"/>
            <StackPanel Grid.Column="1" VerticalAlignment="Center" Margin="20,0,0,0"><TextBlock Text="YouTube TV Installer" Foreground="White" FontSize="28" FontWeight="Bold"><TextBlock.Effect><DropShadowEffect Color="#FF0000" BlurRadius="15" Opacity="0.6"/></TextBlock.Effect></TextBlock><StackPanel Orientation="Horizontal" Margin="2,5,0,0"><TextBlock Text="Developed by IT Groceries Shop &#x2665;" Foreground="#FF0000" FontSize="14" FontWeight="Bold"/></StackPanel></StackPanel></Grid>
        <Border Grid.Row="2" Background="#1E1E1E"><ScrollViewer VerticalScrollBarVisibility="Auto"><StackPanel x:Name="List"/></ScrollViewer></Border>
        <Grid Grid.Row="3" Margin="0,20,0,0"><Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
            <StackPanel Orientation="Horizontal" Grid.Column="0">
                <Button x:Name="BF" Width="45" Height="45" Background="#1877F2" Style="{StaticResource Bn}" Margin="0,0,10,0" ToolTip="Facebook" Cursor="Hand"><TextBlock Text="f" Foreground="White" FontSize="26" FontWeight="Bold" Margin="0,-4,0,0"/></Button>
                <Button x:Name="BG" Width="45" Height="45" Background="#333333" Style="{StaticResource Bn}" ToolTip="GitHub" Cursor="Hand"><Viewbox Width="24" Height="24"><Path Fill="White" Data="M12 .297c-6.63 0-12 5.373-12 12 0 5.303 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61C4.422 18.07 3.633 17.7 3.633 17.7c-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.606-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 22.092 24 17.592 24 12.297c0-6.627-5.373-12-12-12"/></Viewbox></Button>
            </StackPanel>
            <StackPanel Orientation="Horizontal" Grid.Column="2"><Button x:Name="BC" Content="EXIT" Width="90" Height="45" Background="#D32F2F" Foreground="White" Style="{StaticResource Bn}" Margin="0,0,10,0" Cursor="Hand"/><Button x:Name="BA" Content="Start Install" Width="160" Height="45" Background="#2E7D32" Foreground="White" Style="{StaticResource Bn}" Cursor="Hand"/></StackPanel></Grid></Grid></Window>
"@

$r=(New-Object System.Xml.XmlNodeReader $xaml); $Win=[Windows.Markup.XamlReader]::Load($r)

# Align GUI Next to Console (ขวา)
try { $Win.Left = [int]$X_Con + [int]$W + [int]$Gap; $Win.Top = [int]$Y_Pos } catch {}

if(Test-Path $LocalIcon){
    try{ $U=New-Object Uri($LocalIcon); $B=New-Object System.Windows.Media.Imaging.BitmapImage; $B.BeginInit(); $B.UriSource=$U; $B.CacheOption="OnLoad"; $B.EndInit(); $B.Freeze(); $Win.Icon=$B; $Win.FindName("Logo").Source=$B }catch{}
}

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
$Win.ShowDialog()|Out-Null
