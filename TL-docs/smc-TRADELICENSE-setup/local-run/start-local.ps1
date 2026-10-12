<#
Starts everything tl-services needs on this machine: Kafka, the persister and the dependent services.
See LOCAL_RUN.md in this folder for the full guide.

  $env:TL_DB_URL      = "jdbc:postgresql://<host>:5432/<database>?sslmode=require"
  $env:TL_DB_USER     = "<user>"
  $env:TL_DB_PASSWORD = "<password>"
  .\start-local.ps1                  # start (uses jars already built)
  .\start-local.ps1 -Build           # also build any jar that is missing
  .\start-local.ps1 -SkipDuesChecks  # tl-services without the SMC property / water dues checks
  .\start-local.ps1 -RealUser        # real egov-user + egov-enc-service instead of the user stub
  .\start-local.ps1 -NocObjectionDays 0   # tl-services with no waiting for objections on a health NOC (default: 7 days)

A service whose port is already listening is left alone, so the script can be re-run safely.
#>
param(
    [string]$Root = "",
    [string]$KafkaHome = "C:\Kafka\kafka_2.13-3.6.0",
    [string]$LogDir = "",
    [switch]$Build,
    [switch]$SkipDuesChecks,
    [switch]$RealUser,
    [int]$NocObjectionDays = -1,   # days objections are awaited on an offensive health NOC; -1 keeps the 7 of application.properties
    [switch]$InfraOnly      # only Kafka, MDMS and the persister (used by start-local-all.ps1)
)

$ErrorActionPreference = "Stop"
if (-not $Root) { $Root = (Resolve-Path "$PSScriptRoot\..\..\..\..\..\..").Path }
$App = Join-Path $Root "app-services"
if (-not $LogDir) { $LogDir = Join-Path $Root "local-run-logs" }
New-Item -ItemType Directory -Force $LogDir | Out-Null
$PidFile = Join-Path $LogDir "pids.txt"

foreach ($v in "TL_DB_URL", "TL_DB_USER", "TL_DB_PASSWORD") {
    if (-not [Environment]::GetEnvironmentVariable($v)) { throw "Set `$env:$v before running this script (see LOCAL_RUN.md)." }
}
if (-not $env:JAVA_HOME -or -not (Test-Path "$env:JAVA_HOME\bin\java.exe")) { throw "JAVA_HOME must point to a JDK 17." }
$Java = "$env:JAVA_HOME\bin\java.exe"

# Every service reads its database settings from these, so the values in application.properties do not matter.
# Flyway stays off: the database is shared and already has every table.
$env:SPRING_DATASOURCE_URL = $env:TL_DB_URL
$env:SPRING_DATASOURCE_USERNAME = $env:TL_DB_USER
$env:SPRING_DATASOURCE_PASSWORD = $env:TL_DB_PASSWORD
$env:SPRING_FLYWAY_ENABLED = "false"

function Test-Port([int]$Port) {
    [bool](Get-NetTCPConnection -State Listen -LocalPort $Port -ErrorAction SilentlyContinue)
}

function Wait-Port([string]$Name, [int]$Port, $Process, [int]$Seconds = 150) {
    for ($i = 0; $i -lt $Seconds; $i += 2) {
        if (Test-Port $Port) {
            $owner = (Get-NetTCPConnection -State Listen -LocalPort $Port | Select-Object -First 1).OwningProcess
            Add-Content $PidFile "$owner $Name"
            Write-Host ("  {0,-18} up on {1} (PID {2})" -f $Name, $Port, $owner)
            return
        }
        if ($Process -and $Process.HasExited) { break }
        Start-Sleep -Seconds 2
    }
    throw "$Name did not start on port $Port. See $LogDir\$Name.log"
}

function Start-Jar([string]$Name, [int]$Port, [string]$Dir, [string[]]$AppArgs, [switch]$AsSystemProperties) {
    if (Test-Port $Port) { Write-Host ("  {0,-18} already running on {1}, skipped" -f $Name, $Port); return }
    $full = Join-Path $App $Dir
    $jar = Get-ChildItem "$full\target" -Filter *.jar -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch "original|sources" } | Select-Object -First 1
    if (-not $jar) {
        if (-not $Build) { throw "$Name has no jar in $full\target. Run with -Build, or build it yourself (see LOCAL_RUN.md)." }
        Write-Host "  building $Name ..."
        Push-Location $full
        # snapshotNormalization=false stops Maven rewriting a snapshot jar that a running service has locked
        & mvn -q "-Daether.artifactResolver.snapshotNormalization=false" -DskipTests clean package
        $code = $LASTEXITCODE
        Pop-Location
        if ($code -ne 0) { throw "Build of $Name failed." }
        $jar = Get-ChildItem "$full\target" -Filter *.jar | Where-Object { $_.Name -notmatch "original|sources" } | Select-Object -First 1
    }
    # a service whose main() does not hand its arguments to Spring only sees overrides given as -Dkey=value
    $javaArgs = if ($AsSystemProperties) { @($AppArgs | ForEach-Object { $_ -replace '^--', '-D' }) + @("-jar", "target\$($jar.Name)") }
                else { @("-jar", "target\$($jar.Name)") + $AppArgs }
    $p = Start-Process -FilePath $Java -ArgumentList $javaArgs -WorkingDirectory $full `
        -RedirectStandardOutput "$LogDir\$Name.log" -RedirectStandardError "$LogDir\$Name.err" -WindowStyle Hidden -PassThru
    Wait-Port $Name $Port $p
}

function Start-Kafka {
    if (-not (Test-Path "$KafkaHome\bin\windows\kafka-server-start.bat")) { throw "Kafka not found at $KafkaHome (pass -KafkaHome)." }
    # Kafka on Windows cannot recover its data folder after the machine or the broker was stopped
    # uncleanly: it starts, then exits a little later with "all log dirs ... have failed". The local
    # broker only carries messages between the local services, so start from empty folders every time.
    if (-not (Test-Port 2181) -and -not (Test-Port 9092)) {
        foreach ($d in "C:\tmp\kafka-logs", "C:\tmp\zookeeper") {
            if (Test-Path $d) { [System.IO.Directory]::Delete($d, $true); Write-Host "  cleared $d" }
        }
    }
    if (Test-Port 2181) { Write-Host "  zookeeper          already running on 2181, skipped" }
    else {
        $z = Start-Process cmd.exe -ArgumentList "/c", "bin\windows\zookeeper-server-start.bat config\zookeeper.properties" -WorkingDirectory $KafkaHome `
            -RedirectStandardOutput "$LogDir\zookeeper.log" -RedirectStandardError "$LogDir\zookeeper.err" -WindowStyle Hidden -PassThru
        Wait-Port "zookeeper" 2181 $z 60
    }
    if (Test-Port 9092) { Write-Host "  kafka              already running on 9092, skipped" }
    else {
        # After an unclean stop ZooKeeper keeps the old broker registration for ~18s and the broker
        # exits with NodeExists, so give it a few attempts.
        for ($attempt = 1; $attempt -le 4; $attempt++) {
            # The overrides stop Kafka from compacting or deleting its log files. On Windows those file
            # renames fail after a few hours ("Failed to clean up log for __consumer_offsets") and the
            # broker shuts itself down. The data is disposable and cleared at the next start anyway.
            $k = Start-Process cmd.exe -ArgumentList "/c", "bin\windows\kafka-server-start.bat config\server.properties --override log.cleaner.enable=false --override log.retention.ms=-1" -WorkingDirectory $KafkaHome `
                -RedirectStandardOutput "$LogDir\kafka.log" -RedirectStandardError "$LogDir\kafka.err" -WindowStyle Hidden -PassThru
            try { Wait-Port "kafka" 9092 $k 90; break }
            catch {
                if ($attempt -eq 4) { throw }
                Write-Host "  kafka did not come up (attempt $attempt), retrying in 10s ..."
                Start-Sleep -Seconds 10
            }
        }
    }
}

Write-Host "Starting local trade license stack (logs: $LogDir)"
Start-Kafka

$rootUrl = $Root -replace "\\", "/"
$mdms = "http://localhost:8094/"

Start-Jar "egov-mdms-service" 8094 "core-services\egov-mdms-service" @(
    "--egov.mdms.conf.path=$rootUrl/mdms/data",
    "--masters.config.url=file:$rootUrl/mdms/master-config.json")

# Persister configs come from the configs repository, not from the copies inside the services
$cfg = "file:///$rootUrl/configs-scm/configs/egov-persister"
Start-Jar "egov-persister" 8090 "core-services\egov-persister" @(
    "--server.port=8090",
    "--egov.persist.yml.repo.path=$cfg/tradelicense.yml,$cfg/tl-calculation-persister.yml,$cfg/tl-billing-slab-persister.yml,$cfg/egov-workflow-v2-persister.yml")
if ($InfraOnly) { return }

if ($RealUser) {
    # Needs redis on 6379 and the environment's master.password / master.salt / master.initialvector
    # in egov-enc-service's application.properties (rebuild egov-enc-service after changing them).
    Start-Jar "egov-enc-service" 1234 "core-services\egov-enc-service" @("--egov.mdms.host=$mdms")
    Start-Jar "egov-user" 8081 "core-services\egov-user" @("--mdms.host=$mdms", "--egov.mdms.host=$mdms", "--egov.enc.host=http://localhost:1234/")
    $user = "http://localhost:8081/"
}
else {
    if (Test-Port 8091) { Write-Host "  user-stub          already running on 8091, skipped" }
    else {
        $s = Start-Process node -ArgumentList "`"$PSScriptRoot\user-stub.js`"" -RedirectStandardOutput "$LogDir\user-stub.log" `
            -RedirectStandardError "$LogDir\user-stub.err" -WindowStyle Hidden -PassThru
        Wait-Port "user-stub" 8091 $s 20
    }
    $user = "http://localhost:8091/"
}

# property-services (8087) and ws-services (8089) stand-ins, used by the checks on APPLY
if (Test-Port 8087) { Write-Host "  property-stub      already running on 8087, skipped" }
else {
    $ps = Start-Process node -ArgumentList "`"$PSScriptRoot\property-stub.js`"" -RedirectStandardOutput "$LogDir\property-stub.log" `
        -RedirectStandardError "$LogDir\property-stub.err" -WindowStyle Hidden -PassThru
    Wait-Port "property-stub" 8087 $ps 20
}

Start-Jar "egov-idgen" 8088 "core-services\egov-idgen" @("--mdms.service.host=$mdms")

Start-Jar "egov-location" 8086 "core-services\egov-location" @(
    "--server.port=8086", "--egov.services.egov_mdms.hostname=$mdms", "--spring.jpa.showSql=false")

Start-Jar "egov-workflow-v2" 8280 "core-services\egov-workflow-v2" @(
    "--egov.mdms.host=http://localhost:8094", "--egov.mdms.search.endpoint=/egov-mdms-service/v1/_search",
    "--egov.statelevel.tenantid=pg", "--egov.user.host=$user")

Start-Jar "billing-service" 8082 "business-services\billing-service" @(
    "--server.port=8082", "--egov.mdms.host=$mdms", "--workflow.host=http://localhost:8280/",
    "--user.service.hostname=$user", "--egov.idgen.hostname=http://localhost:8088/",
    "--egov.localization.host=http://localhost:8087/", "--egov.apportion.host=http://localhost:8093/")

# Payment: collection-services creates the receipt and publishes the payment event that
# billing-service (demand paid) and tl-services (license approved) consume.
Start-Jar "egov-apportion-service" 8093 "business-services\egov-apportion-service" @(
    "--server.port=8093", "--egov.mdms.host=http://localhost:8094")

$unused = "http://localhost:8087/"   # finance, pdf, localization: not needed for a counter payment
Start-Jar "collection-services" 8095 "business-services\collection-services" @(
    "--server.port=8095", "--egov.mdms.host=$mdms", "--egov.idgen.hostname=http://localhost:8088/",
    "--egov.apportion.service.host=http://localhost:8093/", "--egov.services.billing_service.hostname=http://localhost:8082/",
    "--user.service.host=$user", "--spring.jpa.show-sql=false",
    "--egov.localization.host=$unused", "--egov.egfcommonmasters.hostname=$unused", "--egov.egfmasters.hostname=$unused",
    "--egov.instrument.hostname=$unused", "--egov.egfmaster.service.host=$unused", "--egov.services.hostname=$unused",
    "--coll.notification.ui.host=$unused", "--egov.url.shortner.host=$unused") -AsSystemProperties

Start-Jar "tl-calculator" 8085 "municipal-services\tl-calculator" @(
    "--egov.mdms.host=$mdms", "--egov.billingservice.host=http://localhost:8082/", "--egov.tradelicense.host=http://localhost:8079/")

# Every host is set explicitly: the defaults in application.properties point at https://dev.digit.org/
$tl = @(
    "--egov.mdms.host=$mdms", "--mdms.v2.host=$mdms",
    "--workflow.context.path=http://localhost:8280/", "--workflow.workDir.path=http://localhost:8280/",
    "--egov.tl.calculator.host=http://localhost:8085/", "--egov.billingservice.host=http://localhost:8082/",
    "--egov.user.host=$user", "--egov.idgen.host=http://localhost:8088/", "--egov.location.host=http://localhost:8086/",
    "--egov.property.service.host=http://localhost:8087/", "--egov.ws.service.host=http://localhost:8089/",
    "--egov.localization.host=http://localhost:8087/", "--egov.url.shortner.host=http://localhost:8087/",
    "--state.level.tenant.id=pg",
    "--notification.sms.enabled.forTL=false", "--notification.sms.enabled.forTLRENEWAL=false", "--notification.email.enabled=false",
    "--egov.user.event.notification.enabledForTL=false", "--egov.user.event.notification.enabledForTLRenewal=false")
if ($SkipDuesChecks) { $tl += @("--tl.smc.property.dues.check.enabled=false", "--tl.smc.water.dues.check.enabled=false") }
if ($NocObjectionDays -ge 0) { $tl += "--tl.smc.noc.objection.window.days=$NocObjectionDays" }
Start-Jar "tl-services" 8079 "municipal-services\tl-services" $tl

Write-Host ""
Write-Host "Ready. Trade license API: http://localhost:8079/tl-services/v1/_create"
Write-Host "Stop everything this script started with .\stop-local.ps1"
