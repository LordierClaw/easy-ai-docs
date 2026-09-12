param([Parameter(Mandatory)][string]$Prefix)
$ErrorActionPreference='Stop'
# Preserve PATH injected by the runtime resolver, including bundled tools.
$git=& git.exe --version
if($LASTEXITCODE -ne 0 -or "$git" -notmatch '(\d+\.\d+\.\d+)' -or [version]$Matches[1] -lt [version]'2.40.0'){throw 'Git cần phiên bản 2.40 trở lên.'}
$node=& node.exe --version
if($LASTEXITCODE -ne 0 -or "$node" -notmatch '(\d+\.\d+\.\d+)' -or [version]$Matches[1] -lt [version]'22.0.0'){throw 'Node.js cần phiên bản 22 trở lên.'}
$target=Join-Path $Prefix 'codex.cmd'
$version=& $target --version
if($LASTEXITCODE -ne 0 -or "$version" -notmatch 'codex-cli \d+'){throw 'Không xác minh được phiên bản Codex CLI.'}
$launcher=Join-Path $Prefix 'launch-codex.ps1'
if(!(Test-Path -LiteralPath $launcher)){throw 'Chưa có launcher Codex (EasyAI).'}
$smoke=Join-Path $Prefix ('smoke-'+[Guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $smoke | Out-Null
$answer=Join-Path $smoke 'answer.txt'
Push-Location $smoke
try {
  & ([scriptblock]::Create([IO.File]::ReadAllText($launcher))) exec --skip-git-repo-check --sandbox read-only --ephemeral --output-last-message $answer 'Do not use tools or read files. Reply exactly EASYAI_OK.'
  if(!(Test-Path -LiteralPath $answer)){throw 'Provider chưa trả lời: không có file kết quả smoke test.'}
  if([IO.File]::ReadAllText($answer).Trim() -cne 'EASYAI_OK'){throw 'Provider trả lời sai nội dung kiểm chứng EASYAI_OK.'}
} finally { Pop-Location }
Write-Output ('Verified: '+$git+'; '+$node+'; '+$version)
Write-Output 'EASYAI_CODEX_READY'
exit 0
