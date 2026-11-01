$ErrorActionPreference = 'Stop'
$compiler = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
$framework = Split-Path $compiler
$references = @("/reference:$framework\WPF\PresentationFramework.dll", "/reference:$framework\WPF\PresentationCore.dll", "/reference:$framework\WPF\WindowsBase.dll", "/reference:$framework\System.Xaml.dll", "/reference:$framework\System.Windows.Forms.dll", "/reference:$framework\System.Web.Extensions.dll")
& $compiler /nologo /target:exe "/out:$PSScriptRoot\PatchAapt.exe" "$PSScriptRoot\PatchAapt.cs"
if ($LASTEXITCODE -ne 0) { throw 'Unicode compatibility helper compilation failed' }
& "$PSScriptRoot\PatchAapt.exe" "$PSScriptRoot\payload\tools\aapt.exe"
if ($LASTEXITCODE -ne 0) { throw 'aapt Unicode compatibility update failed' }
$gui = @('TV.cs','Studio.cs','Mirror.cs','Analysis.cs','Aerial.cs','ButtonHelp.cs','AiParser.cs','SharedAi.cs','CloudAi.cs','Reliability.cs','AgentAccess.cs','AdvancedAccess.cs','ChatFileAnalysis.cs','Classification.cs','Apks.cs','AiSettings.cs','Floating.cs','Community.cs','MacChrome.cs','MacFrame.cs','FolderImport.cs','AssemblyInfo.cs') | ForEach-Object { Join-Path $PSScriptRoot $_ }
& $compiler /nologo /target:winexe /main:TV "/out:$PSScriptRoot\payload\TVStudio.exe" @references "/resource:$PSScriptRoot\public-ai.json,tvstudio.public-ai.json" "/win32icon:$PSScriptRoot\payload\logo.ico" @gui
if ($LASTEXITCODE -ne 0) { throw 'GUI compilation failed' }
$installer = @('Setup.cs','SetupWizard.cs','MacFrame.cs','AssemblyInfo.cs') | ForEach-Object { Join-Path $PSScriptRoot $_ }
$installReferences = $references + @("/reference:$framework\System.IO.Compression.dll", "/reference:$framework\System.IO.Compression.FileSystem.dll", "/reference:$framework\Microsoft.CSharp.dll")
$resources = @("/win32icon:$PSScriptRoot\payload\logo.ico", "/resource:$PSScriptRoot\payload\logo.ico,logo.ico", "/resource:$PSScriptRoot\payload\Theme.xaml,theme.xaml")
& $compiler /nologo /target:winexe /main:Setup "/out:$PSScriptRoot\payload\Uninstall.exe" @installReferences @resources @installer
if ($LASTEXITCODE -ne 0) { throw 'Uninstaller compilation failed' }
$bundle = Join-Path $PSScriptRoot ('payload-' + [Guid]::NewGuid().ToString('N') + '.zip')
try {
 Compress-Archive -Path "$PSScriptRoot\payload\*" -DestinationPath $bundle -CompressionLevel Optimal
 & $compiler /nologo /target:winexe /main:Setup "/out:$PSScriptRoot\TVStudio-Setup.exe" "/resource:$bundle,payload.zip" @installReferences @resources @installer
 if ($LASTEXITCODE -ne 0) { throw 'Installer compilation failed' }
} finally {
 if (Test-Path -LiteralPath $bundle) { Remove-Item -LiteralPath $bundle }
}
Write-Output "Built $PSScriptRoot\TVStudio-Setup.exe"

