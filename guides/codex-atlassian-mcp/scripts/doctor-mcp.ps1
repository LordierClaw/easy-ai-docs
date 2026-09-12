param([Parameter(Mandatory)][string]$Prefix)
$ErrorActionPreference='Stop'
$cli=Join-Path $Prefix 'codex.cmd'
if(!(Test-Path -LiteralPath $cli)){throw 'Chưa có Codex do EasyAI quản lý.'}
$previousCodexHome=$env:CODEX_HOME
$env:CODEX_HOME=Join-Path $Prefix 'home'
try {
  $json=& $cli mcp get atlassian --json
  if($LASTEXITCODE -ne 0){throw 'Chưa đăng ký Atlassian MCP hoặc config.toml không hợp lệ.'}
  $server=($json -join "`n") | ConvertFrom-Json
  if($server.transport.url -ne 'https://mcp.atlassian.com/v2/mcp' -or $server.enabled -eq $false){throw 'Atlassian MCP đang tắt hoặc URL không đúng.'}
  Write-Output 'MCP_CONFIG_OK (chưa kiểm chứng OAuth hoặc quyền truy cập site)'
} finally { $env:CODEX_HOME=$previousCodexHome }
exit 0
