# https://blog.jourdant.me/post/3-ways-to-download-files-with-powershell
$cygdir = "$PSScriptRoot\cygwin"
$urls = "$PSScriptRoot\urls"
$mirrorlist = "$urls\cygwin.mirrors"

if ((gwmi win32_operatingsystem | select osarchitecture).osarchitecture -like "64*") {
  
  $cygwin = "$cygdir\setup-x86_64.exe"

  if(![System.IO.File]::Exists($cygwin)){
    "Download cygwin 64-bit"
    $url = Get-Content "$urls\cygwin64.url"
    $wc = New-Object System.Net.WebClient
    
    $wc.DownloadFile($url, $cygwin)
  }
} else {

  $cygwin = "$cygdir\setup-x86.exe"

  if(![System.IO.File]::Exists($cygwin)){
    "Download cygwin 32-bit"
    $url = Get-Content "$urls\cygwin32.url"
    $wc = New-Object System.Net.WebClient
    
    $wc.DownloadFile($url, $cygwin)
  }
}
$list="$PSScriptRoot\cyg-packages.lst"
$content = (Get-Content $list) -replace '(\s|\r)+$', ''
$modules = [string]::join(",", $content)
$parent = Split-Path -parent $PSScriptRoot
$repo = "$cygdir\repo"

$mirrors = @(Get-Content $mirrorlist)

foreach ($mirror in $mirrors) {
  Write-Host $mirror

  $HTTP_Request = [System.Net.WebRequest]::Create($mirror)
  $HTTP_Response = $HTTP_Request.GetResponse()
  $HTTP_Status = [int]$HTTP_Response.StatusCode

  if ($HTTP_Status -eq 200) {
    Write-Host "Donwload cygwin packages from $mirror"
    $mirror = "http://mirrors.kernel.org/sourceware/cygwin/"
    $args = @(
      "--download",
      "--no-admin",
      "--root","$parent\cygwin.XXX",
      "--local-package-dir",$repo,
      "--no-desktop",
      "--no-startmenu",
      "--no-shortcuts",
      "--no-verify",
      "--site", $mirror
      "--quiet-mode","--packages",$modules
    ) 
    & $cygwin $args
    break
  } else {
      Write-Host "The mirror '$mirror' may be down. Go try next one..."
  }
}
