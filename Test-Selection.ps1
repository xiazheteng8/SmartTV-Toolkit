$ErrorActionPreference = 'Stop'
$framework = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319'
$compiler = Join-Path $framework 'csc.exe'
$testRoot = Join-Path $PSScriptRoot ('selection-test-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory $testRoot | Out-Null
Copy-Item "$PSScriptRoot\payload\Theme.xaml", "$PSScriptRoot\payload\logo.ico", "$PSScriptRoot\payload\brand-icons.json", "$PSScriptRoot\payload\classification-rules.json" $testRoot
$references = @("/reference:$framework\WPF\PresentationFramework.dll", "/reference:$framework\WPF\PresentationCore.dll", "/reference:$framework\WPF\WindowsBase.dll", "/reference:$framework\System.Xaml.dll", "/reference:$framework\System.Windows.Forms.dll", "/reference:$framework\System.Web.Extensions.dll")
$gui = @('TV.cs','Studio.cs','Mirror.cs','Analysis.cs','Aerial.cs','ButtonHelp.cs','AiParser.cs','SharedAi.cs','CloudAi.cs','Reliability.cs','AgentAccess.cs','AdvancedAccess.cs','ChatFileAnalysis.cs','Classification.cs','Apks.cs','AiSettings.cs','Floating.cs','Community.cs','MacChrome.cs','MacFrame.cs','FolderImport.cs','AssemblyInfo.cs') | ForEach-Object { Join-Path $PSScriptRoot $_ }
& $compiler /nologo /target:winexe /main:TV "/out:$testRoot\TVStudio.exe" @references "/resource:$PSScriptRoot\public-ai.json,tvstudio.public-ai.json" @gui
if ($LASTEXITCODE -ne 0) { throw 'GUI test compilation failed' }
& $compiler /nologo /target:exe "/out:$testRoot\SelectionCheck.exe" "/reference:$testRoot\TVStudio.exe" @references "$PSScriptRoot\SelectionCheck.cs"
if ($LASTEXITCODE -ne 0) { throw 'Selection test compilation failed' }
$previousData = $env:TVSTUDIO_DATA
try {
 $env:TVSTUDIO_DATA = Join-Path $testRoot 'data'
 Push-Location $testRoot
 & "$testRoot\SelectionCheck.exe"
 if ($LASTEXITCODE -ne 0) { throw 'Selection regression failed' }
} finally {
 Pop-Location
 $env:TVSTUDIO_DATA = $previousData
}
