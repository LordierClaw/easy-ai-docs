. (Join-Path $PSScriptRoot 'common.ps1')
$target=Join-Path $env:USERPROFILE '.local/bin/claude.exe'
if($Context.action -eq 'doctor') {
  Write-Output 'DIAGNOSIS (read-only): Claude Code'
  if(!(Test-Path -LiteralPath $target)){Write-Output 'CLI missing; choose install.';exit 0}
  $version=& $target --version 2>&1;Write-Output ('CLI exit='+$LASTEXITCODE+' '+$version)
  $null=& $target auth status 2>&1;Write-Output ('Authentication exit='+$LASTEXITCODE)
  exit 0
}
if($Context.action -notin @('install','configure','repair','auth')){throw 'Unsupported action.'}
Require-Runtime 'git' '2.40.0' '/.shared/git'
exit 0
