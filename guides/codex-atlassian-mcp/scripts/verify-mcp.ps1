param([Parameter(Mandatory)][string]$Prefix)
$ErrorActionPreference='Stop'
$launcher=Join-Path $Prefix 'launch-codex.ps1'
if(!(Test-Path -LiteralPath $launcher)){throw 'Chưa có launcher Codex của EasyAI.'}
$smoke=Join-Path $Prefix ('mcp-smoke-'+[Guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $smoke | Out-Null
Push-Location $smoke
try {
  # Only this read-only tool is available from Atlassian during verification.
  # Capture events in memory: site names/content must not enter EasyAI logs.
  $events=& ([scriptblock]::Create([IO.File]::ReadAllText($launcher))) exec --json --skip-git-repo-check --sandbox read-only --ephemeral -c 'mcp_servers.atlassian.enabled_tools=["getAccessibleAtlassianResources"]' -c 'mcp_servers.atlassian.required=true' 'Call atlassian getAccessibleAtlassianResources exactly once to verify authentication. Do not use any other tools. Do not modify anything. Do not include site names, URLs or account data in your reply; say only whether the tool succeeded.'
  if($LASTEXITCODE -ne 0){throw 'Codex không hoàn tất kiểm chứng MCP.'}
  $verified=$false
  foreach($line in $events) {
    try { $event=[string]$line | ConvertFrom-Json -ErrorAction Stop } catch { continue }
    $item=$event.item
    if($event.type -eq 'item.completed' -and $item.type -eq 'mcp_tool_call' -and $item.server -eq 'atlassian' -and $item.tool -eq 'getAccessibleAtlassianResources' -and $item.status -eq 'completed' -and $null -ne $item.result -and $item.result.isError -ne $true -and $null -eq $item.error){$verified=$true}
  }
  if(!$verified){throw 'Chưa có bằng chứng tool getAccessibleAtlassianResources thành công. Kiểm tra OAuth/quyền site; không chấp nhận câu trả lời AI làm bằng chứng.'}
} finally { Pop-Location }
Write-Output 'EASYAI_ATLASSIAN_MCP_READY'
exit 0
