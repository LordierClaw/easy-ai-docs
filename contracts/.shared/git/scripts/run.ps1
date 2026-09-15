. (Join-Path $PSScriptRoot 'common.ps1')
. (Join-Path $PSScriptRoot 'runtime.ps1')
if($Context.action -notin @('ensure','doctor')){throw 'Unsupported runtime action.'}
$artifact=[IO.File]::ReadAllText((Join-Path $PSScriptRoot '../resources/artifact.json')) | ConvertFrom-Json
try {Resolve-ContractRuntime $Context $artifact} catch {
  Write-Output ('Runtime diagnostic: '+$_.Exception.Message)
  Stop-Contract 'runtime.unavailable' 'Không thể xác minh runtime. Xem nguồn tải, kết nối và bộ nhớ đệm; chưa dùng file không đạt kiểm chứng.' @{type='choice';options=@(@{label='Hỗ trợ mạng';ref='/requests/network-access';resume='stop'},@{label='Hỗ trợ cài đặt';ref='/requests/installation-support';resume='stop'})}
}
exit 0
