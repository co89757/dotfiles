#Requires -RunAsAdministrator
[CmdletBinding()]
param(

)

Set-ExecutionPolicy Bypass

function Install-Choco () {
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

function Add-Path () {
  [CmdletBinding(SupportsShouldProcess = $true)]
  param(
    # path to add
    [Parameter(Mandatory, ValueFromPipeline)]
    [string]
    $PathToAdd
  )
  $RegistryKey = "Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment"
  $oldPath = (Get-ItemProperty -Path $RegistryKey -Name "Path").Path
  if (-not (Test-Path -Path $PathToAdd)) {
    Write-Error "$PathToAdd does not exist"
    return
  }
  if ($oldPath.Contains( $PathToAdd) ) {
    Write-Host "$PathToAdd already exists in PATH" -Fore Green
    return
  }
  $NewPath = $oldPath + ";" + $PathToAdd
  Set-ItemProperty -Path $RegistryKey -Name "PATH" -Value $NewPath
  Write-Host "Appended path $PathToAdd" -Fore Green
}

function Install-P4Merge () {
  where.exe choco
  if ($LASTEXITCODE -ne 0) {
    Write-Host "Chocolatey( pkg management for win) is not installed, installing choco first ..." -Fore Green
    Install-Choco
  }
  where.exe p4merge
  if ($LASTEXITCODE -ne 0) {
    Write-Host "Chocolatey( pkg management for win) is not installed, installing choco first ..." -Fore Green
    choco.exe install p4merge
  }
  else {
    Write-Host "p4merge is already installed. skipping .." -Fore Green
  }
  Add-PATH -AddedFolder "C:\\Program Files\\Perforce"
}

function Config-P4merge () {
  [CmdletBinding()]
  param()
  Write-Host "Configuring git to use p4merge as mergetool"
  cmd.exe --% /c git config --global merge.tool p4merge & git config --global mergetool.p4merge.path 'C:\Program Files\Perforce\p4merge.exe'
}

Install-P4Merge
Config-P4merge