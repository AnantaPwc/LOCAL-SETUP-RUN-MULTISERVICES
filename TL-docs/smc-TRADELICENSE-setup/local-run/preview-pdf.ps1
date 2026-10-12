<#
Renders the trade license receipt and certificate with the local pdf-service and saves them as PDF files,
so a change to the PDF configs can be checked before it is deployed.

  .\preview-pdf.ps1 -ApplicationNumber PB-TL-2026-10-04-005907
  .\preview-pdf.ps1 -ApplicationNumber PB-TL-2026-10-04-005907 -Locale mr_IN

  .\preview-pdf.ps1 -ApplicationNumber PB-TL-2026-10-04-005907 -Rebuild   # after editing build-pdf-configs.js

Needs the local stack (start-local.ps1) and a local pdf-service on port 8098 loaded with the configs to test.
-Rebuild regenerates the configs and (re)starts that pdf-service; it needs "npm install" done once in
core-services\pdf-service and the localization port-forward on 8097.
#>
param(
    [Parameter(Mandatory = $true)][string]$ApplicationNumber,
    [string]$Locale = "en_IN",
    [string]$TenantId = "pg.smc",
    [string]$PdfUrl = "http://localhost:8098/pdf-service/v1/_createnosave",
    [string]$OutDir = "",
    [switch]$Rebuild,
    [string]$ConfigDir = "C:\Users\Ananta\UPYOG-SMC-CODE\configs-scm\configs\pdf-service",
    [string]$PdfServiceDir = "C:\Users\Ananta\UPYOG-SMC-CODE\app-services\core-services\pdf-service",
    [string]$LogDir = "C:\Users\Ananta\UPYOG-SMC-CODE\local-run-logs"
)

$ErrorActionPreference = "Stop"
if (-not $OutDir) { $OutDir = Join-Path $PSScriptRoot "pdf-samples" }

if ($Rebuild) {
    # regenerate the four config files from build-pdf-configs.js and restart the local pdf-service on them
    $preview = Join-Path $env:TEMP "smc-pdf-preview"
    node (Join-Path $PSScriptRoot "build-pdf-configs.js") $ConfigDir $preview
    if ($LASTEXITCODE -ne 0) { throw "build-pdf-configs.js failed" }
    $old = Get-NetTCPConnection -State Listen -LocalPort 8098 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($old) { Stop-Process -Id $old.OwningProcess -Force -Confirm:$false; Start-Sleep -Seconds 2 }
    $pv = $preview -replace '\\', '/'
    $env:DATA_CONFIG_URLS = "file://$pv/data-config/tradelicense-receipt.json,file://$pv/data-config/tlcertificate.json,file://$pv/data-config/tl-loi.json"
    $env:FORMAT_CONFIG_URLS = "file://$pv/format-config/tradelicense-receipt.json,file://$pv/format-config/tlcertificate.json,file://$pv/format-config/tl-loi.json"
    $env:SERVER_PORT = "8098"; $env:KAFKA_BROKER_HOST = "localhost:9092"; $env:DEFAULT_LOCALISATION_TENANT = "pg"
    $env:EGOV_LOCALISATION_HOST = "http://localhost:8097/"   # kubectl port-forward svc/egov-localization 8097:8080 -n egov
    $env:EGOV_HOST = "https://sangamner-demo.ddns.net/"; $env:EGOV_EXTERNAL_HOST = "https://sangamner-demo.ddns.net/"
    # _create (what the browser calls) saves the PDF in the file store; the server's one is used, through a port-forward
    $env:EGOV_FILESTORE_SERVICE_HOST = "http://localhost:8099/"
    if (-not (Get-NetTCPConnection -State Listen -LocalPort 8099 -ErrorAction SilentlyContinue)) {
        if (-not $env:KUBECONFIG) { $env:KUBECONFIG = "C:\Users\.kube\config" }
        Start-Process kubectl -ArgumentList "port-forward", "svc/egov-filestore", "8099:8080", "-n", "egov", "--address", "127.0.0.1" -WindowStyle Hidden | Out-Null
    }
    # _createnosave never touches the database, the service only needs the three values to start
    $env:DB_NAME = "digit"; $env:DB_USER = "postgres"; $env:DB_PASSWORD = "postgres"
    New-Item -ItemType Directory -Force $LogDir | Out-Null
    $log = Join-Path $LogDir "pdf-service.log"
    Start-Process -FilePath (Join-Path $PdfServiceDir "node_modules\.bin\babel-node.cmd") -ArgumentList "src", "--presets", "es2015,stage-0" `
        -WorkingDirectory $PdfServiceDir -RedirectStandardOutput $log -RedirectStandardError (Join-Path $LogDir "pdf-service.err") -WindowStyle Hidden | Out-Null
    for ($i = 0; $i -lt 40; $i++) { Start-Sleep -Seconds 3; if (Select-String -Path $log -Pattern "Producer is ready" -Quiet -ErrorAction SilentlyContinue) { break } }
    if ($i -ge 40) { throw "pdf-service did not start, see $log" }
}
New-Item -ItemType Directory -Force $OutDir | Out-Null

$requestInfo = @{
    apiId = "Rainmaker"; authToken = "not-checked-locally"; msgId = "preview|$Locale"
    userInfo = @{ id = 10059; uuid = "73e6bb90-e1d0-4835-99d5-adc277877af6"; userName = "TLSU1"; name = "TLSU1"; type = "EMPLOYEE"; tenantId = $TenantId
                  roles = @(@{ code = "TL_CEMP"; name = "TL_CEMP"; tenantId = $TenantId }) }
}

function Get-Json([string]$Url) {
    $body = @{ RequestInfo = $requestInfo } | ConvertTo-Json -Depth 10
    Invoke-RestMethod -Method Post -Uri $Url -ContentType "application/json" -Body ([Text.Encoding]::UTF8.GetBytes($body)) -TimeoutSec 60
}

function Save-Pdf([string]$Key, $Body, [string]$Name) {
    $json = $Body | ConvertTo-Json -Depth 40
    $file = Join-Path $OutDir "$Name-$Locale.pdf"
    try {
        Invoke-WebRequest -Method Post -Uri "$($PdfUrl)?tenantId=$TenantId&key=$Key" -ContentType "application/json" `
            -Body ([Text.Encoding]::UTF8.GetBytes($json)) -OutFile $file -UseBasicParsing -TimeoutSec 120
        Write-Host ("  {0,-22} -> {1} ({2:N0} bytes)" -f $Key, $file, (Get-Item $file).Length)
    }
    catch {
        $detail = $_.Exception.Message
        if ($_.Exception.Response) { $detail = (New-Object IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd() }
        Write-Host "  $Key FAILED: $detail"
    }
}

$license = (Get-Json "http://localhost:8079/tl-services/v1/_search?tenantId=$TenantId&applicationNumber=$ApplicationNumber").Licenses
if (-not $license) { throw "Application $ApplicationNumber not found." }
$payments = (Get-Json "http://localhost:8095/collection-services/payments/TL/_search?tenantId=$TenantId&consumerCodes=$ApplicationNumber").Payments

Save-Pdf "tlcertificate" @{ RequestInfo = $requestInfo; Licenses = @($license) } "$ApplicationNumber-certificate"
if ($payments) { Save-Pdf "tradelicense-receipt" @{ RequestInfo = $requestInfo; Payments = @($payments[0]) } "$ApplicationNumber-receipt" }
else { Write-Host "  no payment found for $ApplicationNumber, receipt skipped" }
