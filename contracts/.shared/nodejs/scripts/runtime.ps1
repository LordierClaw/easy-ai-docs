$ErrorActionPreference='Stop'
function Test-RuntimeVersion([string]$Id,[string]$Executable,[string]$Minimum) {
  try {
    if(!(Test-Path -LiteralPath $Executable -PathType Leaf)){return $null}
    $output=& $Executable --version 2>$null
    if($LASTEXITCODE -ne 0){return $null}
    $pattern='^git version (\d+\.\d+\.\d+(?:\.windows\.\d+)?)\s*$'
    if($Id -eq 'node'){$pattern='^v(\d+\.\d+\.\d+)\s*$'}
    if(($output -join "`n") -notmatch $pattern){return $null}
    $version=$Matches[1]
    if([version](($version -split '\.windows\.')[0]) -lt [version](($Minimum -split '\.windows\.')[0])){return $null}
    if($Id -eq 'node') {
      $base=Split-Path $Executable -Parent
      $npm=Join-Path $base 'node_modules/npm/bin/npm-cli.js'
      if(!(Test-Path -LiteralPath (Join-Path $base 'npm.cmd') -PathType Leaf) -or !(Test-Path -LiteralPath $npm -PathType Leaf)){return $null}
      $output=& $Executable $npm --version 2>$null
      if($LASTEXITCODE -ne 0 -or ($output -join "`n") -notmatch '^\d+\.\d+\.\d+\s*$'){return $null}
    }
    return $version
  } catch {return $null}
}
function Assert-RuntimePath([string]$Path) {
  if(!$Path -or $Path.Contains('\') -or $Path -match '(^/|:|[\x00-\x1f]|[. ]$)' -or $Path -match '(^|/)(\.|\.\.)(/|$)'){throw 'Unsafe ZIP path.'}
  foreach($part in $Path.Split('/')) {
    if(!$part -or $part -match '[. ]$|^(?i:con|prn|aux|nul|com[1-9]|lpt[1-9])(?:\.|$)' -or $part -match '[<>"|?*]'){throw 'Unsafe Windows ZIP path.'}
  }
  return $Path
}
function Assert-RuntimeZip([string]$Archive) {
  $bytes=[IO.File]::ReadAllBytes($Archive)
  if($bytes.Length -lt 22 -or $bytes.Length -gt 268435456){throw 'ZIP size is invalid.'}
  $end=-1
  for($i=$bytes.Length-22;$i -ge [Math]::Max(0,$bytes.Length-65557);$i--){
    if([BitConverter]::ToUInt32($bytes,$i) -eq 0x06054b50 -and $i+22+[BitConverter]::ToUInt16($bytes,$i+20) -eq $bytes.Length){$end=$i;break}
  }
  if($end -lt 0){throw 'ZIP directory is missing.'}
  $count=[BitConverter]::ToUInt16($bytes,$end+10)
  $start=[BitConverter]::ToUInt32($bytes,$end+16)
  if(!$count -or $count -gt 30000 -or [BitConverter]::ToUInt16($bytes,$end+4) -or [BitConverter]::ToUInt16($bytes,$end+6) -or [BitConverter]::ToUInt16($bytes,$end+8) -ne $count -or $start+[BitConverter]::ToUInt32($bytes,$end+12) -ne $end){throw 'ZIP64/multidisk/invalid directory is unsupported.'}
  $cursor=[long]$start; $expanded=[long]0; $paths=@{}; $files=@{}
  for($index=0;$index -lt $count;$index++){
    if($cursor+46 -gt $end -or [BitConverter]::ToUInt32($bytes,$cursor) -ne 0x02014b50){throw 'Invalid ZIP central header.'}
    $flags=[BitConverter]::ToUInt16($bytes,$cursor+8);$method=[BitConverter]::ToUInt16($bytes,$cursor+10)
    $packed=[BitConverter]::ToUInt32($bytes,$cursor+20);$size=[BitConverter]::ToUInt32($bytes,$cursor+24)
    $nameSize=[BitConverter]::ToUInt16($bytes,$cursor+28);$extra=[BitConverter]::ToUInt16($bytes,$cursor+30);$comment=[BitConverter]::ToUInt16($bytes,$cursor+32)
    $attributes=[BitConverter]::ToUInt32($bytes,$cursor+38);$local=[BitConverter]::ToUInt32($bytes,$cursor+42)
    $next=$cursor+46+$nameSize+$extra+$comment
    if($next -gt $end -or !$nameSize -or ($flags -band 1) -or $method -notin @(0,8) -or $size -gt 268435456 -or $packed -eq [uint32]::MaxValue -or [BitConverter]::ToUInt16($bytes,$cursor+34)){throw 'Unsupported ZIP entry.'}
    $raw=$bytes[($cursor+46)..($cursor+45+$nameSize)]
    if(@($raw | Where-Object {$_ -gt 127}).Count){throw 'ZIP paths must be ASCII.'}
    $name=[Text.Encoding]::ASCII.GetString($raw)
    $directory=$name.EndsWith('/')
    $path=Assert-RuntimePath $name.TrimEnd('/')
    if($paths.ContainsKey($path) -or (($attributes -shr 16) -band 0xf000) -eq 0xa000 -or ($attributes -band 0x400)){throw 'ZIP has duplicate paths or links.'}
    $paths[$path]=$true
    if(!$directory){$files[$path]=$true}
    $expanded+=$size
    if($expanded -gt 1073741824){throw 'ZIP expansion limit exceeded.'}
    if($local+30 -gt $start -or [BitConverter]::ToUInt32($bytes,$local) -ne 0x04034b50){throw 'Invalid ZIP local header.'}
    $localName=[BitConverter]::ToUInt16($bytes,$local+26);$localExtra=[BitConverter]::ToUInt16($bytes,$local+28)
    if($localName -ne $nameSize -or $local+30+$localName+$localExtra+$packed -gt $start -or [BitConverter]::ToUInt16($bytes,$local+6) -ne $flags -or [BitConverter]::ToUInt16($bytes,$local+8) -ne $method){throw 'ZIP local header mismatch.'}
    for($j=0;$j -lt $nameSize;$j++){if($bytes[$local+30+$j] -ne $raw[$j]){throw 'ZIP local path mismatch.'}}
    $cursor=$next
  }
  if($cursor -ne $end){throw 'ZIP directory size mismatch.'}
  foreach($name in $paths.Keys){$parts=$name.Split('/');for($i=1;$i -lt $parts.Length;$i++){if($files.ContainsKey(($parts[0..($i-1)] -join '/'))){throw 'ZIP file/directory collision.'}}}
}
function Get-StreamHash($Stream) {
  $sha=[Security.Cryptography.SHA256]::Create()
  try {return [BitConverter]::ToString($sha.ComputeHash($Stream)).Replace('-','').ToLowerInvariant()} finally {$sha.Dispose()}
}
function Assert-NoRuntimeLinks([string]$Root) {
  $cursor=[IO.Path]::GetFullPath($Root)
  while($cursor) {
    if((Test-Path -LiteralPath $cursor) -and ((Get-Item -LiteralPath $cursor -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)){throw 'Runtime paths cannot contain links.'}
    $next=Split-Path $cursor -Parent
    if($next -eq $cursor){break};$cursor=$next
  }
}
function Assert-RuntimePayload([string]$Archive,[string]$Payload) {
  Assert-NoRuntimeLinks $Payload
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  $zip=[IO.Compression.ZipFile]::OpenRead($Archive)
  $expected=@{}
  try {
    foreach($entry in $zip.Entries) {
      if($entry.FullName.EndsWith('/')){continue}
      $expected[$entry.FullName]=$true
      $path=Join-Path $Payload $entry.FullName
      Assert-NoRuntimeLinks $path
      if(!(Test-Path -LiteralPath $path -PathType Leaf)){throw 'Runtime cache file missing.'}
      $source=$entry.Open();$target=[IO.File]::OpenRead($path)
      try {if((Get-StreamHash $source) -cne (Get-StreamHash $target)){throw 'Runtime cache hash mismatch.'}} finally {$source.Dispose();$target.Dispose()}
    }
    foreach($file in Get-ChildItem -LiteralPath $Payload -Force -Recurse) {
      if($file.Attributes -band [IO.FileAttributes]::ReparsePoint){throw 'Runtime cache contains a link.'}
      if(!$file.PSIsContainer){$relative=$file.FullName.Substring($Payload.TrimEnd('\').Length+1).Replace('\','/');if(!$expected.ContainsKey($relative)){throw 'Runtime cache has unrecognized files.'}}
    }
  } finally {$zip.Dispose()}
}
function Assert-RuntimeArchive([string]$Path,$Artifact) {
  Assert-NoRuntimeLinks $Path
  if((Get-Item -LiteralPath $Path).Length -ne $Artifact.size -or (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant() -cne $Artifact.sha256){throw 'Runtime archive size or SHA256 mismatch.'}
  Assert-RuntimeZip $Path
}
function Receive-RuntimeArchive([string]$Url,[string]$Destination,[long]$Limit) {
  [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
  $uri=[Uri]$Url
  for($redirect=0;$redirect -lt 5;$redirect++) {
    if($uri.Scheme -ne 'https' -or $uri.UserInfo -or !$uri.IsDefaultPort -or $uri.Host -notin @('github.com','release-assets.githubusercontent.com','objects.githubusercontent.com')){throw 'Runtime download source is not allowed.'}
    $request=[Net.HttpWebRequest]::Create($uri);$request.AllowAutoRedirect=$false;$request.Timeout=180000;$request.ReadWriteTimeout=180000;$request.UserAgent='EasyAI-contract-runtime'
    $response=$request.GetResponse()
    try {
      if([int]$response.StatusCode -in @(301,302,303,307,308)){$uri=[Uri]::new($uri,$response.Headers['Location']);continue}
      if([int]$response.StatusCode -ne 200 -or $response.ContentLength -gt $Limit){throw 'Runtime HTTP response is invalid.'}
      $inputStream=$response.GetResponseStream();$outputStream=[IO.File]::Create($Destination)
      try {
        $buffer=New-Object byte[] 65536;$total=[long]0
        while(($read=$inputStream.Read($buffer,0,$buffer.Length)) -gt 0){$total+=$read;if($total -gt $Limit -or $total -gt 268435456){throw 'Runtime download size limit exceeded.'};$outputStream.Write($buffer,0,$read)}
      } finally {$inputStream.Dispose();$outputStream.Dispose()}
      return
    } finally {$response.Dispose()}
  }
  throw 'Too many runtime redirects.'
}
function Export-RuntimePaths([string[]]$Paths) {
  [IO.File]::WriteAllText($env:EASYAI_ENV_PATH,(@{pathPrepend=@($Paths)} | ConvertTo-Json),[Text.UTF8Encoding]::new($false))
}
function Resolve-ContractRuntime($Context,$Artifact) {
  $minimum=[string]$Context.input.minVersion
  if(!$minimum){$minimum=$Artifact.version}
  if($minimum -notmatch '^\d+\.\d+\.\d+(?:\.windows\.\d+)?$'){throw 'Invalid minimum runtime version.'}
  $system=Get-Command ($Artifact.id+'.exe') -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
  if($system){$version=Test-RuntimeVersion $Artifact.id $system.Source $minimum;if($version){if($Context.action -ne 'doctor'){Export-RuntimePaths @((Split-Path $system.Source -Parent))};Write-Output ('Runtime system: '+$Artifact.id+' '+$version);return}}
  $parent=Join-Path $Context.paths.shared ('runtimes/'+$Artifact.id)
  $installed=Join-Path $parent ($Artifact.version+'-'+$Artifact.sha256.Substring(0,16))
  $payload=Join-Path $installed 'payload'
  $healthy=$false
  if(Test-Path -LiteralPath $installed){
    try {
      Assert-RuntimeArchive (Join-Path $installed 'archive.zip') $Artifact
      Assert-RuntimePayload (Join-Path $installed 'archive.zip') $payload
      $version=Test-RuntimeVersion $Artifact.id (Join-Path $payload $Artifact.executable) $minimum
      if($version -cne $Artifact.version){throw 'Runtime cached version mismatch.'}
      foreach($entry in $Artifact.pathEntries){$null=Assert-RuntimePath $entry;if(!(Test-Path -LiteralPath (Join-Path $payload $entry) -PathType Container)){throw 'Runtime PATH directory missing.'}}
      $healthy=$true
    } catch {Write-Output 'Runtime cache failed verification; preserved for diagnosis.'}
  }
  if($Context.action -eq 'doctor'){Write-Output ('DIAGNOSIS: '+$Artifact.id+' cache healthy='+$healthy+'; use ensure to restore a missing runtime.');return}
  if(!$healthy){
    if([version](($Artifact.version -split '\.windows\.')[0]) -lt [version](($minimum -split '\.windows\.')[0])){throw 'Pinned artifact is older than the requested minimum.'}
    if(![Environment]::Is64BitOperatingSystem){throw 'Runtime requires Windows x64.'}
    Assert-NoRuntimeLinks $parent
    [IO.Directory]::CreateDirectory($parent) | Out-Null
    $staging=Join-Path $parent ('.staging-'+[Guid]::NewGuid().ToString('N'))
    [IO.Directory]::CreateDirectory($staging) | Out-Null
    $archive=Join-Path $staging 'archive.zip'
    Receive-RuntimeArchive $Artifact.url $archive $Artifact.size
    Assert-RuntimeArchive $archive $Artifact
    $stagePayload=Join-Path $staging 'payload'
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [IO.Compression.ZipFile]::ExtractToDirectory($archive,$stagePayload)
    Assert-RuntimePayload $archive $stagePayload
    $version=Test-RuntimeVersion $Artifact.id (Join-Path $stagePayload $Artifact.executable) $minimum
    if($version -cne $Artifact.version){throw 'Downloaded runtime version/npm verification failed.'}
    foreach($entry in $Artifact.pathEntries){$null=Assert-RuntimePath $entry;if(!(Test-Path -LiteralPath (Join-Path $stagePayload $entry) -PathType Container)){throw 'Downloaded runtime PATH directory missing.'}}
    [IO.File]::WriteAllText((Join-Path $staging 'runtime.json'),($Artifact | ConvertTo-Json -Depth 8),[Text.UTF8Encoding]::new($false))
    # Publish only a fully verified replacement; keep the previous cache as a backup.
    $backup=$null
    if(Test-Path -LiteralPath $installed){$backup=$installed+'.backup-'+[Guid]::NewGuid().ToString('N');[IO.Directory]::Move($installed,$backup)}
    try {[IO.Directory]::Move($staging,$installed)} catch {if($backup){[IO.Directory]::Move($backup,$installed)};throw}
  }
  Export-RuntimePaths @($Artifact.pathEntries | ForEach-Object {Join-Path $payload $_})
  Write-Output ('Runtime verified: '+$Artifact.id+' '+$Artifact.version)
}
