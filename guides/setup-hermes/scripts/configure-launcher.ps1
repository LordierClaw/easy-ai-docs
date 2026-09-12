param(
  [Parameter(Mandatory)][string]$Prefix,
  [string]$ShortcutDirectory=[Environment]::GetFolderPath('Programs'),
  [string]$RuntimePath=$env:EASYAI_RUNTIME_PATH
)
$ErrorActionPreference='Stop'
$target=Join-Path $Prefix 'venv/Scripts/hermes.exe'
if(!(Test-Path -LiteralPath $target)){throw 'Chưa có Hermes CLI do EasyAI quản lý.'}
$hermesHome=Join-Path $Prefix 'home'
New-Item -ItemType Directory -Force -Path $hermesHome | Out-Null
$launcher=Join-Path $Prefix 'launch-hermes.ps1'
$body=@'
$previousPath=$env:PATH
$previousHermesHome=$env:HERMES_HOME
try {
  $env:PATH='__RUNTIME_PATH__'+';'+$env:PATH
  $env:HERMES_HOME='__HOME__'
  & '__TARGET__' @args
  if($LASTEXITCODE -ne 0){throw ('Hermes kết thúc với mã lỗi '+$LASTEXITCODE)}
} finally {
  $env:PATH=$previousPath
  $env:HERMES_HOME=$previousHermesHome
}
'@
$body=$body.Replace('__TARGET__',$target.Replace("'","''")).Replace('__HOME__',$hermesHome.Replace("'","''")).Replace('__RUNTIME_PATH__',$RuntimePath.Replace("'","''"))
if(Test-Path -LiteralPath $launcher){Copy-Item -LiteralPath $launcher -Destination ($launcher+'.backup-'+[Guid]::NewGuid().ToString())}
[IO.File]::WriteAllText($launcher,$body,[Text.UTF8Encoding]::new($true))
New-Item -ItemType Directory -Force -Path $ShortcutDirectory | Out-Null
foreach($item in @(@{Name='Hermes Agent (EasyAI)';Command=''},@{Name='Hermes - Setup';Command=' setup'})) {
  $shortcut=Join-Path $ShortcutDirectory ($item.Name+'.lnk')
  if(Test-Path -LiteralPath $shortcut){Copy-Item -LiteralPath $shortcut -Destination ($shortcut+'.backup-'+[Guid]::NewGuid().ToString())}
  $entry="& ([scriptblock]::Create([IO.File]::ReadAllText('"+$launcher.Replace("'","''")+"')))"+$item.Command
  $shell=(New-Object -ComObject WScript.Shell).CreateShortcut($shortcut)
  $shell.TargetPath=Join-Path $env:SystemRoot 'System32/WindowsPowerShell/v1.0/powershell.exe'
  $shell.Arguments='-NoLogo -NoProfile -NoExit -EncodedCommand '+[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($entry))
  $shell.WorkingDirectory=$Prefix
  $shell.Description='Hermes Agent của Nous Research trong vùng EasyAI'
  $shell.Save()
}
Write-Output ('Launcher: '+$launcher)
exit 0
