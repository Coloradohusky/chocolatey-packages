Import-Module Chocolatey-AU
Import-Module "$PSScriptRoot\..\..\scripts\au_extensions.psm1"

$releases32 = 'https://www.zotero.org/download/client/dl?channel=release&platform=win32'
$releases64 = 'https://www.zotero.org/download/client/dl?channel=release&platform=win-x64'
$softwareName = 'Zotero'

function global:au_BeforeUpdate { Get-RemoteFiles -Purge -NoSuffix }

function global:au_SearchReplace {
  $version = $Latest.Version.ToString()

  @{
    ".\legal\VERIFICATION.txt" = @{
      "(?i)(\s*1\..+)\<.*\>" = "`${1}<$($Latest.URL32)>"
      "(?i)(^\s*checksum\s*type\:).*" = "`${1} $($Latest.ChecksumType32)"
      "(?i)(^\s*checksum(32)?\:).*" = "`${1} $($Latest.Checksum32)"
    }
    ".\tools\chocolateyInstall.ps1" = @{
      "(?i)^(\s*softwareName\s*=\s*)'.*'" = "`${1}'$softwareName'"
      "(?i)(^\s*file\s*=\s*`"[$]toolsPath\\).*" = "`${1}$($Latest.FileName32)`""
      "(?i)(^\s*file64\s*=\s*`"[$]toolsPath\\).*" = "`${1}$($Latest.FileName64)`""
    }
    ".\tools\chocolateyUninstall.ps1" = @{
      "(?i)^(\s*softwareName\s*=\s*)'.*'" = "`${1}'$softwareName'"
    }
    ".\$($Latest.PackageName).nuspec" = @{
      "(\<releaseNotes\>).*(\<\/releaseNotes\>)" = "`${1}https://www.zotero.org/support/$($version.Major).$($version.Minor)_changelog`${2}"
    }
  }
}

function global:au_GetLatest {
    $url32 = Get-RedirectedUrl -url $releases32
    $url64 = Get-RedirectedUrl -url $releases64

    $version  = $url32 -split '/' | Select-Object -Last 1 -Skip 1

    @{
        Version      = $version
        URL32        = $url32
        URL64        = $url64
    }
}

update -ChecksumFor none
