# https://blog.jourdant.me/post/3-ways-to-download-files-with-powershell
$cygdir = "$PSScriptRoot\cygwin"
$urls = "$PSScriptRoot\urls"
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
$cygwin