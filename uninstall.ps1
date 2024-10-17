if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $null = Read-Host "This script requires elevated privileges to run. Please run as Administrator."
    exit
}

$grooperRoot = "$env:SYSTEMDRIVE\inetpub\wwwroot\Grooper"

$customFiles = @(
    "$grooperRoot\apple-touch-icon.png",
    "$grooperRoot\favicon.svg",
    "$grooperRoot\favicon-48x48.png",
    "$grooperRoot\web-app-manifest-192x192.png",
    "$grooperRoot\web-app-manifest-512x512.png",
    "$grooperRoot\Login.aspx",
    "$grooperRoot\Login.aspx.cs",
    "$grooperRoot\Login.css",
    "$grooperRoot\Login.cshtml",
    "$grooperRoot\login-bg.jpg",
    "$grooperRoot\Logout.js",
    "$grooperRoot\site.webmanifest",
    "$grooperRoot\Web.config",
    "$grooperRoot\bin\System.DirectoryServices.AccountManagement.dll",
    "$grooperRoot\bin\System.DirectoryServices.AccountManagement.xml",
    "$grooperRoot\bin\Newtonsoft.json.dll",
    "$grooperRoot\bin\Newtonsoft.json.xml",
    "$grooperRoot\Views\Shared\Layout.cshtml"
)


foreach($file in $customFiles) {
    Remove-Item $file
}


$webConfigPath = "$grooperRoot\Web.config"
$layoutCshtmlPath = "$grooperRoot\Views\Shared\Layout.cshtml"

$webConfigBackupPath = "$grooperRoot\Web.config.bak"
$layoutCshtmlBackupPath = "$grooperRoot\Views\Shared\Layout.cshtml.bak"


if (Test-Path $webConfigBackupPath) {
    Rename-Item -Path $webConfigBackupPath -NewName $webConfigPath -Force
    Write-Host "Restored original Web.config from backup."
} else {
    Write-Host "Backup for Web.config not found. No restoration performed."
}

if (Test-Path $layoutCshtmlBackupPath) {
    Rename-Item -Path $layoutCshtmlBackupPath -NewName $layoutCshtmlPath -Force
    Write-Host "Restored original Layout.cshtml from backup."
} else {
    Write-Host "Backup for Layout.cshtml not found. No restoration performed."
}

#$null = Read-Host "Backup restoration process completed."
exit