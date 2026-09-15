. (Join-Path $PSScriptRoot 'common.ps1')
$target=Join-Path $Prefix 'welcome.txt'
if($Context.action -eq 'doctor') {
  $healthy=(Test-Path -LiteralPath $target) -and [IO.File]::ReadAllText($target) -ceq 'EASYAI_OK'
  Write-Output ('DIAGNOSIS: welcome.txt valid='+$healthy)
  exit 0
}
if($Context.action -notin @('run','install','repair')){throw 'Unsupported action.'}
Write-StagedText $target 'EASYAI_OK'
if([IO.File]::ReadAllText($target) -cne 'EASYAI_OK'){throw 'Workspace note verification failed.'}
Write-Output 'EASYAI_NOTE_READY'
exit 0
