param([Parameter(Mandatory)][string]$Prefix)
$ErrorActionPreference='Stop'
# Read-only diagnosis: no download, reinstall, provider call or config change.
foreach($requirement in @(@{Name='git.exe'; Minimum=[version]'2.40.0'},@{Name='node.exe'; Minimum=[version]'22.0.0'})) {
  $command=Get-Command $requirement.Name -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
  if(!$command){throw ('Không tìm thấy '+$requirement.Name+'. Chọn Cài đặt/Sửa lỗi để phục hồi runtime.')}
  $version=& $command.Source --version
  if($LASTEXITCODE -ne 0 -or "$version" -notmatch '(\d+\.\d+\.\d+)' -or [version]$Matches[1] -lt $requirement.Minimum){throw ('Phiên bản không đạt: '+$requirement.Name)}
  Write-Output ($requirement.Name+': '+$version)
}
$target=Join-Path $Prefix 'codex.cmd'
if(!(Test-Path -LiteralPath $target)){throw 'Chưa cài Codex trong vùng EasyAI. Chọn Cài đặt.'}
$version=& $target --version
if($LASTEXITCODE -ne 0 -or "$version" -notmatch 'codex-cli \d+'){throw 'Codex CLI không chạy được.'}
foreach($relative in @('launch-codex.ps1','home/config.toml','home/credentials.dpapi')) {
  if(!(Test-Path -LiteralPath (Join-Path $Prefix $relative))){throw ('Thiếu file quản lý: '+$relative)}
}
Write-Output ('Codex: '+$version)
Write-Output 'EASYAI_CODEX_DOCTOR_OK'
exit 0
