if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script requires elevated privileges to run. Please run as Administrator."
    $null = Read-Host "Press Enter to restart the script with Administrator privileges"
    #Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}
$grooperRoot = "$env:SYSTEMDRIVE\inetpub\wwwroot\Grooper"
$webConfigPath = "$grooperRoot\Web.config"
$layoutCshtmlPath = "$grooperRoot\Views\Shared\Layout.cshtml"
$webConfigBackupPath = "$grooperRoot\Web.config.bak"
$layoutCshtmlBackupPath = "$grooperRoot\Views\Shared\Layout.cshtml.bak"
if (-not(Test-Path $webConfigBackupPath)) {
if (Test-Path $webConfigPath) {
    Copy-Item -Path $webConfigPath -Destination $webConfigBackupPath -Force
    Write-Host "Backup of Web.config created at $webConfigBackupPath"
} else {
    Write-Host "Web.config file not found at $webConfigPath"
}
}
if (-not(Test-Path $layoutCshtmlBackupPath)) {
if (Test-Path $layoutCshtmlPath) {
    Copy-Item -Path $layoutCshtmlPath -Destination $layoutCshtmlBackupPath -Force
    Write-Host "Backup of _Layout.cshtml created at $layoutCshtmlBackupPath"
} else {
    Write-Host "Layout.cshtml file not found at $layoutCshtmlPath"
}
}

$webConfigContent = Get-Content -Path $webConfigPath -Raw

$webConfigInsertLine = @"
    <authentication mode="Forms">
        <forms cookieless="UseCookies" name=".ASPXAUTH" timeout="14440" />
    </authentication>
"@

if ($webConfigContent -match '<authentication mode="Windows" />') {
    $webConfigContent = $webConfigContent -replace '<authentication mode="Windows" />', $webConfigInsertLine
    Set-Content -Path $webConfigPath -Value $webConfigContent
    Write-Host "Replaced Windows authentication with Forms authentication in web.config"
} else {
    Write-Host "Windows authentication block not found. No changes made to web.config."
}

$libSourcePaths = @(
    "$PSScriptRoot\src\libs\System.DirectoryServices.AccountManagement.dll",
    "$PSScriptRoot\src\libs\System.DirectoryServices.AccountManagement.xml",
    "$PSScriptRoot\src\libs\Newtonsoft.Json.dll",
    "$PSScriptRoot\src\libs\Newtonsoft.Json.xml"
)
foreach ($libPath in $libSourcePaths) {
    if (Test-Path $libPath) {
        Copy-Item -Path $libPath -Destination "$grooperRoot\bin\" -Force
        Write-Host "Copied $libPath to $grooperRoot\bin\"
    } else {
        Write-Host "File not found: $libPath"
    }
}

$rootFiles = @(
    "$PSScriptRoot\src\images\apple-touch-icon.png",
    "$PSScriptRoot\src\images\favicon.svg",
    "$PSScriptRoot\src\images\favicon.ico",
    "$PSScriptRoot\src\images\favicon-48x48.png",
    "$PSScriptRoot\src\images\web-app-manifest-192x192.png",
    "$PSScriptRoot\src\images\web-app-manifest-512x512.png",
    "$PSScriptRoot\src\images\login-bg.jpg",
    "$PSScriptRoot\src\Login.aspx",
    "$PSScriptRoot\src\Login.aspx.cs",
    "$PSScriptRoot\src\Login.css",
    "$PSScriptRoot\src\Login.cshtml",
    "$PSScriptRoot\src\Logout.js",
    "$PSScriptRoot\src\site.webmanifest"
)

foreach ($filePath in $rootFiles) {
    if (Test-Path $filePath) {
        Copy-Item -Path $filePath -Destination "$grooperRoot\" -Force
        Write-Host "Copied $filePath to $grooperRoot\"
    } else {
        Write-Host "File not found: $pdw $filePath"

    }
}

$layoutCshtmlInsertLine = '@Html.Partial("Login")'
$layoutCshtmlContent = Get-Content -Path $layoutCshtmlPath -Raw
if ($layoutCshtmlContent -notmatch $layoutCshtmlInsertLine) {

    $layoutCshtmlContent = $layoutCshtmlContent -replace '(<link rel="preload".*? />\s*)@Styles.Render', "`$1$layoutCshtmlInsertLine`r`n  @Styles.Render"
    Set-Content -Path $layoutCshtmlPath -Value $layoutCshtmlContent
    Write-Host "Inserted @Html.Partial('Login') into Layout.cshtml"
} else {
    Write-Host "The partial view line already exists in Layout.cshtml. No changes made."
}

Read-Host "Script execution completed. Press any key to continue"

