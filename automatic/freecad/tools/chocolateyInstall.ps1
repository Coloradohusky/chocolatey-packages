﻿$ErrorActionPreference = 'Stop';

if (!$PSScriptRoot) { $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent }
. "$PSScriptRoot\helper.ps1"

$packageArgs = @{
  packageName    = 'freecad'
  fileType       = '7z'
  url64          = 'https://github.com/FreeCAD/FreeCAD-Bundle/releases/download/weekly-builds/FreeCAD_weekly-builds-37841-conda-Windows-x86_64-py311.7z'
  softwareName   = 'FreeCAD'
  checksum64     = 'BA22443BBDC70212C11A367CEEF27CBAAD16319020494971C33671CBAC021F91'
  checksumType64 = 'sha256'
  silentArgs     = '/S'
  validExitCodes = @(0)
}

if (( $packageArgs.filetype -eq '7z' ) -or ( $packageArgs.filetype -eq 'zip' )) {
  # Checking for Package Parameters
  $pp = ( Get-UserPackageParams -scrawl )
  if ($pp.InstallDir) { $packageArgs.Add( "UnzipLocation", $pp.InstallDir ) }
  Install-ChocolateyZipPackage @packageArgs
  if ($pp.Shortcut) { $pp.Remove("Shortcut"); Install-ChocolateyShortcut @pp }
  $files = get-childitem $pp.WorkingDirectory -filter "*.exe" -recurse
  foreach ($file in $files) {
    if ( $file -notmatch "freecad" ) {
      $file = $file.Fullname
      New-Item "$file.ignore" -type "file" -force | Out-Null # Generate an ignore file(s)
    }
  }
}
else {
  Install-ChocolateyPackage @packageArgs
}
