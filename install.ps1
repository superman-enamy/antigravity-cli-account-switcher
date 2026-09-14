# agy-switch Windows PowerShell Installer
# Universal multi-account switcher for Google Antigravity CLI (agy)

Write-Host "Installing agy-switch for Windows..." -ForegroundColor Cyan

# 1. Check Python
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) {
    Write-Host "Error: Python is not installed or not in PATH." -ForegroundColor Red
    Write-Host "Please install Python 3 from https://python.org or the Microsoft Store." -ForegroundColor Yellow
    exit 1
}

# 2. Setup Target Directory
$targetDir = Join-Path $HOME ".local\bin"
if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
}

$scriptPath = Join-Path $PSScriptRoot "agy-switch"
$destFile = Join-Path $targetDir "agy-switch"

if (Test-Path $scriptPath) {
    Copy-Item $scriptPath $destFile -Force
} else {
    $repoUrl = if ($env:GITHUB_REPO) { $env:GITHUB_REPO } else { "https://raw.githubusercontent.com/superman-enamy/antigravity-cli-account-switcher/main" }
    Invoke-WebRequest -Uri "$repoUrl/agy-switch" -OutFile $destFile
}

# 3. Create CMD batch wrappers for Windows Terminal / CMD
$cmdShim = @"
@echo off
python "$destFile" %*
"@
Set-Content -Path (Join-Path $targetDir "agy-switch.cmd") -Value $cmdShim -Encoding ASCII
Set-Content -Path (Join-Path $targetDir "agy-account.cmd") -Value $cmdShim -Encoding ASCII

# 4. Add to User PATH if missing
$userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($userPath -notlike "*$targetDir*") {
    [Environment]::SetEnvironmentVariable("PATH", "$userPath;$targetDir", "User")
    $env:PATH = "$env:PATH;$targetDir"
}

# 5. Add PowerShell profile functions
$profileDir = Split-Path $PROFILE
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}
if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}

$psIntegration = @"

# Antigravity CLI (agy) Account Switcher integration
function agy {
    param([Parameter(ValueFromRemainingArguments = `$true)]`$args)
    if (`$args.Count -gt 0 -and (`$args[0] -eq 'accounts' -or `$args[0] -eq 'account')) {
        python "$destFile" list `$args[1..`$args.Count]
    } elseif (`$args.Count -gt 0 -and `$args[0] -eq 'switch') {
        if (`$args.Count -eq 1) {
            python "$destFile"
        } else {
            python "$destFile" switch `$args[1..`$args.Count]
        }
    } else {
        & (Get-Command agy.exe -CommandType Application).Source @args
    }
}
"@

$profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ($profileContent -notlike "*Antigravity CLI (agy) Account Switcher integration*") {
    Add-Content -Path $PROFILE -Value $psIntegration
}

# 6. Initialize
Write-Host "Initializing account vault..." -ForegroundColor Cyan
& python $destFile list

Write-Host "`nInstallation successful!" -ForegroundColor Green
Write-Host "Commands available:" -ForegroundColor White
Write-Host "  agy accounts" -ForegroundColor Yellow
Write-Host "  agy switch" -ForegroundColor Yellow
Write-Host "  agy switch pro2" -ForegroundColor Yellow
Write-Host "  agy-switch add <alias>" -ForegroundColor Yellow
