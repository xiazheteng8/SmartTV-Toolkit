$ErrorActionPreference='Stop'
$fw=Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319'
$testRoot=Join-Path $PSScriptRoot ('agent-test-'+[Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory $testRoot | Out-Null
Copy-Item "$PSScriptRoot\payload\TVStudio.exe","$PSScriptRoot\payload\Theme.xaml","$PSScriptRoot\payload\logo.ico","$PSScriptRoot\payload\brand-icons.json", "$PSScriptRoot\payload\classification-rules.json" $testRoot
& "$fw\csc.exe" /nologo "/out:$testRoot\adb.exe" "$PSScriptRoot\MockAdb.cs"
if($LASTEXITCODE -ne 0){throw 'Mock compilation failed'}
& "$fw\csc.exe" /nologo "/out:$testRoot\AgentCheck.exe" "/reference:$testRoot\TVStudio.exe" "/reference:$fw\WPF\PresentationFramework.dll" "/reference:$fw\WPF\PresentationCore.dll" "/reference:$fw\WPF\WindowsBase.dll" "/reference:$fw\System.Xaml.dll" "/reference:$fw\System.Web.Extensions.dll" "$PSScriptRoot\AgentCheck.cs"
if($LASTEXITCODE -ne 0){throw 'Test compilation failed'}
$previous=$env:TVSTUDIO_AGENT_TEST_ROOT
try{$env:TVSTUDIO_AGENT_TEST_ROOT=$testRoot;node "$PSScriptRoot\Test-Agent.cjs";if($LASTEXITCODE -ne 0){throw 'Agent loopback checks failed; inspect network permissions and the diagnostic log'}}finally{$env:TVSTUDIO_AGENT_TEST_ROOT=$previous}
