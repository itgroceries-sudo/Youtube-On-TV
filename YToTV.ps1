# =========================================================
#  YOUTUBE TV LAUNCHER v40.0 (User Mode)
# =========================================================
param([switch]$Silent, [string]$Browser)

$Url  = "https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/YToTV.cmd"
$Dest = "$env:TEMP\YToTV.cmd"

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-Host "[INIT] Downloading..." -ForegroundColor Cyan
    (New-Object System.Net.WebClient).DownloadFile($Url, $Dest)
} catch {
    Write-Host "[ERROR] Download Failed." -ForegroundColor Red; exit
}

# เตรียมคำสั่ง (ไม่ต้อง RunAs Admin แล้ว)
$ArgsList = @()
if ($Silent) { $ArgsList += "-Silent" }
if ($Browser) { $ArgsList += "-Browser"; $ArgsList += $Browser }

# สั่งรันแบบซ่อนหน้าต่าง cmd (WindowStyle Hidden)
Start-Process -FilePath $Dest -ArgumentList $ArgsList -WindowStyle Hidden
