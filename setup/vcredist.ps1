# https://blog.jourdant.me/post/3-ways-to-download-files-with-powershell
$urls = "$PSScriptRoot\urls"
$ShadowSpawn = "$PSScriptRoot\ShadowSpawn"
# Get-WmiObject -Class Win32_Product -Filter "Name LIKE '%Visual C++ 2010%'"
#if ((gwmi win32_operatingsystem | select osarchitecture).osarchitecture -like "64*") {

$proxy = [System.Net.WebProxy]::GetDefaultProxy() | select address

if (Get-WmiObject -Class Win32_Product -Filter "Name LIKE '%Visual C++ 2010%'") {
  Write-Host "Visual C++ 2010 Redistributable already installed"
} else {
  Write-Host "Try to Install Visual C++ 2010 Redistributable"
  if ((gwmi win32_operatingsystem | select osarchitecture).osarchitecture -like "64*") {
    
    $vcredist = "$ShadowSpawn\vcredist-2010_x64.exe"

    if(![System.IO.File]::Exists($vcredist)){
      $url = Get-Content "$urls\vcredist64.url"
      [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
      $wc = New-Object System.Net.WebClient

      Write-Host "Download vcredist 2010 64-bit from $url to $vcredist"
      
      $wc.DownloadFile("$url", "$vcredist")
    }
  } else {

    $vcredist = "$ShadowSpawn\vcredist-2010_x86.exe"

    if(![System.IO.File]::Exists($vcredist)){
      $url = Get-Content "$urls\vcredist86.url"
      [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
      $wc = New-Object System.Net.WebClient

      Write-Host "Download vcredist 2010 32-bit from $url to $vcredist"
      
      $wc.DownloadFile("$url", "$vcredist")
    }
  }
  Start-Process -FilePath "$vcredist" -ArgumentList "/Q" -Wait
  if ($lastexitcode -ne 0) {
    Write-Host $errorMessage
  }
}
