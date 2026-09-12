param(
  [Parameter(Mandatory)][string]$Prefix,
  [string]$ShortcutDirectory=[Environment]::GetFolderPath('Programs'),
  [string]$RuntimePath=$env:EASYAI_RUNTIME_PATH
)
$ErrorActionPreference='Stop'
$target=Join-Path $env:USERPROFILE '.local/bin/claude.exe'
if(!(Test-Path -LiteralPath $target)){throw 'Chưa có Claude native CLI. Chọn Cài đặt.'}
New-Item -ItemType Directory -Force -Path $Prefix | Out-Null
$bashPath=''
$git=Get-Command git.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
if($git) {
  $gitRoot=Split-Path (Split-Path $git.Source -Parent) -Parent
  foreach($relative in @('bin/bash.exe','usr/bin/bash.exe')) {
    $candidate=Join-Path $gitRoot $relative
    if(Test-Path -LiteralPath $candidate){$bashPath=$candidate; break}
  }
}
$launcher=Join-Path $Prefix 'launch-claude.ps1'
$body=@'
$previousPath=$env:PATH
$previousBash=$env:CLAUDE_CODE_GIT_BASH_PATH
try {
  $env:PATH='__RUNTIME_PATH__'+';'+$env:PATH
  if('__BASH__'){$env:CLAUDE_CODE_GIT_BASH_PATH='__BASH__'}
  & '__TARGET__' @args
  if($LASTEXITCODE -ne 0){throw ('Claude kết thúc với mã lỗi '+$LASTEXITCODE)}
} finally {
  $env:PATH=$previousPath
  $env:CLAUDE_CODE_GIT_BASH_PATH=$previousBash
}
'@
$body=$body.Replace('__TARGET__',$target.Replace("'","''")).Replace('__RUNTIME_PATH__',$RuntimePath.Replace("'","''")).Replace('__BASH__',$bashPath.Replace("'","''"))
if(Test-Path -LiteralPath $launcher){Copy-Item -LiteralPath $launcher -Destination ($launcher+'.backup-'+[Guid]::NewGuid().ToString())}
[IO.File]::WriteAllText($launcher,$body,[Text.UTF8Encoding]::new($true))
New-Item -ItemType Directory -Force -Path $ShortcutDirectory | Out-Null
$shortcut=Join-Path $ShortcutDirectory 'Claude Code (EasyAI).lnk'
if(Test-Path -LiteralPath $shortcut){Copy-Item -LiteralPath $shortcut -Destination ($shortcut+'.backup-'+[Guid]::NewGuid().ToString())}
$entry="& ([scriptblock]::Create([IO.File]::ReadAllText('"+$launcher.Replace("'","''")+"')))"
$shell=(New-Object -ComObject WScript.Shell).CreateShortcut($shortcut)
$shell.TargetPath=Join-Path $env:SystemRoot 'System32/WindowsPowerShell/v1.0/powershell.exe'
$shell.Arguments='-NoLogo -NoProfile -NoExit -EncodedCommand '+[Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($entry))
$shell.WorkingDirectory=$Prefix
$shell.Description='Claude Code CLI với runtime EasyAI'
$shell.Save()
Write-Output ('Launcher: '+$launcher)
exit 0
