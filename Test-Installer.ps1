$ErrorActionPreference = 'Stop'
$framework = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319'
$compiler = Join-Path $framework 'csc.exe'
$testRoot = Join-Path $PSScriptRoot ('it-' + [Guid]::NewGuid().ToString('N').Substring(0,8))
New-Item -ItemType Directory $testRoot | Out-Null
Copy-Item "$PSScriptRoot\TVStudio-Setup.exe" $testRoot
$references = @("/reference:$testRoot\TVStudio-Setup.exe", "/reference:$framework\WPF\PresentationFramework.dll", "/reference:$framework\WPF\PresentationCore.dll", "/reference:$framework\WPF\WindowsBase.dll", "/reference:$framework\System.Xaml.dll", "/reference:$framework\System.Web.Extensions.dll")
& $compiler /nologo /target:exe "/out:$testRoot\WizardCheck.exe" @references "$PSScriptRoot\WizardCheck.cs"
if ($LASTEXITCODE -ne 0) { throw 'Installer UI test compilation failed' }
& $compiler /nologo /target:exe "/out:$testRoot\InstallerCheck.exe" @references "$PSScriptRoot\InstallerCheck.cs"
if ($LASTEXITCODE -ne 0) { throw 'Installer engine test compilation failed' }
try {
 Push-Location $testRoot
 & "$testRoot\WizardCheck.exe"
 $uiExit = $LASTEXITCODE
 Get-Content "$testRoot\wizard-check.log"
 if ($uiExit -ne 0) { throw 'Installer UI checks failed' }
 & "$testRoot\InstallerCheck.exe"
 $engineExit = $LASTEXITCODE
 Get-Content "$testRoot\installer-check.log"
 if ($engineExit -ne 0) { throw 'Installer engine checks failed' }
} finally {
 Pop-Location
}

