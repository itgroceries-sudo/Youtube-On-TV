# =========================================================
#  YOUTUBE TV LAUNCHER v46.0 (Stable)
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

$ArgsList = @()
if ($Silent) { $ArgsList += "-Silent" }
if ($Browser) { $ArgsList += "-Browser"; $ArgsList += $Browser }

if ($Silent) {
    if ($ArgsList.Count -gt 0) {
        Start-Process -FilePath $Dest -ArgumentList $ArgsList -WindowStyle Hidden
    } else {
        Start-Process -FilePath $Dest -WindowStyle Hidden
    }
} else {
    # Normal Mode: Use Normal style
    if ($ArgsList.Count -gt 0) {
        Start-Process -FilePath $Dest -ArgumentList $ArgsList -WindowStyle Normal
    } else {
        Start-Process -FilePath $Dest -WindowStyle Normal
    }
}
