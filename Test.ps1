$ErrorActionPreference = 'Stop'
$framework = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319'
$compiler = Join-Path $framework 'csc.exe'
$testRoot = Join-Path $PSScriptRoot ('test-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory $testRoot | Out-Null
Copy-Item "$PSScriptRoot\payload\TVStudio.exe", "$PSScriptRoot\payload\Theme.xaml", "$PSScriptRoot\payload\logo.ico", "$PSScriptRoot\payload\brand-icons.json", "$PSScriptRoot\payload\classification-rules.json" $testRoot
Copy-Item "$PSScriptRoot\payload\Launcher" $testRoot -Recurse
& $compiler /nologo /target:exe "/out:$testRoot\adb.exe" "$PSScriptRoot\MockAdb.cs"
if ($LASTEXITCODE -ne 0) { throw 'Mock compile failed' }
& $compiler /nologo /target:exe "/out:$testRoot\Integration.exe" "/reference:$testRoot\TVStudio.exe" "/reference:$framework\WPF\PresentationFramework.dll" "/reference:$framework\WPF\PresentationCore.dll" "/reference:$framework\WPF\WindowsBase.dll" "/reference:$framework\System.Xaml.dll" "/reference:$framework\System.Web.Extensions.dll" "$PSScriptRoot\Integration.cs"
if ($LASTEXITCODE -ne 0) { throw 'Test compile failed' }
$previousData = $env:TVSTUDIO_DATA
try {
 $env:TVSTUDIO_DATA = Join-Path $testRoot 'data'
 Push-Location $testRoot
 & "$testRoot\Integration.exe"
 $testExit = $LASTEXITCODE
 Get-Content "$testRoot\integration.log"
 if ($testExit -ne 0) { throw 'Integration checks failed' }
} finally {
 Pop-Location
 $env:TVSTUDIO_DATA = $previousData
}


