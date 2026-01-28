# =========================================================
#  YOUTUBE TV LAUNCHER v47.0 (Clean Launch)
# =========================================================
param([switch]$Silent, [string]$Browser)

# 1. Config URL (Check your GitHub path)
$Url  = "https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/YToTV.cmd"
$Dest = "$env:TEMP\YToTV.cmd"

# 2. Download
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-Host "[INIT] Downloading Core Component..." -ForegroundColor Cyan
    (New-Object System.Net.WebClient).DownloadFile($Url, $Dest)
} catch {
    Write-Host "[ERROR] Download Failed." -ForegroundColor Red; exit
}

# 3. Arguments
$ArgsList = @()
if ($Silent) { $ArgsList += "-Silent" }
if ($Browser) { $ArgsList += "-Browser"; $ArgsList += $Browser }

# 4. Execute
# Always launch HIDDEN. The Core (.cmd) will decide to show itself if not silent.
Write-Host "[INIT] Executing..." -ForegroundColor Yellow
if ($ArgsList.Count -gt 0) {
    Start-Process -FilePath $Dest -ArgumentList $ArgsList -WindowStyle Hidden
} else {
    Start-Process -FilePath $Dest -WindowStyle Hidden
}
