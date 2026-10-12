<#
Loads the workflow definitions of the Sangamner services CLEAN_CERT, HEALTH_NOC and ADV_PERM
(src\main\resources\Workflows\<SERVICE>.json) for the state tenant, through the workflow service.

  .\load-permit-workflows.ps1            # shows what is loaded and what would be created; writes nothing
  .\load-permit-workflows.ps1 -Create    # creates the missing ones

This is one-time setup data in the database (tables eg_wf_businessservice_v2, eg_wf_state_v2, eg_wf_action_v2).
The database is shared with the deployed environment: run -Create only when that is intended.
A definition that is already loaded is left as it is.

The workflow service caches its searches: right after -Create a search for the state tenant can still answer
"not loaded" until that service is restarted. The definitions work at once for the city tenant.
#>
param(
    [switch]$Create,
    [string[]]$Services = @("CLEAN_CERT", "HEALTH_NOC", "ADV_PERM"),
    [string]$StateTenantId = "pg",
    [string]$WorkflowUrl = "http://localhost:8280/egov-workflow-v2/egov-wf/businessservice"
)

$ErrorActionPreference = "Stop"

# A real employee (TLSU1 of pg.smc), never a made-up uuid: it is stored as the creator of the definition
$requestInfo = @{
    apiId = "Rainmaker"; authToken = "not-checked-locally"; msgId = "local|en_IN"
    userInfo = @{ id = 10059; uuid = "73e6bb90-e1d0-4835-99d5-adc277877af6"; userName = "TLSU1"; name = "TLSU1"; type = "EMPLOYEE"; tenantId = $StateTenantId
        roles = @(@{ code = "SUPERUSER"; name = "SUPERUSER"; tenantId = $StateTenantId }) }
}

function Invoke-Api([string]$Url, [string]$Json) {
    try {
        $r = Invoke-WebRequest -Method Post -Uri $Url -ContentType "application/json" -Body ([Text.Encoding]::UTF8.GetBytes($Json)) -UseBasicParsing -TimeoutSec 120
        return ($r.Content | ConvertFrom-Json)
    }
    catch {
        $detail = $_.Exception.Message
        if ($_.Exception.Response) { $detail = (New-Object IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd() }
        throw "$Url failed: $detail"
    }
}

foreach ($service in $Services) {
    $found = Invoke-Api "$WorkflowUrl/_search?tenantId=$StateTenantId&businessServices=$service" (@{ RequestInfo = $requestInfo } | ConvertTo-Json -Depth 10)
    if (@($found.BusinessServices).Count -gt 0) {
        Write-Host ("{0,-11} already loaded for {1}: {2} states" -f $service, $StateTenantId, @($found.BusinessServices[0].states).Count)
        continue
    }

    $definition = Get-Content (Join-Path $PSScriptRoot "..\..\..\src\main\resources\Workflows\$service.json") -Raw | ConvertFrom-Json
    $definition.RequestInfo = $requestInfo
    foreach ($businessService in $definition.BusinessServices) { $businessService.tenantId = $StateTenantId }
    $states = @($definition.BusinessServices[0].states)
    if (-not $Create) {
        Write-Host ("{0,-11} not loaded. -Create would add it for {1}: {2} states, {3} actions" -f $service, $StateTenantId, $states.Count, @($states.actions | Where-Object { $_ }).Count)
        continue
    }

    $created = Invoke-Api "$WorkflowUrl/_create" ($definition | ConvertTo-Json -Depth 30)
    Write-Host ("{0,-11} created for {1}: {2} states" -f $service, $StateTenantId, @($created.BusinessServices[0].states).Count)
}
