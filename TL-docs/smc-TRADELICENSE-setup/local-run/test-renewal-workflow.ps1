<#
Renews one issued trade license on the local stack, through the whole TL_RENEW (Permanent license) or
TTL_RENEW (Temporary license) workflow:

  search the license -> INITIATE (a new application under the same license number) -> APPLY
           -> FORWARD (doc verifier) -> FORWARD (field inspector) -> FORWARD (HOD) -> APPROVE -> PAY -> APPROVED

  .\test-renewal-workflow.ps1 -LicenseNumber PB-TL-2026-10-10-001311    # renew this license
  .\test-renewal-workflow.ps1 -LicenseNumber PB-TL-... -StopBeforePayment
  .\test-renewal-workflow.ps1 -ApplicationNumber PB-TL-...              # continue a renewal application

The renewal is sent the way the UI does it: the license as returned by _search goes to _update with
applicationType RENEWAL, workflowCode TL_RENEW and action INITIATE; tl-services then creates the renewal application.
The financial year, validity and fee are set by the services: next financial year and the Annexure 1 fee when
the license is still valid, the current financial year and double the fee when it has lapsed.

Needs the one-time setup of ..\README.md, section "Renewal": workflow TL_RENEW, the RENEWAL billing slabs,
and in MDMS the next financial year, its tax period and the 100% penalty.
#>
param(
    [string]$LicenseNumber = "",
    [string]$ApplicationNumber = "",
    [switch]$StopBeforePayment,
    [string]$TenantId = "pg.smc",
    [string]$BaseUrl = "http://localhost:8079/tl-services/v1",
    [string]$BillingUrl = "http://localhost:8082/billing-service",
    [string]$CollectionUrl = "http://localhost:8095/collection-services"
)

$ErrorActionPreference = "Stop"
if (-not $LicenseNumber -and -not $ApplicationNumber) { throw "Give -LicenseNumber (license to renew) or -ApplicationNumber (renewal to continue)." }

function New-RequestInfo([string]$Type, [string[]]$Roles, [string]$RoleTenant) {
    $info = if ($Type -eq "CITIZEN") {
        @{ id = 17253; uuid = "57a3e9c0-fc9e-480c-bf12-2d6a964d134c"; userName = "8908011908"; name = "OWNER"; mobileNumber = "8908011908"; type = "CITIZEN"; tenantId = "pg" }
    } else {
        # A real employee (TLSU1 of pg.smc), never a made-up uuid: it is stored in the workflow history.
        # Locally the roles in RequestInfo are trusted, so this user is given the role each step needs.
        @{ id = 10059; uuid = "73e6bb90-e1d0-4835-99d5-adc277877af6"; userName = "TLSU1"; name = "TLSU1"; type = "EMPLOYEE"; tenantId = $TenantId }
    }
    $info.roles = @($Roles | ForEach-Object { @{ code = $_; name = $_; tenantId = $RoleTenant } })
    @{ apiId = "Rainmaker"; authToken = "not-checked-locally"; msgId = "local|en_IN"; userInfo = $info }
}

function Invoke-Api([string]$Url, $Body) {
    $json = $Body | ConvertTo-Json -Depth 30
    try {
        $r = Invoke-WebRequest -Method Post -Uri $Url -ContentType "application/json" -Body ([Text.Encoding]::UTF8.GetBytes($json)) -UseBasicParsing -TimeoutSec 120
        return ($r.Content | ConvertFrom-Json)
    }
    catch {
        $detail = $_.Exception.Message
        if ($_.Exception.Response) { $detail = (New-Object IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd() }
        throw "$Url failed: $detail"
    }
}

function Get-License([hashtable]$RequestInfo) {
    # the persister writes asynchronously, so give it a moment after every change
    for ($i = 0; $i -lt 15; $i++) {
        $s = Invoke-Api "$BaseUrl/_search?tenantId=$TenantId&applicationNumber=$script:AppNo" @{ RequestInfo = $RequestInfo }
        if (@($s.Licenses).Count -eq 1 -and $s.Licenses[0]) { return $s.Licenses[0] }
        Start-Sleep -Seconds 2
    }
    throw "Application $script:AppNo not found by _search"
}

function Wait-Status([hashtable]$RequestInfo, [string]$Expected) {
    for ($i = 0; $i -lt 20; $i++) {
        $l = Get-License $RequestInfo
        if ($l.status -eq $Expected) { return $l }
        Start-Sleep -Seconds 2
    }
    throw "Application $script:AppNo is in status '$($l.status)', expected '$Expected'"
}

function Step([string]$Action, [string]$Expected, [hashtable]$RequestInfo, [scriptblock]$Change) {
    $license = Get-License $RequestInfo
    $license.action = $Action
    if ($Change) { & $Change $license }
    $r = Invoke-Api "$BaseUrl/_update" @{ RequestInfo = $RequestInfo; Licenses = @($license) }
    $status = $r.Licenses[0].status
    Write-Host ("  {0,-8} by {1,-18} -> {2}" -f $Action, ($RequestInfo.userInfo.roles[0].code), $status)
    if ($status -ne $Expected) { throw "After $Action the status is '$status', expected '$Expected'" }
    Wait-Status $RequestInfo $Expected | Out-Null
}

function Show-Date($Millis) { if ($Millis) { [DateTimeOffset]::FromUnixTimeMilliseconds([long]$Millis).ToOffset([TimeSpan]::FromMinutes(330)).ToString("dd-MM-yyyy") } }

$citizen = New-RequestInfo "CITIZEN" @("CITIZEN") "pg"

# ---- INITIATE: the issued license becomes the renewal request ---------------------------------------------
if ($ApplicationNumber) { $script:AppNo = $ApplicationNumber }
else {
    $found = Invoke-Api "$BaseUrl/_search?tenantId=$TenantId&licenseNumbers=$LicenseNumber" @{ RequestInfo = $citizen }
    $previous = @($found.Licenses | Where-Object { $_.status -in "APPROVED", "EXPIRED" } | Sort-Object validTo -Descending)[0]
    if (-not $previous) { throw "No issued or expired license found with number $LicenseNumber" }
    Write-Host ("License to renew: {0} (application {1}, {2}, valid {3} to {4}, {5})" -f $previous.licenseNumber, $previous.applicationNumber,
        $previous.financialYear, (Show-Date $previous.validFrom), (Show-Date $previous.validTo), $previous.status)

    $previous.applicationType = "RENEWAL"
    # a permanent license is renewed under TL_RENEW, a temporary one under TTL_RENEW
    $previous.workflowCode = if ($previous.licenseType -eq "TEMPORARY") { "TTL_RENEW" } else { "TL_RENEW" }
    $previous.action = "INITIATE"
    $created = (Invoke-Api "$BaseUrl/_update" @{ RequestInfo = $citizen; Licenses = @($previous) }).Licenses[0]
    $script:AppNo = $created.applicationNumber
    Write-Host ("  {0,-8} by {1,-18} -> {2}" -f "INITIATE", "CITIZEN", $created.status)
}
Write-Host "Renewal application: $script:AppNo"
$renewal = Get-License $citizen
Write-Host ("  renewal for {0}, valid {1} to {2}, estimated fee: {3}" -f $renewal.financialYear, (Show-Date $renewal.validFrom), (Show-Date $renewal.validTo),
    (($renewal.calculation.taxHeadEstimates | ForEach-Object { "$($_.taxHeadCode) $($_.estimateAmount)" }) -join ", "))
$current = $renewal.status

# ---- APPLY: the citizen adds the copy of the previous license and submits ----------------------------------
if ($current -eq "INITIATED") {
    Step "APPLY" "APPLIED" $citizen {
        param($l)
        # values _search does not return while the user stub is in use
        $owner = $l.tradeLicenseDetail.owners[0]
        $owner.name = "Local Test Owner"
        $owner.mobileNumber = "7747474747"
        $owner | Add-Member -NotePropertyName aadhaarNumber -NotePropertyValue "234567894821" -Force
        $owner | Add-Member -NotePropertyName permanentAddress -NotePropertyValue "12, Test Colony, Sangamner" -Force
        # a movable trade has no business location
        if ($l.tradeLicenseDetail.structureType -like "IMMOVABLE*" -and -not $l.tradeLicenseDetail.address.addressLine1) { $l.tradeLicenseDetail.address.addressLine1 = "gh" }

        # documents carried over from the previous application keep their id; missing renewal documents are added
        $docs = @($l.tradeLicenseDetail.applicationDocuments | Where-Object { $_ })
        $renewalDocuments = if ($l.licenseType -eq "TEMPORARY") { @("AADHAARCARD", "PREVIOUSLICENSE") } else { @("AADHAARCARD", "SHOPACTLICENSE", "PREVIOUSLICENSE") }
        foreach ($type in $renewalDocuments) {
            if ($docs.documentType -notcontains $type) {
                $docs += [pscustomobject]@{ tenantId = $TenantId; documentType = $type; fileStoreId = "local-test-renewal-$($type.ToLower())-$script:AppNo"; active = $true }
            }
        }
        $l.tradeLicenseDetail | Add-Member -NotePropertyName applicationDocuments -NotePropertyValue @($docs) -Force
    }
    $current = "APPLIED"
}

# ---- employee steps -------------------------------------------------------------------------------------
$steps = @(
    @{ from = "APPLIED";                action = "FORWARD"; to = "FIELDINSPECTION";        role = "TL_DOC_VERIFIER" },
    @{ from = "FIELDINSPECTION";        action = "FORWARD"; to = "PENDINGHODVERIFICATION"; role = "TL_FIELD_INSPECTOR" },
    @{ from = "PENDINGHODVERIFICATION"; action = "FORWARD"; to = "PENDINGAPPROVAL";        role = "TL_HOD" },
    @{ from = "PENDINGAPPROVAL";        action = "APPROVE"; to = "PENDINGPAYMENT";         role = "TL_APPROVER" }
)
foreach ($s in $steps) {
    if ($current -ne $s.from) { continue }
    Step $s.action $s.to (New-RequestInfo "EMPLOYEE" @($s.role) $TenantId) $null
    $current = $s.to
}

if ($current -eq "PENDINGPAYMENT" -and $StopBeforePayment) {
    Write-Host "Stopped before payment: $script:AppNo is in PENDINGPAYMENT"
    return
}

# ---- PAY in cash at the counter ---------------------------------------------------------------------------
if ($current -eq "PENDINGPAYMENT") {
    $counter = New-RequestInfo "EMPLOYEE" @("TL_CEMP") $TenantId

    $bill = (Invoke-Api "$BillingUrl/bill/v2/_fetchbill?tenantId=$TenantId&consumerCode=$script:AppNo&businessService=TL" @{ RequestInfo = $counter }).Bill[0]
    $heads = ($bill.billDetails[0].billAccountDetails | ForEach-Object { "$($_.taxHeadCode) $($_.amount)" }) -join ", "
    Write-Host ("  {0,-8} by {1,-18} -> bill {2}, amount {3} ({4})" -f "BILL", "billing-service", $bill.billNumber, $bill.totalAmount, $heads)

    $payment = @{
        RequestInfo = $counter
        Payment     = @{
            tenantId        = $TenantId
            paymentMode     = "CASH"
            totalDue        = $bill.totalAmount
            totalAmountPaid = $bill.totalAmount
            paidBy          = "OWNER"
            # the payer is the existing test citizen, so collection-services does not create a new user
            payerName       = "OWNER"
            mobileNumber    = "8908011908"
            paymentDetails  = @(@{ businessService = "TL"; billId = $bill.id; totalDue = $bill.totalAmount; totalAmountPaid = $bill.totalAmount })
        }
    }
    $paid = (Invoke-Api "$CollectionUrl/payments/_create" $payment).Payments[0]
    Write-Host ("  {0,-8} by {1,-18} -> receipt {2}, paid {3} ({4})" -f "PAY", "TL_CEMP (cash)", $paid.paymentDetails[0].receiptNumber, $paid.totalAmountPaid, $paid.paymentStatus)
    $current = (Wait-Status $citizen "APPROVED").status
}

$final = Get-License $citizen
Write-Host ""
Write-Host "Application : $($final.applicationNumber) ($($final.applicationType), $($final.workflowCode))"
Write-Host "Status      : $($final.status)"
Write-Host "License no. : $($final.licenseNumber)"
Write-Host "Valid       : $($final.financialYear), $(Show-Date $final.validFrom) to $(Show-Date $final.validTo), issued $(Show-Date $final.issuedDate)"
if ($final.status -ne "APPROVED") { throw "The renewal did not reach APPROVED." }
if ($LicenseNumber -and $final.licenseNumber -ne $LicenseNumber) { throw "The renewal has license number $($final.licenseNumber), expected $LicenseNumber." }
