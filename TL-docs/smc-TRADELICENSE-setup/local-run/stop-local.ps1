<#
Stops the processes that start-local.ps1 started (it records them in <LogDir>\pids.txt).
Services that were already running when start-local.ps1 ran are not touched.

  .\stop-local.ps1              # stop the services, leave Kafka and ZooKeeper running
  .\stop-local.ps1 -IncludeKafka
#>
param(
    [string]$Root = "",
    [string]$LogDir = "",
    [switch]$IncludeKafka
)

if (-not $Root) { $Root = (Resolve-Path "$PSScriptRoot\..\..\..\..\..\..").Path }
if (-not $LogDir) { $LogDir = Join-Path $Root "local-run-logs" }
$PidFile = Join-Path $LogDir "pids.txt"
if (-not (Test-Path $PidFile)) { Write-Host "Nothing to stop: $PidFile not found."; return }

$entries = @(Get-Content $PidFile | Where-Object { $_ })
[array]::Reverse($entries)
$kept = @()
foreach ($e in $entries) {
    $procId, $name = $e -split " ", 2
    if (-not $IncludeKafka -and ($name -eq "kafka" -or $name -eq "zookeeper")) { $kept += $e; continue }
    $p = Get-Process -Id $procId -ErrorAction SilentlyContinue
    # the PID may have been reused since; only stop the kind of process the script starts
    if ($p -and $p.ProcessName -in "java", "node") {
        Stop-Process -Id $procId -Force -Confirm:$false
        Write-Host ("  stopped {0,-18} (PID {1})" -f $name, $procId)
    }
    else { Write-Host ("  {0,-18} not running" -f $name) }
}
[array]::Reverse($kept)
if ($kept.Count) { Set-Content $PidFile $kept } else { Remove-Item $PidFile -Confirm:$false }
