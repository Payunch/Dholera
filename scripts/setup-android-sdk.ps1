<#
setup-android-sdk.ps1
Runs the Android command-line tools install and creates a Pixel 6 AVD.
Run as Administrator in PowerShell. This downloads several GB.
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "Preparing Android SDK directory..."
$SDKROOT = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
If (-Not (Test-Path $SDKROOT)) { New-Item -ItemType Directory -Path $SDKROOT -Force | Out-Null }
Write-Host "SDK root:" $SDKROOT

$zipUrl = 'https://dl.google.com/android/repository/commandlinetools-win-9477386_latest.zip'
$tmp = Join-Path $env:TEMP 'cmdline_tools.zip'
Write-Host "Downloading command-line tools (might take a few minutes)..."
Invoke-WebRequest -Uri $zipUrl -OutFile $tmp -UseBasicParsing

Write-Host "Extracting..."
$extractPath = Join-Path $SDKROOT 'cmdline-tools'
If (-Not (Test-Path $extractPath)) { New-Item -ItemType Directory -Path $extractPath | Out-Null }
Expand-Archive -Path $tmp -DestinationPath $extractPath -Force

# Normalize folder layout to cmdline-tools/latest
If (Test-Path (Join-Path $extractPath 'tools')) {
    If (-Not (Test-Path (Join-Path $extractPath 'latest'))) { New-Item -ItemType Directory -Path (Join-Path $extractPath 'latest') | Out-Null }
    Move-Item -Path (Join-Path $extractPath 'tools\*') -Destination (Join-Path $extractPath 'latest') -Force
}

$env:PATH = (Join-Path $extractPath 'latest\bin') + ';' + (Join-Path $SDKROOT 'emulator') + ';' + (Join-Path $SDKROOT 'platform-tools') + ';' + $env:PATH

Write-Host "Installing platforms, emulator and system image (this will download several GB)."
Start-Process -FilePath (Join-Path $extractPath 'latest\bin\sdkmanager') -ArgumentList @("platform-tools", "emulator", "platforms;android-33", "system-images;android-33;google_apis;x86_64") -Wait

Write-Host "Accepting licenses..."
Start-Process -FilePath (Join-Path $extractPath 'latest\bin\sdkmanager') -ArgumentList @('--licenses') -Wait

Write-Host "Creating AVD 'pixel_6' if missing..."
$avdList = & (Join-Path $extractPath 'latest\bin\avdmanager') list avd 2>$null
If ($avdList -notmatch 'Name: pixel_6') {
    Start-Process -FilePath (Join-Path $extractPath 'latest\bin\avdmanager') -ArgumentList @('create', 'avd', '-n', 'pixel_6', '-k', 'system-images;android-33;google_apis;x86_64', '--device', 'pixel', '--force') -Wait
}

Write-Host "Setup complete. You can now run scripts/run-dev-emulator.ps1 to launch emulator and run Flutter app."
