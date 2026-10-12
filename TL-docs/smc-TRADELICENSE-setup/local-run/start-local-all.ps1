<#
Starts the whole trade license stack on this machine, with nothing borrowed from the deployed server
except its database, its S3 bucket and its configuration values:

  start-local.ps1 -RealUser   Kafka, MDMS, persister, idgen, location, workflow, billing, apportion,
                              collection, tl-calculator, tl-services
  and in addition             egov-enc-service 1234, egov-user 8081, egov-otp 8084, user-otp 8092,
                              egov-localization 8096, egov-accesscontrol 8097, egov-filestore 8083,
                              egov-hrms 9999, property-services 8087, ws-services 8089

  .\start-local-all.ps1            # start (uses jars already built)
  .\start-local-all.ps1 -Build     # also build any jar that is missing
  .\stop-local.ps1                 # stops all of it (Kafka stays up)

The database login, the encryption master keys and the S3 keys are read from the cluster with kubectl
each time and handed to the services as environment variables only; they are not written to any file.
The cluster must therefore be reachable when this script starts (not afterwards). Needs Redis on 6379.
A service whose port is already listening is left alone, so the script can be re-run safely.
#>
param(
    [string]$Root = "",
    [string]$KubeConfig = "C:\Users\.kube\config",
    [string]$Namespace = "egov",
    [int]$NocObjectionDays = -1,   # passed to start-local.ps1: days objections are awaited on an offensive health NOC
    [switch]$Build
)

$ErrorActionPreference = "Stop"
if (-not $Root) { $Root = (Resolve-Path "$PSScriptRoot\..\..\..\..\..\..").Path }
$App = Join-Path $Root "app-services"
$LogDir = Join-Path $Root "local-run-logs"
New-Item -ItemType Directory -Force $LogDir | Out-Null
$PidFile = Join-Path $LogDir "pids.txt"
if (-not $env:JAVA_HOME -or -not (Test-Path "$env:JAVA_HOME\bin\java.exe")) { throw "JAVA_HOME must point to a JDK 17." }
$Java = "$env:JAVA_HOME\bin\java.exe"
if (-not (Get-NetTCPConnection -State Listen -LocalPort 6379 -ErrorAction SilentlyContinue)) { throw "Redis is not running on 6379." }

# ---- values from the cluster -------------------------------------------------------------------
$env:KUBECONFIG = $KubeConfig
function Get-ClusterJson([string]$Kind, [string]$Name) {
    $text = kubectl get $Kind $Name -n $Namespace -o json --request-timeout=30s
    if ($LASTEXITCODE -ne 0 -or -not $text) { throw "Could not read $Kind/$Name from the cluster. Is it running and reachable?" }
    ($text | Out-String | ConvertFrom-Json)
}
function Get-SecretValues([string]$Name) {
    $out = @{}
    foreach ($p in (Get-ClusterJson "secret" $Name).data.PSObject.Properties) {
        $out[$p.Name] = [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($p.Value))
    }
    $out
}
Write-Host "Reading database, encryption and file store settings from the cluster ..."
$db = Get-SecretValues "db"
$enc = Get-SecretValues "egov-enc-service"
$s3 = Get-SecretValues "egov-filestore"
$env:TL_DB_URL = (Get-ClusterJson "configmap" "egov-config").data.'db-url'
$env:TL_DB_USER = $db['username']
$env:TL_DB_PASSWORD = $db['password']
$userEnv = (Get-ClusterJson "deployment" "egov-user").spec.template.spec.containers[0].env
$fixedOtp = ($userEnv | Where-Object { $_.name -eq "CITIZEN_LOGIN_PASSWORD_OTP_FIXED_VALUE" }).value

$env:SPRING_DATASOURCE_URL = $env:TL_DB_URL
$env:SPRING_DATASOURCE_USERNAME = $env:TL_DB_USER
$env:SPRING_DATASOURCE_PASSWORD = $env:TL_DB_PASSWORD
$env:SPRING_FLYWAY_ENABLED = "false"     # shared database: no service may change the schema

# ---- helpers -------------------------------------------------------------------------------------
function Test-Port([int]$Port) { [bool](Get-NetTCPConnection -State Listen -LocalPort $Port -ErrorAction SilentlyContinue) }

# $Secrets are given to this one process only, as environment variables
function Start-Service-Jar([string]$Name, [int]$Port, [string]$Dir, [string[]]$AppArgs, [hashtable]$Secrets = @{}) {
    if (Test-Port $Port) { Write-Host ("  {0,-18} already running on {1}, skipped" -f $Name, $Port); return }
    $full = Join-Path $App $Dir
    $jar = Get-ChildItem "$full\target" -Filter *.jar -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch "original|sources" } | Select-Object -First 1
    if (-not $jar) {
        if (-not $Build) { throw "$Name has no jar in $full\target. Run with -Build." }
        Write-Host "  building $Name ..."
        Push-Location $full
        & mvn -q "-Daether.artifactResolver.snapshotNormalization=false" -DskipTests clean package
        $code = $LASTEXITCODE
        Pop-Location
        if ($code -ne 0) { throw "Build of $Name failed." }
        $jar = Get-ChildItem "$full\target" -Filter *.jar | Where-Object { $_.Name -notmatch "original|sources" } | Select-Object -First 1
    }
    foreach ($k in $Secrets.Keys) { [Environment]::SetEnvironmentVariable($k, $Secrets[$k], "Process") }
    try {
        $p = Start-Process -FilePath $Java -ArgumentList (@("-Xmx512m", "-jar", "target\$($jar.Name)") + $AppArgs) -WorkingDirectory $full `
            -RedirectStandardOutput "$LogDir\$Name.log" -RedirectStandardError "$LogDir\$Name.err" -WindowStyle Hidden -PassThru
    }
    finally { foreach ($k in $Secrets.Keys) { [Environment]::SetEnvironmentVariable($k, $null, "Process") } }
    for ($i = 0; $i -lt 240; $i += 2) {
        if (Test-Port $Port) {
            $owner = (Get-NetTCPConnection -State Listen -LocalPort $Port | Select-Object -First 1).OwningProcess
            Add-Content $PidFile "$owner $Name"
            Write-Host ("  {0,-18} up on {1} (PID {2})" -f $Name, $Port, $owner)
            return
        }
        if ($p.HasExited) { break }
        Start-Sleep -Seconds 2
    }
    throw "$Name did not start on port $Port. See $LogDir\$Name.log"
}

$mdms = "http://localhost:8094/"
$user = "http://localhost:8081/"
$localization = "http://localhost:8096/"
$filestore = "http://localhost:8083/"

# ---- before the base stack: what it must find already listening ----------------------------------
# egov-enc-service reads MDMS while it starts, so Kafka, MDMS and the persister come first
& "$PSScriptRoot\start-local.ps1" -InfraOnly -Root $Root -Build:$Build
Write-Host "Starting the user, encryption and property services"
Start-Service-Jar "egov-enc-service" 1234 "core-services\egov-enc-service" @("--egov.mdms.host=$mdms", "--state.level.tenant.id=pg") @{
    MASTER_PASSWORD = $enc['master.password']; MASTER_SALT = $enc['master.salt']; MASTER_INITIALVECTOR = $enc['master.initialvector'] }

Start-Service-Jar "egov-user" 8081 "core-services\egov-user" @(
    "--mdms.host=$mdms", "--egov.mdms.host=$mdms", "--egov.enc.host=http://localhost:1234/",
    "--egov.otp.host=http://localhost:8084/", "--egov.services.accesscontrol.host=http://localhost:8097/",
    "--egov.filestore.host=$filestore", "--egov.user.host=http://localhost:8081", "--egov.localization.host=$localization",
    "--state.level.tenant.id=pg", "--egov.state.level.tenant.id=pg", "--decryption.abac.enabled=false",
    "--citizen.login.password.otp.enabled=true", "--employee.login.password.otp.enabled=false",
    "--citizen.login.password.otp.fixed.enabled=true", "--access.token.validity.in.minutes=6000",
    "--refresh.token.validity.in.minutes=6000", "--default.password.expiry.in.days=900",
    "--roles.state.level.enabled=true", "--citizen.registration.withlogin.enabled=true") @{
    CITIZEN_LOGIN_PASSWORD_OTP_FIXED_VALUE = $fixedOtp }

# The base script starts its property / water stand-in only when 8087 is free, so the real services go first.
# A stand-in left over from an earlier start-local.ps1 run is replaced.
foreach ($port in 8087, 8089) {
    $c = Get-NetTCPConnection -State Listen -LocalPort $port -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($c -and (Get-Process -Id $c.OwningProcess).ProcessName -eq "node") { Stop-Process -Id $c.OwningProcess -Force -Confirm:$false; Start-Sleep -Seconds 1 }
}
Start-Service-Jar "property-services" 8087 "municipal-services\property-services" @(
    "--server.port=8087", "--mdms.v2.host=$mdms", "--mdms.v2.search.endpoint=egov-mdms-service/v1/_search",
    "--egov.mdms.host=$mdms", "--egov.idgen.host=http://localhost:8088/", "--workflow.host=http://localhost:8280/",
    "--egov.user.host=$user", "--egov.location.host=http://localhost:8086/", "--egov.localization.host=$localization",
    "--egov.enc.host=http://localhost:1234/", "--egbs.host=http://localhost:8082/", "--state.level.tenant.id=pg",
    "--notif.sms.enabled=false", "--notif.email.enabled=false", "--egov.user.event.notification.enabled=false")

# ---- the base stack --------------------------------------------------------------------------------
& "$PSScriptRoot\start-local.ps1" -RealUser -Root $Root -Build:$Build -NocObjectionDays $NocObjectionDays

# ---- what the browser UI needs besides ------------------------------------------------------------
Write-Host "Starting the services the UI calls"
Start-Service-Jar "ws-services" 8089 "municipal-services\ws-services" @(
    "--server.port=8089", "--egov.mdms.host=$mdms", "--egov.property.service.host=http://localhost:8087/",
    "--egov.billing.service.host=http://localhost:8082/", "--egov.idgen.host=http://localhost:8088/",
    "--egov.localization.host=$localization", "--egov.user.host=$user", "--egov.filestore.host=$filestore",
    "--egov.collection.host=http://localhost:8095/", "--egov.enc.host=http://localhost:1234/",
    "--workflow.context.path=http://localhost:8280/", "--state.level.tenant.id=pg",
    "--notification.sms.enabled=false", "--notification.email.enabled=false", "--egov.user.event.notification.enabled=false")

Start-Service-Jar "egov-otp" 8084 "core-services\egov-otp" @("--server.port=8084")
Start-Service-Jar "user-otp" 8092 "core-services\user-otp" @(
    "--server.port=8092", "--otp.host=http://localhost:8084/otp/", "--user.host=$user", "--egov.localisation.host=$localization")
Start-Service-Jar "egov-localization" 8096 "core-services\egov-localization" @("--server.port=8096")
Start-Service-Jar "egov-accesscontrol" 8097 "core-services\egov-accesscontrol" @("--server.port=8097", "--egov.mdms.host=$mdms")
Start-Service-Jar "egov-filestore" 8083 "core-services\egov-filestore" @(
    "--server.port=8083", "--isS3Enabled=true", "--isNfsStorageEnabled=false", "--isAzureStorageEnabled=false",
    "--is.bucket.fixed=true", "--fixed.bucketname=nugp-demo-assets", "--presigned.url.expiry.time.in.secs=3600") @{
    AWS_KEY = $s3['awskey']; AWS_SECRETKEY = $s3['awssecretkey'] }
Start-Service-Jar "egov-hrms" 9999 "business-services\egov-hrms" @(
    "--server.port=9999", "--egov.mdms.host=$mdms", "--egov.filestore.host=$filestore", "--egov.localization.host=$localization",
    "--egov.idgen.host=http://localhost:8088/", "--egov.user.host=$user", "--egov.otp.host=http://localhost:8084/",
    "--state.level.tenant.id=pg", "--parent.level.tenant.id=pg", "--egov.services.data_sync_employee.required=false")

# pdf-service (node) with the SMC receipt and certificate configs, as preview-pdf.ps1 -Rebuild runs it,
# but with the local localization and file store. "npm install" must have been done once in its folder.
if (Test-Port 8098) { Write-Host "  pdf-service        already running on 8098, skipped" }
else {
    $pdfDir = Join-Path $App "core-services\pdf-service"
    $preview = Join-Path $env:TEMP "smc-pdf-preview"
    node (Join-Path $PSScriptRoot "build-pdf-configs.js") (Join-Path $Root "configs-scm\configs\pdf-service") $preview
    if ($LASTEXITCODE -ne 0) { throw "build-pdf-configs.js failed" }
    $pv = $preview -replace '\\', '/'
    $pdfEnv = @{
        DATA_CONFIG_URLS = "file://$pv/data-config/tradelicense-receipt.json,file://$pv/data-config/tlcertificate.json,file://$pv/data-config/tl-loi.json"
        FORMAT_CONFIG_URLS = "file://$pv/format-config/tradelicense-receipt.json,file://$pv/format-config/tlcertificate.json,file://$pv/format-config/tl-loi.json"
        SERVER_PORT = "8098"; KAFKA_BROKER_HOST = "localhost:9092"; DEFAULT_LOCALISATION_TENANT = "pg"
        EGOV_LOCALISATION_HOST = $localization; EGOV_FILESTORE_SERVICE_HOST = $filestore
        EGOV_HOST = "http://localhost:3001/"; EGOV_EXTERNAL_HOST = "http://localhost:3001/"
        # the job table of pdf-service is not in the shared database; a PDF is still returned without it
        DB_NAME = "digit"; DB_USER = "postgres"; DB_PASSWORD = "postgres"
    }
    foreach ($k in $pdfEnv.Keys) { [Environment]::SetEnvironmentVariable($k, $pdfEnv[$k], "Process") }
    $log = "$LogDir\pdf-service.log"
    $p = Start-Process -FilePath (Join-Path $pdfDir "node_modules\.bin\babel-node.cmd") -ArgumentList "src", "--presets", "es2015,stage-0" `
        -WorkingDirectory $pdfDir -RedirectStandardOutput $log -RedirectStandardError "$LogDir\pdf-service.err" -WindowStyle Hidden -PassThru
    foreach ($k in $pdfEnv.Keys) { [Environment]::SetEnvironmentVariable($k, $null, "Process") }
    for ($i = 0; $i -lt 60 -and -not (Test-Port 8098); $i++) { Start-Sleep -Seconds 2 }
    if (-not (Test-Port 8098)) { throw "pdf-service did not start, see $log" }
    $owner = (Get-NetTCPConnection -State Listen -LocalPort 8098 | Select-Object -First 1).OwningProcess
    Add-Content $PidFile "$owner pdf-service"
    Write-Host ("  {0,-18} up on {1} (PID {2})" -f "pdf-service", 8098, $owner)
}

Write-Host ""
Write-Host "Ready. Start the browser UI with .\start-ui.ps1 -LocalOnly"
