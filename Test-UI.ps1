$ErrorActionPreference = 'Stop'
$framework = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319'
$compiler = Join-Path $framework 'csc.exe'
$testRoot = Join-Path $PSScriptRoot ('ui-test-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory $testRoot | Out-Null
Copy-Item "$PSScriptRoot\payload\TVStudio.exe", "$PSScriptRoot\payload\Theme.xaml", "$PSScriptRoot\payload\logo.ico", "$PSScriptRoot\payload\brand-icons.json", "$PSScriptRoot\payload\classification-rules.json" $testRoot
& $compiler /nologo /target:exe "/out:$testRoot\UiCheck.exe" "/reference:$testRoot\TVStudio.exe" "/reference:$framework\WPF\PresentationFramework.dll" "/reference:$framework\WPF\PresentationCore.dll" "/reference:$framework\WPF\WindowsBase.dll" "/reference:$framework\System.Xaml.dll" "/reference:$framework\System.Windows.Forms.dll" "/reference:$framework\System.Drawing.dll" "$PSScriptRoot\UiCheck.cs"
if ($LASTEXITCODE -ne 0) { throw 'UI test compilation failed' }
$previousData = $env:TVSTUDIO_DATA
try {
 $env:TVSTUDIO_DATA = Join-Path $testRoot 'data'
 Push-Location $testRoot
 & "$testRoot\UiCheck.exe"
 $testExit = $LASTEXITCODE
 Get-Content "$testRoot\ui-check.log"
 if ($testExit -ne 0) { throw 'UI checks failed' }
} finally {
 Pop-Location
 $env:TVSTUDIO_DATA = $previousData
}
