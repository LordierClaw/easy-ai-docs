param([Parameter(Mandatory)][string]$Prefix)
$ErrorActionPreference='Stop'
# EasyAI has already selected system or bundled runtimes for this process.
$target=Join-Path $Prefix 'codex.cmd'
if(Test-Path -LiteralPath $target){
  $version=& $target --version
  if($LASTEXITCODE -eq 0 -and "$version" -match 'codex-cli \d+'){
    Write-Output ('Reused: '+$version)
    exit 0
  }
  throw 'Bản Codex trong vùng quản lý bị lỗi. Giữ log, kiểm tra package rồi đề xuất sửa; không tự cài đè.'
}
foreach($tool in @('git.exe','node.exe','npm.cmd')){
  if(!(Get-Command $tool -CommandType Application -ErrorAction SilentlyContinue)){throw ('Thiếu '+$tool+'. Chạy lại bước ensure_runtime và kiểm tra bundle/PATH của EasyAI.')}
}
New-Item -ItemType Directory -Force -Path $Prefix | Out-Null
$ErrorActionPreference='Continue'
& npm.cmd install --global --prefix $Prefix '@openai/codex@0.154.0' --registry https://registry.npmjs.org --ignore-scripts --no-audit --no-fund
$installCode=$LASTEXITCODE
if($installCode -ne 0){exit $installCode}
$ErrorActionPreference='Stop'
if(!(Test-Path -LiteralPath $target)){throw 'npm hoàn tất nhưng chưa có codex.cmd.'}
& $target --version
if($LASTEXITCODE -ne 0){exit $LASTEXITCODE}
Write-Output 'CLI_INSTALLED'
exit 0
