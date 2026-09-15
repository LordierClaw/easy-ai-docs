. (Join-Path $PSScriptRoot 'common.ps1')
if($Context.action -in @('doctor','auth')){exit 0}
$model=$env:EASYAI_PROVIDER_MODEL
$baseUrl=$env:EASYAI_PROVIDER_URL
if(!$model -or !$baseUrl -or !$env:EASYAI_PROVIDER_SECRET){Stop-Contract 'provider.missing' 'Cấu hình khóa provider trong EasyAI rồi thử lại. Không nhập khóa vào hội thoại.' @{type='message';message='Cấu hình provider.json hoặc EASYAI_PROVIDER_* theo README rồi thử lại.'}}
if($model -match '[\r\n\x00]' -or $baseUrl -match '[\r\n\x00]' -or $baseUrl -notmatch '^https?://'){throw 'Invalid public provider settings.'}
function Toml-String([string]$value){return '"'+$value.Replace('\','\\').Replace('"','\"')+'"'}
$codexHome=Join-Path $Prefix 'home'
$config=Join-Path $codexHome 'config.toml'
$previous=''
if(Test-Path -LiteralPath $config){
  $previous=[IO.File]::ReadAllText($config)
  $originalHome=$env:CODEX_HOME
  try {
    $env:CODEX_HOME=$codexHome
    $null=& (Join-Path $Prefix 'codex.cmd') mcp list --json
    if($LASTEXITCODE -ne 0){throw 'Existing TOML is invalid; preserved for diagnosis.'}
  } finally {$env:CODEX_HOME=$originalHome}
}
# Preserve unrelated tables. Refuse complex inline/quoted managed declarations instead of guessing.
if($previous -match '(?m)^\s*(model_providers\s*=|["''](?:model|model_provider|profile|openai_base_url|chatgpt_base_url)["'']\s*=|\[\s*["'']model_providers)'){throw 'Managed TOML uses an unsupported inline/quoted declaration. Existing file preserved.'}
$lines=New-Object 'Collections.Generic.List[string]'
$inManaged=$false
$inRoot=$true
foreach($line in ($previous -split '\r?\n')) {
  if($line -match '^\s*\['){$inRoot=$false; $inManaged=($line -match '^\s*\[model_providers\.easyai(?:\]|\.)')}
  if($inManaged){continue}
  if($inRoot -and $line -match '^\s*(model|model_provider|profile|openai_base_url|chatgpt_base_url)\s*='){continue}
  $lines.Add($line)
}
$text='model = '+(Toml-String $model)+"`r`nmodel_provider = `"easyai`"`r`n"+(($lines -join "`r`n").Trim())+"`r`n[model_providers.easyai]`r`nname = `"EasyAI`"`r`nbase_url = "+(Toml-String $baseUrl)+"`r`nwire_api = `"responses`"`r`nenv_key = `"EASYAI_CODEX_API_KEY`"`r`nrequires_openai_auth = false`r`nrequest_max_retries = 2`r`nstream_max_retries = 2`r`n"
$stage=Join-Path $Context.paths.attempt ('provider-'+[Guid]::NewGuid().ToString('N'))
[IO.Directory]::CreateDirectory($stage) | Out-Null
[IO.File]::WriteAllText((Join-Path $stage 'config.toml'),$text,[Text.UTF8Encoding]::new($false))
$oldHome=$env:CODEX_HOME
try {
  $env:CODEX_HOME=$stage
  $null=& (Join-Path $Prefix 'codex.cmd') mcp list --json
  if($LASTEXITCODE -ne 0){throw 'Codex rejected the staged provider TOML; existing configuration preserved.'}
} finally {$env:CODEX_HOME=$oldHome}
if((Test-Path -LiteralPath $config) -and [IO.File]::ReadAllText($config) -cne $previous){throw 'Configuration changed during validation; retry.'}
$secure=ConvertTo-SecureString $env:EASYAI_PROVIDER_SECRET -AsPlainText -Force
$encrypted=ConvertFrom-SecureString $secure
# Verify DPAPI before publishing either file, never write the plaintext key.
$null=ConvertTo-SecureString $encrypted
Write-StagedText (Join-Path $codexHome 'credentials.dpapi') $encrypted
Write-StagedText $config $text
Write-Output 'PROVIDER_CONFIGURED (Windows DPAPI)'
exit 0
