<#
run-dev-emulator.ps1
Launches the Pixel 6 emulator and runs the Flutter app with the dev flavor.
Run in a normal PowerShell after running setup-android-sdk.ps1 (if needed).
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "Launching Pixel_6 emulator (if not running)..."
flutter emulators --launch Pixel_6
Start-Sleep -Seconds 6

Write-Host "Listing connected devices..."
flutter devices

Write-Host "Running Flutter dev flavor..."
flutter run --flavor dev -t lib/main.dart
