# =========================================================
#  YOUTUBE TV LAUNCHER v43.0 (International Final)
# =========================================================
param([switch]$Silent, [string]$Browser)

# 1. Config URL (Ensure this matches your GitHub repo)
$Url  = "https://raw.githubusercontent.com/itgroceries-sudo/Youtube-On-TV/main/YToTV.cmd"
$Dest = "$env:TEMP\YToTV.cmd"

# 2. Download Core Component
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    Write-Host "[INIT] Downloading Core Component..." -ForegroundColor Cyan
    (New-Object System.Net.WebClient).DownloadFile($Url, $Dest)
} catch {
    Write-Host "[ERROR] Download Failed. Check URL or Internet Connection." -ForegroundColor Red; exit
}

# 3. Prepare Arguments
$ArgsList = @()
if ($Silent) { $ArgsList += "-Silent" }
if ($Browser) { $ArgsList += "-Browser"; $ArgsList += $Browser }

# 4. Launch Logic (FIXED: Console Visibility)
Write-Host "[INIT] Launching Installer..." -ForegroundColor Yellow

if ($Silent) {
    # Silent Mode: Hide everything (Launcher + Core)
    if ($ArgsList.Count -gt 0) {
        Start-Process -FilePath $Dest -ArgumentList $ArgsList -WindowStyle Hidden
    } else {
        Start-Process -FilePath $Dest -WindowStyle Hidden
    }
} else {
    # Normal Mode: Do NOT force hide here. Let the Core (.cmd) handle its own visibility.
    # The .cmd header starts hidden, sets up UI, then unhides the console automatically.
    if ($ArgsList.Count -gt 0) {
        Start-Process -FilePath $Dest -ArgumentList $ArgsList
    } else {
        Start-Process -FilePath $Dest
    }
}
