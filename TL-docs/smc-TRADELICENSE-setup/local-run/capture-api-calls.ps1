<#
Runs one Permanent (TL_NEW) application from INITIATE to APPROVED on the local stack and records, for every step,
the request sent, the response received and the calls tl-services made to other services.

  .\capture-api-calls.ps1

Output: api-samples\NN-<step>-request.json / -response.json and API_CALLS.md in this folder.
#>
param(
    [string]$PropertyId = "PG-PT-1013-008993",
    [string]$TenantId = "pg.smc",
    [string]$KafkaHome = "C:\Kafka\kafka_2.13-3.6.0",
    [string]$BaseUrl = "http://localhost:8079/tl-services/v1",
    [string]$LogDir = ""
)

$ErrorActionPreference = "Stop"
if (-not $LogDir) { $LogDir = Join-Path (Resolve-Path "$PSScriptRoot\..\..\..\..\..\..").Path "local-run-logs" }
$TlLog = Join-Path $LogDir "tl-services.log"
$Out = Join-Path $PSScriptRoot "api-samples"
New-Item -ItemType Directory -Force $Out | Out-Null
$Steps = New-Object System.Collections.ArrayList
$Tick = '```'

function New-RequestInfo([string]$Type, [string]$Role, [string]$RoleTenant) {
    $info = if ($Type -eq "CITIZEN") {
        [ordered]@{ id = 17253; uuid = "57a3e9c0-fc9e-480c-bf12-2d6a964d134c"; userName = "8908011908"; name = "OWNER"; mobileNumber = "8908011908"; type = "CITIZEN"; tenantId = "pg" }
    } else {
        [ordered]@{ id = 1; uuid = "local-test-employee"; userName = "LOCALEMP"; name = "Local Test Employee"; mobileNumber = "9999999999"; type = "EMPLOYEE"; tenantId = $TenantId }
    }
    $info.roles = @([ordered]@{ code = $Role; name = $Role; tenantId = $RoleTenant })
    [ordered]@{ apiId = "Rainmaker"; authToken = "not-checked-locally"; msgId = "local|en_IN"; userInfo = $info }
}

function Send([string]$Path, $Body) {
    $json = $Body | ConvertTo-Json -Depth 30
    try {
        $r = Invoke-WebRequest -Method Post -Uri "$BaseUrl/$Path" -ContentType "application/json" -Body ([Text.Encoding]::UTF8.GetBytes($json)) -UseBasicParsing -TimeoutSec 120
        return @{ request = $json; status = [int]$r.StatusCode; response = ($r.Content | ConvertFrom-Json) }
    }
    catch {
        $detail = $_.Exception.Message
        if ($_.Exception.Response) { $detail = (New-Object IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd() }
        throw "$Path failed: $detail"
    }
}

function Get-License {
    for ($i = 0; $i -lt 15; $i++) {
        $s = Send "_search?tenantId=$TenantId&applicationNumber=$script:AppNo" ([ordered]@{ RequestInfo = $script:Citizen })
        if (@($s.response.Licenses).Count -eq 1 -and $s.response.Licenses[0]) { return $s }
        Start-Sleep -Seconds 2
    }
    throw "Application $script:AppNo not found"
}

function Wait-Status([string]$Expected) {
    for ($i = 0; $i -lt 20; $i++) {
        $s = Get-License
        if ($s.response.Licenses[0].status -eq $Expected) { return $s }
        Start-Sleep -Seconds 2
    }
    throw "Application $script:AppNo did not reach $Expected"
}

# calls tl-services made to other services since the given log line
function Get-InternalCalls([int]$FromLine) {
    Start-Sleep -Seconds 3
    @(Get-Content $TlLog | Select-Object -Skip $FromLine | Select-String -Pattern "Sending request to (\S+)" |
        ForEach-Object { $_.Matches[0].Groups[1].Value })
}

function Save-Step([string]$Name, [string]$Title, [string]$Actor, [string]$Method, [string]$Url, [string]$Request, $Response, [string[]]$Calls, [string]$Note) {
    $n = "{0:d2}-{1}" -f ($Steps.Count + 1), $Name
    if ($Request) { Set-Content "$Out\$n-request.json" $Request -Encoding utf8 }
    $responseJson = if ($Response) { $Response | ConvertTo-Json -Depth 30 } else { "" }
    if ($responseJson) { Set-Content "$Out\$n-response.json" $responseJson -Encoding utf8 }
    [void]$Steps.Add(@{ file = $n; title = $Title; actor = $Actor; method = $Method; url = $Url; request = $Request; response = $responseJson; calls = $Calls; note = $Note })
    Write-Host ("  {0,-34} recorded" -f $Title)
}

$script:Citizen = New-RequestInfo "CITIZEN" "CITIZEN" "pg"

# ---- 1. INITIATE ----------------------------------------------------------------------------------------
$create = Get-Content "$PSScriptRoot\create-request.json" -Raw | ConvertFrom-Json
$create.RequestInfo = $script:Citizen
$mark = (Get-Content $TlLog).Count
$r = Send "_create" $create
$script:AppNo = $r.response.Licenses[0].applicationNumber
Save-Step "initiate" "INITIATE (create the application)" "Citizen" "POST" "$BaseUrl/_create" $r.request $r.response (Get-InternalCalls $mark) `
    "Saves a draft. Only the license type and structure are validated at this stage."
Write-Host "Application: $script:AppNo"

# ---- 2. SEARCH (done before every update) ----------------------------------------------------------------
$mark = (Get-Content $TlLog).Count
$s = Get-License
Save-Step "search" "SEARCH (read the application)" "Citizen" "POST" "$BaseUrl/_search?tenantId=$TenantId&applicationNumber=$script:AppNo" $s.request $s.response (Get-InternalCalls $mark) `
    "Every update below starts from this response: take Licenses[0], change the action, send it back."

# ---- 3. APPLY --------------------------------------------------------------------------------------------
$license = $s.response.Licenses[0]
$license.action = "APPLY"
$license.propertyId = $PropertyId
$license.tradeLicenseDetail.address.addressLine1 = "gh"
$owner = $license.tradeLicenseDetail.owners[0]
$owner.name = "Local Test Owner"
$owner.mobileNumber = "7747474747"
$owner | Add-Member -NotePropertyName aadhaarNumber -NotePropertyValue "234567894821" -Force
$owner | Add-Member -NotePropertyName permanentAddress -NotePropertyValue "12, Test Colony, Sangamner" -Force
$docs = @("SEVENTWELVEEXTRACT", "PROPERTYEXTRACT", "AADHAARCARD", "PROPERTYTAXRECEIPT", "LANDOWNERCONSENT", "SHOPACTLICENSE") |
    ForEach-Object { [ordered]@{ tenantId = $TenantId; documentType = $_; fileStoreId = "local-test-$($_.ToLower())"; active = $true } }
$license.tradeLicenseDetail | Add-Member -NotePropertyName applicationDocuments -NotePropertyValue @($docs) -Force
$mark = (Get-Content $TlLog).Count
$r = Send "_update" ([ordered]@{ RequestInfo = $script:Citizen; Licenses = @($license) })
Save-Step "apply" "APPLY (submit the application)" "Citizen" "POST" "$BaseUrl/_update" $r.request $r.response (Get-InternalCalls $mark) `
    "Changes to the searched license: action, propertyId, owner name / mobile / Aadhaar / address, addressLine1 and the six documents. All SMC checks run here."
Wait-Status "APPLIED" | Out-Null

# ---- 4-7. employee steps ---------------------------------------------------------------------------------
$employeeSteps = @(
    @{ name = "forward-doc-verifier";    action = "FORWARD"; to = "FIELDINSPECTION";        role = "TL_DOC_VERIFIER";    title = "FORWARD (document verification)" },
    @{ name = "forward-field-inspector"; action = "FORWARD"; to = "PENDINGHODVERIFICATION"; role = "TL_FIELD_INSPECTOR"; title = "FORWARD (field inspection)" },
    @{ name = "forward-hod";             action = "FORWARD"; to = "PENDINGAPPROVAL";        role = "TL_HOD";             title = "FORWARD (HOD verification)" },
    @{ name = "approve";                 action = "APPROVE"; to = "PENDINGPAYMENT";         role = "TL_APPROVER";        title = "APPROVE" }
)
foreach ($e in $employeeSteps) {
    $license = (Get-License).response.Licenses[0]
    $license.action = $e.action
    $license.tradeLicenseDetail.address.addressLine1 = "gh"   # the persister update mapping would otherwise blank it
    $info = New-RequestInfo "EMPLOYEE" $e.role $TenantId
    $mark = (Get-Content $TlLog).Count
    $r = Send "_update" ([ordered]@{ RequestInfo = $info; Licenses = @($license) })
    $note = "Change to the searched license: action = $($e.action). The role in RequestInfo.userInfo.roles must be $($e.role) for tenant $TenantId."
    if ($e.action -eq "APPROVE") { $note += " The fee is calculated and the demand is created at this step." }
    Save-Step $e.name $e.title $e.role "POST" "$BaseUrl/_update" $r.request $r.response (Get-InternalCalls $mark) $note
    Wait-Status $e.to | Out-Null
}

# ---- 8. PAY ----------------------------------------------------------------------------------------------
$paymentEvent = [ordered]@{
    RequestInfo = $script:Citizen
    Payment     = [ordered]@{ tenantId = $TenantId; paymentDetails = @([ordered]@{ businessService = "TL"; tenantId = $TenantId; bill = [ordered]@{ consumerCode = $script:AppNo; tenantId = $TenantId } }) }
}
$mark = (Get-Content $TlLog).Count
($paymentEvent | ConvertTo-Json -Depth 20 -Compress) | & "$KafkaHome\bin\windows\kafka-console-producer.bat" --bootstrap-server localhost:9092 --topic egov.collection.payment-create 2>$null | Out-Null
$final = Wait-Status "APPROVED"
Save-Step "pay" "PAY (payment event)" "collection-services (simulated)" "KAFKA" "topic egov.collection.payment-create" ($paymentEvent | ConvertTo-Json -Depth 20) $null (Get-InternalCalls $mark) `
    "Not an HTTP call. PAY through _update is refused. tl-services consumes this event, moves the application to APPROVED and generates the license number. On a real environment collection-services publishes a full payment; this is the minimum tl-services needs."

# ---- 9. final SEARCH --------------------------------------------------------------------------------------
Save-Step "search-approved" "SEARCH (approved license)" "Citizen" "POST" "$BaseUrl/_search?tenantId=$TenantId&applicationNumber=$script:AppNo" $final.request $final.response @() `
    "Shows status APPROVED with licenseNumber and issuedDate."

# ---- API_CALLS.md ----------------------------------------------------------------------------------------
$md = New-Object System.Text.StringBuilder
[void]$md.AppendLine("# Trade license API calls, step by step")
[void]$md.AppendLine()
[void]$md.AppendLine("Recorded on the local stack by ``capture-api-calls.ps1`` for application ``$script:AppNo`` (Permanent, ``TL_NEW``),")
[void]$md.AppendLine("license number ``$($final.response.Licenses[0].licenseNumber)``. The bodies below are the real requests and responses.")
[void]$md.AppendLine("The same JSON is in [api-samples/](api-samples/), one file per request and response.")
[void]$md.AppendLine()
[void]$md.AppendLine("Locally there is no gateway, so ``RequestInfo.userInfo`` is sent in the body and ``authToken`` is not checked.")
[void]$md.AppendLine("On a deployed environment the gateway fills ``userInfo`` from the token.")
[void]$md.AppendLine()
[void]$md.AppendLine("| # | Step | Sent by | Call | Status after |")
[void]$md.AppendLine("|---|---|---|---|---|")
$i = 0
foreach ($st in $Steps) {
    $i++
    $after = ""
    if ($st.response) { $o = $st.response | ConvertFrom-Json; if ($o.Licenses) { $after = $o.Licenses[0].status } }
    if ($st.method -eq "KAFKA") { $after = "APPROVED" }
    [void]$md.AppendLine("| $i | $($st.title) | $($st.actor) | ``$($st.method) $($st.url -replace [regex]::Escape($BaseUrl), '/tl-services/v1')`` | $after |")
}
$i = 0
foreach ($st in $Steps) {
    $i++
    [void]$md.AppendLine()
    [void]$md.AppendLine("## $i. $($st.title)")
    [void]$md.AppendLine()
    [void]$md.AppendLine("- **Sent by:** $($st.actor)")
    [void]$md.AppendLine("- **Call:** ``$($st.method) $($st.url)``")
    [void]$md.AppendLine("- $($st.note)")
    if ($st.calls.Count) {
        [void]$md.AppendLine()
        [void]$md.AppendLine("Calls tl-services makes to other services while handling it, in order:")
        [void]$md.AppendLine()
        $k = 0
        foreach ($c in $st.calls) { $k++; [void]$md.AppendLine("$k. ``POST $c``") }
    }
    if ($st.request) {
        [void]$md.AppendLine()
        [void]$md.AppendLine("<details><summary>Request body</summary>")
        [void]$md.AppendLine()
        [void]$md.AppendLine("$($Tick)json")
        [void]$md.AppendLine($st.request)
        [void]$md.AppendLine($Tick)
        [void]$md.AppendLine()
        [void]$md.AppendLine("</details>")
    }
    if ($st.response) {
        [void]$md.AppendLine()
        [void]$md.AppendLine("<details><summary>Response body (HTTP 200)</summary>")
        [void]$md.AppendLine()
        [void]$md.AppendLine("$($Tick)json")
        [void]$md.AppendLine($st.response)
        [void]$md.AppendLine($Tick)
        [void]$md.AppendLine()
        [void]$md.AppendLine("</details>")
    }
}
Set-Content (Join-Path $PSScriptRoot "API_CALLS.md") $md.ToString() -Encoding utf8

Write-Host ""
Write-Host "Application $script:AppNo -> $($final.response.Licenses[0].status), license $($final.response.Licenses[0].licenseNumber)"
Write-Host "Written: API_CALLS.md and $($Steps.Count * 2 - 1) files in api-samples\"
