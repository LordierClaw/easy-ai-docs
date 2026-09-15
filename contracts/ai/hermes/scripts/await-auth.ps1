. (Join-Path $PSScriptRoot 'common.ps1')
if($Context.action -eq 'doctor'){exit 0}
$target=Join-Path $Prefix 'venv/Scripts/hermes.exe'
$ready=$false
if(Test-Path -LiteralPath (Join-Path $Prefix 'home/config.yaml')) {
  $oldHome=$env:HERMES_HOME
  try {$env:HERMES_HOME=Join-Path $Prefix 'home';$null=& $target config check 2>&1;$ready=($LASTEXITCODE -eq 0)} finally {$env:HERMES_HOME=$oldHome}
}
if(!$ready){Stop-Contract 'hermes.setup' 'Mở Hermes - Setup và cấu hình provider/model trong công cụ.' $null @{type='confirm';key='configured';message='Hoàn thành Hermes Setup rồi tiếp tục để kiểm tra cấu hình thật.'}}

exit 0
