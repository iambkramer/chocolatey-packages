import-module au
import-module "$PSScriptRoot\..\..\extensions\chocolatey-core.extension\extensions\chocolatey-core.psm1"
Import-Module "$PSScriptRoot\..\..\scripts\au_extensions.psm1"

if ($MyInvocation.InvocationName -ne '.') {
  function global:au_BeforeUpdate {
    $Latest.Checksum32 = Get-RemoteChecksum $Latest.URL32
    $Latest.Checksum64 = Get-RemoteChecksum $Latest.URL64
  }
}

function global:au_SearchReplace {
  @{
    'tools\chocolateyInstall.ps1' = @{
      "(?i)(^\s*packageName\s*=\s*)('.*')" = "`$1'$($Latest.PackageName)'"
      "(?i)(^\s*url\s*=\s*)('.*')"         = "`$1'$($Latest.URL32)'"
      "(?i)(^\s*url64bit\s*=\s*)('.*')"    = "`$1'$($Latest.URL64)'"
      "(?i)(^\s*checksum\s*=\s*)('.*')"    = "`$1'$($Latest.Checksum32)'"
      "(?i)(^\s*checksum64\s*=\s*)('.*')"  = "`$1'$($Latest.Checksum64)'"
      "(?i)(^[$]version\s*=\s*)('.*')"     = "`$1'$($Latest.RemoteVersion)'"
    }
  }
}

function global:au_GetLatest {
  $latestRelease = Get-GitHubRelease microsoft vscode
  $version = $latestRelease.tag_name
  # URLs are documented here: https://code.visualstudio.com/docs/supporting/faq#_previous-release-versions
  $url32 = "https://update.code.visualstudio.com/$version/win32/stable"
  $url64 = "https://update.code.visualstudio.com/$version/win32-x64/stable"

  @{
    Version       = $version
    RemoteVersion = $version
    URL32         = $url32
    URL64         = $url64
  }
}

if ($MyInvocation.InvocationName -ne '.') {
  update -ChecksumFor none
}
