if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script requires elevated privileges to run. Please run as Administrator."
    $null = Read-Host "Press Enter to restart the script with Administrator privileges"
    #Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Import-Module WebAdministration
$siteName = "Grooper"
$sitePath = "IIS:\Sites\Default Web Site\$siteName"

if (-not (Test-Path $sitePath)) {
    Write-Host "Site '$siteName' not found in IIS."
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
        Write-Host "Backup of Layout.cshtml created at $layoutCshtmlBackupPath"
    } else {
        Write-Host "Layout.cshtml file not found at $layoutCshtmlPath"
    }
}

$mimeExtension = ".webmanifest"
$mimeType = "application/manifest+json"
$existingMime = Get-WebConfigurationProperty -PSPath $sitePath `
    -Filter "system.webServer/staticContent/mimeMap" `
    -Name "." | Where-Object { $_.fileExtension -eq $mimeExtension }

if ($existingMime) {
    Write-Host "MIME type for '$mimeExtension' already exists. No changes made."
} else {
    Add-WebConfigurationProperty -PSPath $sitePath `
        -Filter "system.webServer/staticContent" `
        -Name "." -Value @{
            fileExtension = $mimeExtension
            mimeType = $mimeType
        }
    Write-Host "Added MIME type for '$mimeExtension' with type '$mimeType' to site '$siteName'."
}


Set-WebConfigurationProperty -PSPath $sitePath `
    -Filter "system.web/authentication" `
    -Name "mode" -Value "Forms"

Set-WebConfigurationProperty -PSPath $sitePath `
    -Filter "system.web/authentication/forms" `
    -Name "cookieless" -Value "UseCookies"

Set-WebConfigurationProperty -PSPath $sitePath `
    -Filter "system.web/authentication/forms" `
    -Name "name" -Value ".ASPXAUTH"

Set-WebConfigurationProperty -PSPath $sitePath `
    -Filter "system.web/authentication/forms" `
    -Name "timeout" -Value "14440"

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

$imageFiles = @(
    "$PSScriptRoot\src\images\apple-touch-icon.png",
    "$PSScriptRoot\src\images\favicon.svg",
    "$PSScriptRoot\src\images\favicon.ico",
    "$PSScriptRoot\src\images\favicon-48x48.png",
    "$PSScriptRoot\src\images\web-app-manifest-192x192.png",
    "$PSScriptRoot\src\images\web-app-manifest-512x512.png",
    "$PSScriptRoot\src\images\login-bg.jpg",
    "$PSScriptRoot\src\images\grooper_logo.svg"
)

foreach ($filePath in $imageFiles) {
    if (Test-Path $filePath) {
        Copy-Item -Path $filePath -Destination "$grooperRoot\Content\Images\" -Force
        Write-Host "Copied $filePath to $grooperRoot\Content\Images\"
    } else {
        Write-Host "File not found: $pwd $filePath"

    }
}

Copy-Item -Path "$PSScriptRoot\src\Login.cshtml" -Destination "$grooperRoot\Views\Shared\" -Force
Write-Host "Copied $filePath to $grooperRoot\"

$rootFiles = @(
    "$PSScriptRoot\src\Login.aspx",
    "$PSScriptRoot\src\Login.aspx.cs",
    "$PSScriptRoot\src\Login.css",
    "$PSScriptRoot\src\Logout.js",
    "$PSScriptRoot\src\site.webmanifest"
)

foreach ($filePath in $rootFiles) {
    if (Test-Path $filePath) {
        Copy-Item -Path $filePath -Destination "$grooperRoot\" -Force
        Write-Host "Copied $filePath to $grooperRoot\"
    } else {
        Write-Host "File not found: $pwd $filePath"

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

