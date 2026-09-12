param(
  [Parameter(Mandatory)][string]$Prefix,
  [string]$ShortcutDirectory=[Environment]::GetFolderPath('Programs'),
  [string]$RuntimePath=$env:EASYAI_RUNTIME_PATH
)
$ErrorActionPreference='Stop'
$target=Join-Path $Prefix 'codex.cmd'
if(!(Test-Path -LiteralPath $target)){throw 'Codex CLI chưa được cài tại prefix đã duyệt.'}
$codexHome=Join-Path $Prefix 'home'
if(!(Test-Path -LiteralPath (Join-Path $codexHome 'config.toml'))){throw 'Chưa cấu hình custom provider EasyAI.'}
if(!(Test-Path -LiteralPath (Join-Path $codexHome 'credentials.dpapi'))){throw 'Chưa có khóa provider được Windows bảo vệ.'}
$launcher=Join-Path $Prefix 'launch-codex.ps1'
$body=@'
$ErrorActionPreference='Stop'
$p=Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -ErrorAction SilentlyContinue
if($p.AutoConfigURL){throw 'PAC chưa được hỗ trợ. Nhờ IT cung cấp proxy cố định.'}
$previousPath=$env:PATH
$runtimePath='__RUNTIME_PATH__'
$env:PATH=$runtimePath+';'+$env:PATH+';'+[Environment]::GetEnvironmentVariable('Path','Machine')+';'+[Environment]::GetEnvironmentVariable('Path','User')
$env:ALL_PROXY=$null; $env:HTTP_PROXY=$null; $env:HTTPS_PROXY=$null
if($p.ProxyEnable -and $p.ProxyServer){
  $s=[string]$p.ProxyServer
  if($s.Contains('=')){$h=@($s.Split(';') | Where-Object {$_ -like 'https=*'})[0]; if(!$h){throw 'Thiếu proxy HTTPS.'}; $s=$h.Substring(6)}
  if($s -notmatch '^https?://'){$s='http://'+$s}
  $env:HTTP_PROXY=$s; $env:HTTPS_PROXY=$s
}
$b=([string]$p.ProxyOverride).Replace(';',',').Replace('<local>','localhost,127.0.0.1,::1')
$env:NO_PROXY='localhost,127.0.0.1,::1,'+$b
$previousCodexHome=$env:CODEX_HOME
$previousProviderKey=$env:EASYAI_CODEX_API_KEY
$protectedCredential=[IO.File]::ReadAllText('__CREDENTIAL__') | ConvertTo-SecureString
$pointer=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($protectedCredential)
try {
  $env:CODEX_HOME='__HOME__'
  [Environment]::SetEnvironmentVariable('EASYAI_CODEX_API_KEY',[Runtime.InteropServices.Marshal]::PtrToStringBSTR($pointer),'Process')
  & '__TARGET__' @args
  $result=$LASTEXITCODE
} finally {
  [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($pointer)
  [Environment]::SetEnvironmentVariable('EASYAI_CODEX_API_KEY',$previousProviderKey,'Process')
  $env:CODEX_HOME=$previousCodexHome
  $env:PATH=$previousPath
}
if($result -ne 0){throw ('Codex kết thúc với mã lỗi '+$result)}
'@
$body=$body.Replace('__TARGET__',$target.Replace("'","''")).Replace('__HOME__',$codexHome.Replace("'","''")).Replace('__CREDENTIAL__',(Join-Path $codexHome 'credentials.dpapi').Replace("'","''")).Replace('__RUNTIME_PATH__',$RuntimePath.Replace("'","''"))
if(Test-Path -LiteralPath $launcher){Copy-Item -LiteralPath $launcher -Destination ($launcher+'.backup-'+[Guid]::NewGuid().ToString())}
[IO.File]::WriteAllText($launcher,$body,[Text.UTF8Encoding]::new($true))
New-Item -ItemType Directory -Force -Path $ShortcutDirectory | Out-Null
$shortcut=Join-Path $ShortcutDirectory 'Codex (EasyAI).lnk'
if(Test-Path -LiteralPath $shortcut){Copy-Item -LiteralPath $shortcut -Destination ($shortcut+'.backup-'+[Guid]::NewGuid().ToString())}
$entry="& ([scriptblock]::Create([IO.File]::ReadAllText('"+$launcher.Replace("'","''")+"')))"
$s=(New-Object -ComObject WScript.Shell).CreateShortcut($shortcut)
$s.TargetPath=Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$s.Arguments='-NoLogo -NoProfile -NoExit -EncodedCommand '+[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($entry))
$s.WorkingDirectory=$Prefix
$s.Description='Codex CLI dùng cùng model và provider với EasyAI'
$s.Save()
Write-Output ('Launcher: '+$launcher)
Write-Output ('Shortcut: '+$shortcut)
exit 0
