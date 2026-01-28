# =========================================================
#  YOUTUBE TV LAUNCHER (Run this via IEX)
# =========================================================
param([switch]$Silent, [string]$Browser)

# 1. ลิ้งค์ไปยังไฟล์ตัวจริง (ต้องแก้ให้ตรงกับ GitHub ของคุณ)
$Url  = "https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/YToTV.cmd"
$Dest = "$env:TEMP\YToTV.cmd"

# 2. ดาวน์โหลดไฟล์ตัวจริง
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-Host "[INIT] Downloading Core Component..." -ForegroundColor Cyan
    (New-Object System.Net.WebClient).DownloadFile($Url, $Dest)
} catch {
    Write-Host "[ERROR] Download Failed. Check URL." -ForegroundColor Red
    exit
}

# 3. สร้าง Argument String เพื่อส่งต่อค่า
$ArgsList = ""
if ($Silent) { $ArgsList += " -Silent" }
if ($Browser) { $ArgsList += " -Browser $Browser" }

# 4. สั่งรันตัวจริง (.cmd) ด้วยสิทธิ์ Admin
Write-Host "[INIT] Launching Installer (Admin Request)..." -ForegroundColor Yellow
Start-Process -FilePath $Dest -ArgumentList $ArgsList -Verb RunAs
