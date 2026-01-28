# =========================================================
#  YOUTUBE TV LAUNCHER v39.0 (Silent Start)
# =========================================================
param([switch]$Silent, [string]$Browser)

$Url  = "https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/YToTV.cmd"
$Dest = "$env:TEMP\YToTV.cmd"

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-Host "[INIT] Downloading Core..." -ForegroundColor Cyan
    (New-Object System.Net.WebClient).DownloadFile($Url, $Dest)
} catch {
    Write-Host "[ERROR] Download Failed." -ForegroundColor Red; exit
}

$ExecArgs = @()
if ($Silent) { $ExecArgs += "-Silent" }
if ($Browser) { $ExecArgs += "-Browser"; $ExecArgs += $Browser }

# สั่งรันแบบซ่อนหน้าต่าง Launcher (WindowStyle Hidden)
if ($ExecArgs.Count -gt 0) {
    Start-Process -FilePath $Dest -ArgumentList $ExecArgs -Verb RunAs -WindowStyle Hidden
} else {
    Start-Process -FilePath $Dest -Verb RunAs -WindowStyle Hidden
}
