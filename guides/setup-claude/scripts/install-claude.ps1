param([Parameter(Mandatory)][string]$Prefix)
$ErrorActionPreference='Stop'
$target=Join-Path $env:USERPROFILE '.local/bin/claude.exe'
if(Test-Path -LiteralPath $target) {
  $version=& $target --version
  if($LASTEXITCODE -eq 0 -and "$version" -match 'Claude Code'){Write-Output ('CLAUDE_REUSED: '+$version); exit 0}
  throw 'CLI native đã tồn tại nhưng không chạy được. Giữ file và chẩn đoán trước khi cài đè.'
}
New-Item -ItemType Directory -Force -Path $Prefix | Out-Null
$installer=Join-Path $Prefix 'anthropic-install.ps1'
$expected='cd17c6b555f761d60373659824bf805e1510538226e4c7028e19d7494937a333'
Invoke-WebRequest -Uri 'https://claude.ai/install.ps1' -OutFile $installer -UseBasicParsing
if((Get-FileHash -LiteralPath $installer -Algorithm SHA256).Hash.ToLowerInvariant() -ne $expected){throw 'Bootstrap Anthropic đã thay đổi SHA-256. Cần cập nhật và publish guide sau khi xem xét; chưa chạy installer.'}
# Isolate upstream exit statements, preserving PATH without changing machine policy.
$entry="& ([scriptblock]::Create([IO.File]::ReadAllText('"+$installer.Replace("'","''")+"'))) -Target stable"
$powershell=Join-Path $env:SystemRoot 'System32/WindowsPowerShell/v1.0/powershell.exe'
& $powershell -NoLogo -NoProfile -NonInteractive -EncodedCommand ([Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($entry)))
if($LASTEXITCODE -ne 0){throw 'Installer Anthropic thất bại. Xem mã lỗi và output.'}
if(!(Test-Path -LiteralPath $target)){throw 'Installer kết thúc nhưng chưa có Claude CLI native.'}
$version=& $target --version
if($LASTEXITCODE -ne 0 -or "$version" -notmatch 'Claude Code'){throw 'Không xác minh được Claude Code sau cài.'}
Write-Output ('CLAUDE_INSTALLED: '+$version)
exit 0
