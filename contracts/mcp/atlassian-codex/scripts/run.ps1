. (Join-Path $PSScriptRoot 'common.ps1')
$cli=Join-Path $Prefix 'codex.cmd'
if($Context.action -eq 'doctor') {
  Write-Output 'DIAGNOSIS (read-only): Atlassian MCP'
  if(!(Test-Path -LiteralPath $cli)){Write-Output 'Codex missing; run /ai/codex install.';exit 0}
  $previousHome=$env:CODEX_HOME
  try {
    $env:CODEX_HOME=Join-Path $Prefix 'home'
    $json=& $cli mcp get atlassian --json 2>&1
    if($LASTEXITCODE -ne 0){Write-Output 'MCP configuration missing or invalid.';exit 0}
    $server=($json -join "`n") | ConvertFrom-Json
    Write-Output ('Configuration valid='+($server.transport.url -eq 'https://mcp.atlassian.com/v2/mcp' -and $server.enabled -ne $false)+'; OAuth and site permissions not tested by doctor.')
  } finally {$env:CODEX_HOME=$previousHome}
  exit 0
}
if($Context.action -notin @('install','configure','repair','auth')){throw 'Unsupported action.'}
if(!(Test-Path -LiteralPath $cli) -or !(Test-Path -LiteralPath (Join-Path $Prefix 'launch-codex.ps1'))){Stop-Contract 'codex.missing' 'Hoàn thành hợp đồng Codex trước.' @{type='contract';ref='/ai/codex';action='install';resume='retry'}}
Require-Runtime 'node' '22.0.0' '/.shared/nodejs'
exit 0
