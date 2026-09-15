. (Join-Path $PSScriptRoot 'common.ps1')
if($Context.action -eq 'doctor'){exit 0}
if(!$Context.input.authenticated){Stop-Contract 'mcp.login' 'Mở Codex - Atlassian Login trong Start Menu để đăng nhập OAuth.' $null @{type='confirm';key='authenticated';message='Hoàn tất đăng nhập Atlassian rồi tiếp tục. EasyAI sẽ kiểm chứng bằng một lời gọi MCP chỉ đọc.'}}
try {Invoke-ContractStep 'verify-mcp.ps1'} catch {Stop-Contract 'mcp.auth' 'Chưa có sự kiện MCP thành công. Kiểm tra OAuth và quyền site rồi thử lại.' $null @{type='confirm';key='authenticated';message='Đăng nhập lại bằng Codex - Atlassian Login rồi tiếp tục để kiểm chứng thật.'}}
exit 0
