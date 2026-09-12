param(
  [Parameter(Mandatory)][string]$Prefix,
  [string]$ShortcutDirectory=[Environment]::GetFolderPath('Programs'),
  [string]$RuntimePath=$env:EASYAI_RUNTIME_PATH
)
$ErrorActionPreference='Stop'
$cli=Join-Path $Prefix 'codex.cmd'
$codexHome=Join-Path $Prefix 'home'
$config=Join-Path $codexHome 'config.toml'
if(!(Test-Path -LiteralPath $cli) -or !(Test-Path -LiteralPath $config)){throw 'Hoàn thành guide Cài đặt Codex của EasyAI trước.'}
$previousCodexHome=$env:CODEX_HOME
$env:CODEX_HOME=$codexHome
try {
  # Let Codex validate TOML rather than attempting an incomplete TOML parser.
  $json=& $cli mcp list --json
  if($LASTEXITCODE -ne 0){throw 'Codex không đọc được config.toml. Giữ nguyên file để xử lý.'}
  $servers=@(($json -join "`n") | ConvertFrom-Json)
  $existing=@($servers | Where-Object name -eq 'atlassian')
  if($existing.Count -gt 0) {
    if($existing[0].transport.url -ne 'https://mcp.atlassian.com/v2/mcp' -or $existing[0].enabled -eq $false){throw 'Server atlassian đã tồn tại nhưng URL/trạng thái khác. Cần kế hoạch sửa có backup, không ghi đè tự động.'}
    Write-Output 'MCP_CONFIG_REUSED'
  } else {
    Copy-Item -LiteralPath $config -Destination ($config+'.backup-'+[Guid]::NewGuid().ToString())
    # codex mcp add can start OAuth immediately; register the table here and
    # leave the browser login to an explicit userConfirmation step.
    $block="`r`n[mcp_servers.atlassian]`r`nurl = `"https://mcp.atlassian.com/v2/mcp`"`r`n"
    [IO.File]::AppendAllText($config,$block,[Text.UTF8Encoding]::new($false))
    $registered=& $cli mcp get atlassian --json
    if($LASTEXITCODE -ne 0){throw 'Không xác minh được cấu hình MCP mới. Đã giữ bản backup.'}
    $server=($registered -join "`n") | ConvertFrom-Json
    if($server.transport.url -ne 'https://mcp.atlassian.com/v2/mcp'){throw 'URL MCP sau ghi không đúng.'}
    Write-Output 'MCP_CONFIG_CREATED'
  }
} finally { $env:CODEX_HOME=$previousCodexHome }

$login=Join-Path $Prefix 'login-atlassian.ps1'
$body=@'
$ErrorActionPreference='Stop'
$previousCodexHome=$env:CODEX_HOME
$previousPath=$env:PATH
try {
  $env:CODEX_HOME='__HOME__'
  $env:PATH='__RUNTIME_PATH__'+';'+$env:PATH
  & '__CLI__' mcp login atlassian
  if($LASTEXITCODE -ne 0){throw 'Đăng nhập Atlassian chưa thành công. Xem thông báo ở trên.'}
  Write-Output 'Đăng nhập xong. Quay lại EasyAI và xác nhận để kiểm chứng kết nối.'
} finally {
  $env:CODEX_HOME=$previousCodexHome
  $env:PATH=$previousPath
}
'@
$body=$body.Replace('__HOME__',$codexHome.Replace("'","''")).Replace('__CLI__',$cli.Replace("'","''")).Replace('__RUNTIME_PATH__',$RuntimePath.Replace("'","''"))
if(Test-Path -LiteralPath $login){Copy-Item -LiteralPath $login -Destination ($login+'.backup-'+[Guid]::NewGuid().ToString())}
[IO.File]::WriteAllText($login,$body,[Text.UTF8Encoding]::new($true))
New-Item -ItemType Directory -Force -Path $ShortcutDirectory | Out-Null
$shortcut=Join-Path $ShortcutDirectory 'Codex - Atlassian Login.lnk'
if(Test-Path -LiteralPath $shortcut){Copy-Item -LiteralPath $shortcut -Destination ($shortcut+'.backup-'+[Guid]::NewGuid().ToString())}
$entry="& ([scriptblock]::Create([IO.File]::ReadAllText('"+$login.Replace("'","''")+"')))"
$shell=(New-Object -ComObject WScript.Shell).CreateShortcut($shortcut)
$shell.TargetPath=Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$shell.Arguments='-NoLogo -NoProfile -NoExit -EncodedCommand '+[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($entry))
$shell.WorkingDirectory=$Prefix
$shell.Description='Đăng nhập OAuth Atlassian cho Codex do EasyAI quản lý'
$shell.Save()
Write-Output ('Mở Start Menu → Codex - Atlassian Login. Launcher: '+$login)
exit 0
