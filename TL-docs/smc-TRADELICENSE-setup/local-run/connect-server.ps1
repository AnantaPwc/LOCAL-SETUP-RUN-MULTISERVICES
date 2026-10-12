<#
Connects the local stack to the services of the deployed environment that cannot run locally, by
port-forwarding them from the Kubernetes cluster to localhost:

  egov-user          -> localhost:8081   (real users; it uses the cluster's own egov-enc-service)
  egov-enc-service   -> localhost:1234
  property-services  -> localhost:8087
  ws-services        -> localhost:8089
  egov-mdms-service  -> localhost:8094   (only with -Mdms: the master data as deployed on the server)

  .\connect-server.ps1 -Mdms         # then: .\start-local.ps1 -RealUser
  .\connect-server.ps1 -Stop

start-local.ps1 skips whatever is already listening, so with these forwards in place it starts neither the
user / property stand-ins nor a local MDMS. The cluster must be running and reachable with the kubeconfig.
#>
param(
    [string]$KubeConfig = "C:\Users\.kube\config",
    [string]$Namespace = "egov",
    [string]$Root = "",
    [switch]$Mdms,
    [switch]$Stop
)

$ErrorActionPreference = "Stop"
if (-not $Root) { $Root = (Resolve-Path "$PSScriptRoot\..\..\..\..\..\..").Path }
$LogDir = Join-Path $Root "local-run-logs"
New-Item -ItemType Directory -Force $LogDir | Out-Null
$PidFile = Join-Path $LogDir "portforward-pids.txt"

if ($Stop) {
    if (Test-Path $PidFile) {
        foreach ($line in Get-Content $PidFile) {
            $procId, $name = $line -split " ", 2
            $p = Get-Process -Id $procId -ErrorAction SilentlyContinue
            if ($p -and $p.ProcessName -eq "kubectl") { Stop-Process -Id $procId -Force -Confirm:$false; Write-Host "  stopped forward of $name" }
        }
        Remove-Item $PidFile -Confirm:$false
    }
    return
}

$env:KUBECONFIG = $KubeConfig
$forwards = @(
    @{ svc = "egov-enc-service"; port = 1234 },
    @{ svc = "egov-user"; port = 8081 },
    @{ svc = "property-services"; port = 8087 },
    @{ svc = "ws-services"; port = 8089 }
)
if ($Mdms) { $forwards += @{ svc = "egov-mdms-service"; port = 8094 } }

foreach ($f in $forwards) {
    if (Get-NetTCPConnection -State Listen -LocalPort $f.port -ErrorAction SilentlyContinue) {
        Write-Host ("  {0,-18} port {1} already in use, skipped" -f $f.svc, $f.port)
        continue
    }
    $p = Start-Process kubectl -ArgumentList "port-forward", "svc/$($f.svc)", "$($f.port):8080", "-n", $Namespace, "--address", "127.0.0.1" `
        -RedirectStandardOutput "$LogDir\pf-$($f.svc).log" -RedirectStandardError "$LogDir\pf-$($f.svc).err" -WindowStyle Hidden -PassThru
    Add-Content $PidFile "$($p.Id) $($f.svc)"
    $up = $false
    for ($i = 0; $i -lt 15; $i++) {
        Start-Sleep -Seconds 1
        if (Get-NetTCPConnection -State Listen -LocalPort $f.port -ErrorAction SilentlyContinue) { $up = $true; break }
        if ($p.HasExited) { break }
    }
    if (-not $up) { throw "Could not forward $($f.svc): $(Get-Content "$LogDir\pf-$($f.svc).err" -Raw)" }
    Write-Host ("  {0,-18} -> localhost:{1}" -f $f.svc, $f.port)
}
