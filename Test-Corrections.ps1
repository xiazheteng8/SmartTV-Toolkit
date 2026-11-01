param([string]$Phase = 'active')
$ErrorActionPreference = 'Stop'
$framework = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319'
$compiler = Join-Path $framework 'csc.exe'
$testRoot = Join-Path $PSScriptRoot ('correction-test-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory $testRoot | Out-Null
Copy-Item "$PSScriptRoot\payload\TVStudio.exe", "$PSScriptRoot\payload\Theme.xaml", "$PSScriptRoot\payload\logo.ico", "$PSScriptRoot\payload\brand-icons.json", "$PSScriptRoot\payload\classification-rules.json" $testRoot
& $compiler /nologo /target:exe "/out:$testRoot\adb.exe" "$PSScriptRoot\MockAdb.cs"
if ($LASTEXITCODE -ne 0) { throw 'Mock compile failed' }
& $compiler /nologo /target:exe "/out:$testRoot\CorrectionCheck.exe" "/reference:$testRoot\TVStudio.exe" "/reference:$framework\WPF\PresentationFramework.dll" "/reference:$framework\WPF\PresentationCore.dll" "/reference:$framework\WPF\WindowsBase.dll" "/reference:$framework\System.Xaml.dll" "$PSScriptRoot\CorrectionCheck.cs"
if ($LASTEXITCODE -ne 0) { throw 'Correction test compile failed' }
$previousData = $env:TVSTUDIO_DATA
try {
 $env:TVSTUDIO_DATA = Join-Path $testRoot 'data'
 Push-Location $testRoot
 & "$testRoot\CorrectionCheck.exe" $Phase | Tee-Object -FilePath 'correction-check.log'
 if ($LASTEXITCODE -ne 0) { throw 'Correction checks failed' }
} finally {
 Pop-Location
 $env:TVSTUDIO_DATA = $previousData
}
