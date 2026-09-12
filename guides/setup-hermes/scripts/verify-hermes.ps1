param([Parameter(Mandatory)][string]$Prefix,[ValidateSet('cli','config')][string]$Mode='cli')
$ErrorActionPreference='Stop'
$target=Join-Path $Prefix 'venv/Scripts/hermes.exe'
if(!(Test-Path -LiteralPath $target)){throw 'Chưa có Hermes CLI trong vùng EasyAI.'}
$previousHermesHome=$env:HERMES_HOME
$env:HERMES_HOME=Join-Path $Prefix 'home'
try {
  $version=& $target --version
  if($LASTEXITCODE -ne 0 -or "$version" -notmatch 'Hermes'){throw 'Hermes CLI chưa chạy được.'}
  if($Mode -eq 'config') {
    if(!(Test-Path -LiteralPath (Join-Path $env:HERMES_HOME 'config.yaml'))){throw 'Chưa có cấu hình. Mở Hermes - Setup.'}
    $null=& $target config check
    if($LASTEXITCODE -ne 0){throw 'Hermes config check chưa đạt. Mở Hermes - Setup và kiểm tra provider/model.'}
  }
  Write-Output ('HERMES_'+$Mode.ToUpperInvariant()+'_OK: '+$version)
} finally { $env:HERMES_HOME=$previousHermesHome }
exit 0
