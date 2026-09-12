param([ValidateSet('cli','auth')][string]$Mode='cli')
$ErrorActionPreference='Stop'
$target=Join-Path $env:USERPROFILE '.local/bin/claude.exe'
if(!(Test-Path -LiteralPath $target)){throw 'Chưa có Claude Code native CLI.'}
$version=& $target --version
if($LASTEXITCODE -ne 0 -or "$version" -notmatch 'Claude Code'){throw 'Claude CLI không chạy được.'}
if($Mode -eq 'auth') {
  # Official CLI exit code is 0 when logged in, 1 otherwise. Discard account JSON.
  $null=& $target auth status
  if($LASTEXITCODE -ne 0){throw 'Claude chưa xác nhận đăng nhập. Mở Claude Code và hoàn tất đăng nhập chính thức.'}
}
Write-Output ('CLAUDE_'+$Mode.ToUpperInvariant()+'_OK: '+$version)
exit 0
