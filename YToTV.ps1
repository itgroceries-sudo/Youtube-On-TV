# =========================================================
#  YOUTUBE TV LAUNCHER v45.0 (Final Logic)
# =========================================================
param([switch]$Silent, [string]$Browser)

$Url  = "https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/YToTV.cmd"
$Dest = "$env:TEMP\YToTV.cmd"

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    Write-Host "[INIT] Downloading Core..." -ForegroundColor Cyan
    (New-Object System.Net.WebClient).DownloadFile($Url, $Dest)
} catch {
    Write-Host "[ERROR] Download Failed." -ForegroundColor Red; exit
}

$ArgsList = @()
if ($Silent) { $ArgsList += "-Silent" }
if ($Browser) { $ArgsList += "-Browser"; $ArgsList += $Browser }

# --- FIX: Explicit WindowStyle Logic ---
if ($Silent) {
    # Silent Mode: Launch Hidden
    if ($ArgsList.Count -gt 0) {
        Start-Process -FilePath $Dest -ArgumentList $ArgsList -WindowStyle Hidden
    } else {
        Start-Process -FilePath $Dest -WindowStyle Hidden
    }
} else {
    # Normal Mode: Launch Normal (Let the Core handle the initial flicker/hide)
    if ($ArgsList.Count -gt 0) {
        Start-Process -FilePath $Dest -ArgumentList $ArgsList -WindowStyle Normal
    } else {
        Start-Process -FilePath $Dest -WindowStyle Normal
    }
}
