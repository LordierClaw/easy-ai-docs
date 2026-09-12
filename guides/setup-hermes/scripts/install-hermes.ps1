param([Parameter(Mandatory)][string]$Prefix)
$ErrorActionPreference='Stop'
$source=Join-Path $Prefix 'source'
$venv=Join-Path $Prefix 'venv'
$target=Join-Path $venv 'Scripts/hermes.exe'
$commit='a84a2223f82c3d9906fd4a9d778a188774e7a08e'
$uvDirectory=Join-Path $Prefix 'uv'
$uv=Join-Path $uvDirectory 'uv.exe'
if(Test-Path -LiteralPath $target) {
  $version=& $target --version
  if($LASTEXITCODE -eq 0 -and "$version" -match 'Hermes'){Write-Output ('HERMES_REUSED: '+$version); exit 0}
  throw 'Hermes đã có nhưng CLI lỗi. Giữ dữ liệu để chẩn đoán, không cài đè.'
}
if(!(Get-Command git.exe -CommandType Application -ErrorAction SilentlyContinue)){throw 'Thiếu Git từ ensure_runtime.'}
New-Item -ItemType Directory -Force -Path $Prefix | Out-Null
if(!(Test-Path -LiteralPath $uv)) {
  $archive=Join-Path $Prefix 'uv-0.12.13-windows-x64.zip'
  Invoke-WebRequest -Uri 'https://github.com/astral-sh/uv/releases/download/0.12.13/uv-x86_64-pc-windows-msvc.zip' -OutFile $archive -UseBasicParsing
  if((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant() -ne 'a86c9dc7bad9b03f388583b7187c05fe9951c2e0d392217e8fd43d97787f6ec2'){throw 'Hash uv không đúng; chưa giải nén/chạy.'}
  Expand-Archive -LiteralPath $archive -DestinationPath $uvDirectory -Force
}
if(!(Test-Path -LiteralPath $uv)){throw 'Archive uv không có uv.exe theo cấu trúc đã khai báo.'}
if(Test-Path -LiteralPath $source) {
  if(!(Test-Path -LiteralPath (Join-Path $source '.git'))){throw 'Thư mục source dở dang hoặc không phải Git. Không xóa tự động.'}
  $head=& git.exe -C $source rev-parse HEAD
  if($LASTEXITCODE -ne 0 -or "$head".Trim() -ne $commit){throw 'Checkout Hermes không khớp commit đã ghim. Không reset tự động.'}
  $changes=& git.exe -C $source status --porcelain
  if($LASTEXITCODE -ne 0 -or $changes){throw 'Checkout Hermes có thay đổi hoặc không đọc được. Giữ nguyên để đánh giá.'}
} else {
  & git.exe init $source
  if($LASTEXITCODE -ne 0){throw 'Không tạo được checkout Hermes.'}
  & git.exe -C $source remote add origin 'https://github.com/NousResearch/hermes-agent.git'
  if($LASTEXITCODE -ne 0){throw 'Không cấu hình được origin Hermes.'}
  & git.exe -C $source fetch --depth 1 origin $commit
  if($LASTEXITCODE -ne 0){throw 'Không tải được commit Hermes.'}
  & git.exe -C $source checkout --detach FETCH_HEAD
  if($LASTEXITCODE -ne 0){throw 'Không checkout được Hermes.'}
}
$previousPythonInstall=$env:UV_PYTHON_INSTALL_DIR
$previousCache=$env:UV_CACHE_DIR
$previousHermesHome=$env:HERMES_HOME
try {
  $env:UV_PYTHON_INSTALL_DIR=Join-Path $Prefix 'python'
  $env:UV_CACHE_DIR=Join-Path $Prefix 'cache'
  $env:HERMES_HOME=Join-Path $Prefix 'home'
  & $uv venv --python 3.11 $venv
  if($LASTEXITCODE -ne 0){throw 'Không tạo được Python 3.11/venv riêng.'}
  $python=Join-Path $venv 'Scripts/python.exe'
  & $uv pip install --python $python --editable ($source+'[mcp]')
  if($LASTEXITCODE -ne 0){throw 'Cài package Hermes chưa thành công. Giữ output để sửa dependency.'}
  if(!(Test-Path -LiteralPath $target)){throw 'Chưa có hermes.exe sau cài.'}
  $version=& $target --version
  if($LASTEXITCODE -ne 0 -or "$version" -notmatch 'Hermes'){throw 'Hermes CLI không chạy được sau cài.'}
  Write-Output ('HERMES_INSTALLED: '+$version)
} finally {
  $env:UV_PYTHON_INSTALL_DIR=$previousPythonInstall
  $env:UV_CACHE_DIR=$previousCache
  $env:HERMES_HOME=$previousHermesHome
}
exit 0
