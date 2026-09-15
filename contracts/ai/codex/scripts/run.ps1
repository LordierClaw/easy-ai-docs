. (Join-Path $PSScriptRoot 'common.ps1')
if($Context.action -eq 'doctor'){
  Write-Output 'DIAGNOSIS (read-only):'
  foreach($file in @('codex.cmd','launch-codex.ps1','home/config.toml','home/credentials.dpapi')) {
    Write-Output ($file+': '+$(if(Test-Path -LiteralPath (Join-Path $Prefix $file)){'present'}else{'missing; choose install or configure'}))
  }
  $cli=Join-Path $Prefix 'codex.cmd'
  if(Test-Path -LiteralPath $cli){$version=& $cli --version 2>&1; Write-Output ('CLI exit='+$LASTEXITCODE+' '+$version)}
  exit 0
}
if($Context.action -notin @('install','configure','repair','auth')){throw 'Unsupported action.'}
Require-Runtime 'git' '2.40.0' '/.shared/git'
Require-Runtime 'node' '22.0.0' '/.shared/nodejs'
if($Context.action -in @('configure','auth') -and !(Test-Path -LiteralPath (Join-Path $Prefix 'codex.cmd'))){Stop-Contract 'codex.missing' 'Cần chọn Cài đặt Codex trước.' @{type='message';message='Quay lại Codex và chọn Cài đặt.'}}
Write-Output 'Điều kiện Git/Node đã đạt.'
exit 0
