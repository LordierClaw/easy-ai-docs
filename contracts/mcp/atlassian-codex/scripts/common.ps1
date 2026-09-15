$ErrorActionPreference='Stop'
function Get-ContractContext {
  if(!$env:EASYAI_CONTEXT_PATH){throw 'EASYAI_CONTEXT_PATH is required.'}
  $context=[IO.File]::ReadAllText($env:EASYAI_CONTEXT_PATH) | ConvertFrom-Json
  foreach($name in @('workspace','shared','attempt','contract')) {
    if(![IO.Path]::IsPathRooted([string]$context.paths.$name)){throw ('Invalid context path: '+$name)}
  }
  return $context
}
function Stop-Contract($Code,$Message,$Fallback=$null,$Wait=$null) {
  $problem=@{code=$Code;message=$Message}
  if($Fallback){$problem.fallback=$Fallback}
  if($Wait){$problem.wait=$Wait}
  [IO.File]::WriteAllText($env:EASYAI_PROBLEM_PATH,($problem | ConvertTo-Json -Depth 12),[Text.UTF8Encoding]::new($false))
  Write-Output $Message
  exit 1
}
function Write-StagedText([string]$Path,[string]$Text,[bool]$Bom=$false) {
  if((Test-Path -LiteralPath $Path) -and [IO.File]::ReadAllText($Path) -ceq $Text){return}
  [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($Path)) | Out-Null
  $stage=$Path+'.stage-'+[Guid]::NewGuid().ToString('N')
  [IO.File]::WriteAllText($stage,$Text,[Text.UTF8Encoding]::new($Bom))
  if(Test-Path -LiteralPath $Path){[IO.File]::Replace($stage,$Path,($Path+'.backup-'+[Guid]::NewGuid().ToString('N')))}
  else {[IO.File]::Move($stage,$Path)}
}
function Require-Runtime([string]$Name,[string]$Minimum,[string]$Ref) {
  $command=Get-Command ($Name+'.exe') -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
  $healthy=$false
  if($command){
    try {
      $version=& $command.Source --version 2>$null
      $healthy=($LASTEXITCODE -eq 0 -and "$version" -match '(\d+\.\d+\.\d+)' -and [version]$Matches[1] -ge [version]$Minimum)
      if($healthy -and $Name -eq 'node') {
        $npm=Join-Path (Split-Path $command.Source -Parent) 'node_modules/npm/bin/npm-cli.js'
        $healthy=Test-Path -LiteralPath $npm
        if($healthy){$npmVersion=& $command.Source $npm --version 2>$null; $healthy=($LASTEXITCODE -eq 0 -and "$npmVersion" -match '^\d+\.\d+\.\d+$')}
      }
    } catch {$healthy=$false}
  }
  if(!$healthy){Stop-Contract 'runtime.missing' ('Cần '+$Name+' >= '+$Minimum+'.') @{type='contract';ref=$Ref;action='ensure';input=@{minVersion=$Minimum};resume='retry'}}
}
function Invoke-ContractStep([string]$Name) {
  & (Join-Path $PSScriptRoot $Name)
  if($LASTEXITCODE -ne 0){throw ('Script '+$Name+' failed: '+$LASTEXITCODE)}
}
$Context=Get-ContractContext
$Prefix=[string]$Context.paths.workspace
$RuntimePath=$env:PATH
$ShortcutDirectory=[Environment]::GetFolderPath('Programs')
if($Context.input.shortcutDirectory){$ShortcutDirectory=[string]$Context.input.shortcutDirectory}

$Prefix=Join-Path (Split-Path $Context.paths.shared -Parent) 'workspace/contracts/ai/codex'
if($Context.input.codexPrefix){$Prefix=[string]$Context.input.codexPrefix}
