$ErrorActionPreference = "Stop"

function Invoke-Call {
    param (
        [scriptblock]$ScriptBlock,
        [string]$ErrorAction = $ErrorActionPreference
    )
    & @ScriptBlock
    if (($lastexitcode -ne 0) -and $ErrorAction -eq "Stop") {
        exit $lastexitcode
    }
}

if (Test-Path ".\dist") {
    Remove-Item ".\dist" -Force -Recurse
}

New-Item -Path .\dist -ItemType Directory
gci -File .\target\release | Copy-Item -Destination .\dist\
Copy-Item -Recurse .\appx\* .\dist\
Invoke-Call -ScriptBlock { MakeAppx pack /d dist /p dist\wireguard } -ErrorAction Stop
Write-Host "Make sure the publisher fields in .\appx\AppxManifest.xml match the fields in your certificate. For more details see https://learn.microsoft.com/en-us/uwp/schemas/appxpackage/appxmanifestschema/element-identity"
$KeyLocation = Read-Host "Certificate location (.pfx file)"
$Password = Read-Host "Certificate password"
Invoke-Call -ScriptBlock { SignTool sign /fd SHA256 /a /f $KeyLocation /p $Password dist\wireguard.appx } -ErrorAction Stop
Write-Host Done. appx is located at .\dist\wireguard.appx. Use "Add-AppxPackage -AllowUnsigned .\dist\wireguard.appx" to install.
