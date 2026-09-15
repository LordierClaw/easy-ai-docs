. (Join-Path $PSScriptRoot 'common.ps1')
if($Context.action -eq 'doctor'){exit 0}
$target=Join-Path $env:USERPROFILE '.local/bin/claude.exe'
# A reply in chat is never authentication evidence.
$null=& $target auth status 2>&1
if($LASTEXITCODE -ne 0){Stop-Contract 'claude.auth' 'Mở Claude Code (EasyAI) và hoàn thành đăng nhập chính thức.' $null @{type='confirm';key='authenticated';message='Hoàn thành đăng nhập Claude Code rồi tiếp tục để kiểm tra trạng thái thật.'}}

exit 0
