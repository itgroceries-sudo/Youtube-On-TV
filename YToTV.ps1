# =========================================================
#  YOUTUBE TV LAUNCHER v44.0 (Visibility Fix)
# =========================================================
param([switch]$Silent, [string]$Browser)

# 1. Config URL (Must match your GitHub repo)
$Url  = "https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/YToTV.cmd"
$Dest = "$env:TEMP\YToTV.cmd"

# 2. Download Core Component
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    Write-Host "[INIT] Downloading Core Component..." -ForegroundColor Cyan
    (New-Object System.Net.WebClient).DownloadFile($Url, $Dest)
} catch {
    Write-Host "[ERROR] Download Failed. Check URL." -ForegroundColor Red; exit
}

# 3. Prepare Arguments
$ArgsList = @()
if ($Silent) { $ArgsList += "-Silent" }
if ($Browser) { $ArgsList += "-Browser"; $ArgsList += $Browser }

# 4. Launch Logic (FIXED: Explicit WindowStyle)
Write-Host "[INIT] Launching Installer..." -ForegroundColor Yellow

if ($Silent) {
    # Silent Mode: Hide everything
    if ($ArgsList.Count -gt 0) {
        Start-Process -FilePath $Dest -ArgumentList $ArgsList -WindowStyle Hidden
    } else {
        Start-Process -FilePath $Dest -WindowStyle Hidden
    }
} else {
    # Normal Mode: Force NORMAL window style (Fixes "Console Disappeared" issue)
    if ($ArgsList.Count -gt 0) {
        Start-Process -FilePath $Dest -ArgumentList $ArgsList -WindowStyle Normal
    } else {
        Start-Process -FilePath $Dest -WindowStyle Normal
    }
}
