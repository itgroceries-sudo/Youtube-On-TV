# =========================================================
#  YOUTUBE TV LAUNCHER v42.0 (Fix Args Error)
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

# เตรียม Arguments
$ArgsList = @()
if ($Silent) { $ArgsList += "-Silent" }
if ($Browser) { $ArgsList += "-Browser"; $ArgsList += $Browser }

# สั่งรัน (แยกกรณีชัดเจน เพื่อแก้บั๊ก ParameterBindingValidationException)
if ($ArgsList.Count -gt 0) {
    # กรณีมีค่าส่งไป (เช่น -Silent)
    Start-Process -FilePath $Dest -ArgumentList $ArgsList -WindowStyle Hidden
} else {
    # กรณีตัวเปล่า (ห้ามใส่ -ArgumentList เด็ดขาด)
    Start-Process -FilePath $Dest -WindowStyle Hidden
}
