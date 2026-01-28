# =========================================================
#  YOUTUBE TV LAUNCHER v37.0 (Fixed Args)
# =========================================================
param([switch]$Silent, [string]$Browser)

# 1. ลิ้งค์ไปยังไฟล์ตัวจริง (ต้องแก้ให้ตรงกับ GitHub ของคุณ)
$Url  = "https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/YToTV.cmd"
$Dest = "$env:TEMP\YToTV.cmd"

# 2. ดาวน์โหลด
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-Host "[INIT] Downloading Core Component..." -ForegroundColor Cyan
    (New-Object System.Net.WebClient).DownloadFile($Url, $Dest)
} catch {
    Write-Host "[ERROR] Download Failed." -ForegroundColor Red; exit
}

# 3. เตรียม Arguments
$ArgsList = ""
if ($Silent) { $ArgsList += " -Silent" }
if ($Browser) { $ArgsList += " -Browser $Browser" }

# 4. สั่งรัน (แก้บั๊กตรงนี้: เช็คก่อนว่ามี Args ไหม)
Write-Host "[INIT] Launching Installer..." -ForegroundColor Yellow

if ($ArgsList.Trim().Length -gt 0) {
    Start-Process -FilePath $Dest -ArgumentList $ArgsList -Verb RunAs
} else {
    Start-Process -FilePath $Dest -Verb RunAs
}
