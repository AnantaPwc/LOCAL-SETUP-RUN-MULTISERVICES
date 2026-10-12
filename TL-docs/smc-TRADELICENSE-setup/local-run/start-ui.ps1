<#
Runs the React UI from source on http://localhost:3000 against the local backend.

  .\start-ui.ps1            # start the API proxy (3001) and the React dev server (3000)
  .\start-ui.ps1 -Stop

Needs, once (and again after pulling or switching branch):
  - portable Node 14 with yarn in D:\tools\node-v14.21.3-win-x64
  - in <UiRoot>\micro-ui-internals:  yarn install --ignore-engines ; yarn build     (builds the local packages)
  - in <UiRoot>:                     yarn install --ignore-engines
Needs running: connect-server.ps1 -Mdms and start-local.ps1 -RealUser.

Browser -> React dev server (3000) -> ui-proxy.js (3001) -> local services, or the deployed server.
#>
param(
    [string]$UiRoot = "",   # default: frontend\upyog-ui\web of this repository
    [string]$NodeDir = "D:\tools\node-v14.21.3-win-x64",
    [string]$Server = "https://sangamner-demo.ddns.net",
    [string]$LogDir = "",
    [switch]$LocalOnly,     # every API from this machine (start-local-all.ps1), nothing from $Server
    [switch]$Stop
)

$ErrorActionPreference = "Stop"
if (-not $UiRoot) { $UiRoot = (Resolve-Path "$PSScriptRoot\..\..\..\..\..\frontend\upyog-ui\web").Path }
if (-not $LogDir) { $LogDir = Join-Path (Resolve-Path "$PSScriptRoot\..\..\..\..\..\..").Path "local-run-logs" }
New-Item -ItemType Directory -Force $LogDir | Out-Null

function Stop-Port([int]$Port, [string]$Name) {
    $c = Get-NetTCPConnection -State Listen -LocalPort $Port -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($c -and (Get-Process -Id $c.OwningProcess).ProcessName -eq "node") {
        Stop-Process -Id $c.OwningProcess -Force -Confirm:$false
        Write-Host "  stopped $Name on $Port"
    }
}

if ($Stop) { Stop-Port 3000 "React dev server"; Stop-Port 3001 "ui-proxy"; return }

if (-not (Test-Path "$NodeDir\yarn.cmd")) { throw "Node 14 with yarn not found in $NodeDir." }
$env:Path = "$NodeDir;$env:Path"

if (Get-NetTCPConnection -State Listen -LocalPort 3001 -ErrorAction SilentlyContinue) { Write-Host "  ui-proxy           already running on 3001, skipped" }
else {
    $env:UI_PROXY_PORT = "3001"
    $env:UI_PROXY_SERVER = $Server
    $env:UI_PROXY_LOCAL_ONLY = "$([bool]$LocalOnly)".ToLower()
    Start-Process node -ArgumentList "`"$PSScriptRoot\ui-proxy.js`"" -RedirectStandardOutput "$LogDir\ui-proxy.log" -RedirectStandardError "$LogDir\ui-proxy.err" -WindowStyle Hidden | Out-Null
    Write-Host "  ui-proxy           started on 3001"
}

if (Get-NetTCPConnection -State Listen -LocalPort 3000 -ErrorAction SilentlyContinue) { Write-Host "  React dev server   already running on 3000, skipped"; return }

# Settings the app would otherwise read from a .env file. The app in <UiRoot> (web) is the one the
# deployed image is built from; its setupProxy.js sends the API paths to REACT_APP_PROXY_URL.
$env:NODE_OPTIONS = "--max-old-space-size=6144"
$env:SKIP_PREFLIGHT_CHECK = "true"
$env:BROWSER = "none"
$env:PORT = "3000"
$env:REACT_APP_PROXY_URL = "http://localhost:3001"
$env:REACT_APP_STATE_LEVEL_TENANT_ID = "pg"

$log = "$LogDir\ui-dev-server.log"
if (Test-Path $log) { Clear-Content $log }
Start-Process -FilePath "$NodeDir\yarn.cmd" -ArgumentList "start" -WorkingDirectory $UiRoot `
    -RedirectStandardOutput $log -RedirectStandardError "$LogDir\ui-dev-server.err" -WindowStyle Hidden | Out-Null
Write-Host "  React dev server   starting (first compile takes 1-3 minutes) ..."
for ($i = 0; $i -lt 120; $i++) {
    Start-Sleep -Seconds 4
    if (Select-String -Path $log -Pattern "Compiled|Failed to compile" -Quiet -ErrorAction SilentlyContinue) { break }
}
if (Select-String -Path $log -Pattern "Failed to compile" -Quiet) { throw "The UI failed to compile. See $log" }
Write-Host ""
Write-Host "Open  http://localhost:3000/upyog-ui/citizen  or  http://localhost:3000/upyog-ui/employee"
