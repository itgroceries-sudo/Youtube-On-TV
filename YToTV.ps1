# =========================================================
#  YOUTUBE TV LAUNCHER v38.0 (Bulletproof Args)
# =========================================================
param([switch]$Silent, [string]$Browser)

# 1. URL ไฟล์ตัว Core (ต้องแก้ให้ตรงกับ GitHub ของคุณ)
$Url  = "https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/YToTV.cmd"
$Dest = "$env:TEMP\YToTV.cmd"

# 2. ดาวน์โหลด (พร้อม Error Handling)
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-Host "[INIT] Downloading Core Component..." -ForegroundColor Cyan
    (New-Object System.Net.WebClient).DownloadFile($Url, $Dest)
} catch {
    Write-Host "[ERROR] Download Failed. Please check internet or URL." -ForegroundColor Red
    exit
}

# 3. เตรียม Arguments (ใส่ลง Array เพื่อความชัวร์)
$ExecArgs = @()
if ($Silent) { $ExecArgs += "-Silent" }
if ($Browser) { $ExecArgs += "-Browser"; $ExecArgs += $Browser }

# 4. สั่งรัน (แยกกรณีชัดเจน เพื่อกัน Error ค่าว่าง)
Write-Host "[INIT] Launching Installer..." -ForegroundColor Yellow

if ($ExecArgs.Count -gt 0) {
    # กรณีมี Argument (เช่น -Silent)
    Start-Process -FilePath $Dest -ArgumentList $ExecArgs -Verb RunAs
} else {
    # กรณีไม่มี Argument เลย (เรียก GUI ปกติ)
    Start-Process -FilePath $Dest -Verb RunAs
}
