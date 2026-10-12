<#
Runs one trade license through the whole TL_NEW (Permanent) or TTL_NEW (Temporary) workflow on the local stack:

  INITIATE -> APPLY -> FORWARD (doc verifier) -> FORWARD (field inspector) -> FORWARD (HOD)
           -> APPROVE -> PAY -> APPROVED, with a license number

  .\test-workflow.ps1                                   # new permanent application (TL_NEW)
  .\test-workflow.ps1 -Temporary                        # new temporary application (TTL_NEW)
  .\test-workflow.ps1 -ApplicationNumber PB-TL-...      # continue an existing application
  .\test-workflow.ps1 -PropertyId PG-PT-1013-008993
  .\test-workflow.ps1 -StopBeforePayment                # leave the application in PENDINGPAYMENT
  .\test-workflow.ps1 -SimulatePayment                  # skip collection-services, see below

PAY cannot be sent through _update. The script pays in cash at the counter the way the employee UI does:
billing-service generates the bill, collection-services creates the payment and receipt and publishes the
payment event, billing-service marks the demand paid and tl-services approves the license.
With -SimulatePayment the script publishes the payment event to Kafka itself instead; then no receipt
exists and the demand stays unpaid.
#>
param(
    [string]$ApplicationNumber = "",
    [string]$PropertyId = "PG-PT-1013-008993",
    [switch]$Temporary,
    [switch]$StopBeforePayment,
    [switch]$SimulatePayment,
    [string]$TenantId = "pg.smc",
    [string]$KafkaHome = "C:\Kafka\kafka_2.13-3.6.0",
    [string]$BaseUrl = "http://localhost:8079/tl-services/v1",
    [string]$BillingUrl = "http://localhost:8082/billing-service",
    [string]$CollectionUrl = "http://localhost:8095/collection-services"
)

$ErrorActionPreference = "Stop"

function New-RequestInfo([string]$Type, [string[]]$Roles, [string]$RoleTenant) {
    $info = if ($Type -eq "CITIZEN") {
        @{ id = 17253; uuid = "57a3e9c0-fc9e-480c-bf12-2d6a964d134c"; userName = "8908011908"; name = "OWNER"; mobileNumber = "8908011908"; type = "CITIZEN"; tenantId = "pg" }
    } else {
        # A real employee (TLSU1 of pg.smc). The uuid is stored in the workflow history, and the deployed
        # workflow service fails on history rows whose user does not exist, so never use a made-up uuid here.
        # Locally the roles in RequestInfo are trusted, so this user is given the role each step needs.
        @{ id = 10059; uuid = "73e6bb90-e1d0-4835-99d5-adc277877af6"; userName = "TLSU1"; name = "TLSU1"; type = "EMPLOYEE"; tenantId = $TenantId }
    }
    $info.roles = @($Roles | ForEach-Object { @{ code = $_; name = $_; tenantId = $RoleTenant } })
    @{ apiId = "Rainmaker"; authToken = "not-checked-locally"; msgId = "local|en_IN"; userInfo = $info }
}

function Invoke-Tl([string]$Path, $Body) {
    $json = $Body | ConvertTo-Json -Depth 30
    try {
        $r = Invoke-WebRequest -Method Post -Uri "$BaseUrl/$Path" -ContentType "application/json" -Body ([Text.Encoding]::UTF8.GetBytes($json)) -UseBasicParsing -TimeoutSec 120
        return ($r.Content | ConvertFrom-Json)
    }
    catch {
        $detail = $_.Exception.Message
        if ($_.Exception.Response) { $detail = (New-Object IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd() }
        throw "$Path failed: $detail"
    }
}

function Get-License([hashtable]$RequestInfo) {
    # the persister writes asynchronously, so give it a moment after every change
    for ($i = 0; $i -lt 15; $i++) {
        $s = Invoke-Tl "_search?tenantId=$TenantId&applicationNumber=$script:AppNo" @{ RequestInfo = $RequestInfo }
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
    $r = Invoke-Tl "_update" @{ RequestInfo = $RequestInfo; Licenses = @($license) }
    $status = $r.Licenses[0].status
    Write-Host ("  {0,-8} by {1,-18} -> {2}" -f $Action, ($RequestInfo.userInfo.roles[0].code), $status)
    if ($status -ne $Expected) { throw "After $Action the status is '$status', expected '$Expected'" }
    Wait-Status $RequestInfo $Expected | Out-Null
}

$citizen = New-RequestInfo "CITIZEN" @("CITIZEN") "pg"

# ---- INITIATE ------------------------------------------------------------------------------------------
if ($ApplicationNumber) { $script:AppNo = $ApplicationNumber }
else {
    $create = Get-Content "$PSScriptRoot\create-request.json" -Raw | ConvertFrom-Json
    $create.RequestInfo = $citizen
    if ($Temporary) {
        # Temporary license: movable trade, employee names instead of property details
        $new = $create.Licenses[0]
        $new.workflowCode = "TTL_NEW"
        $new.licenseType = "TEMPORARY"
        $new.tradeLicenseDetail.structureType = "MOVABLE.HANDCART"
        $new.tradeLicenseDetail.additionalDetail.isImmovableStructure = $false
        $names = @(1..$new.tradeLicenseDetail.noOfEmployees | ForEach-Object { "Local Test Employee $_" })
        $new.tradeLicenseDetail.additionalDetail | Add-Member -NotePropertyName employeeNames -NotePropertyValue $names -Force
    }
    $created = Invoke-Tl "_create" $create
    $script:AppNo = $created.Licenses[0].applicationNumber
    Write-Host ("  {0,-8} by {1,-18} -> {2}" -f "INITIATE", "CITIZEN", $created.Licenses[0].status)
}
Write-Host "Application: $script:AppNo"
$current = (Get-License $citizen).status

# ---- APPLY: the citizen completes the form and submits --------------------------------------------------
if ($current -eq "INITIATED") {
    Step "APPLY" "APPLIED" $citizen {
        param($l)
        $isTemporary = $l.workflowCode -eq "TTL_NEW"
        if (-not $isTemporary) { $l.propertyId = $PropertyId }
        $owner = $l.tradeLicenseDetail.owners[0]
        $owner.name = "Local Test Owner"
        $owner.mobileNumber = "7747474747"
        $owner | Add-Member -NotePropertyName aadhaarNumber -NotePropertyValue "234567894821" -Force
        $owner | Add-Member -NotePropertyName permanentAddress -NotePropertyValue "12, Test Colony, Sangamner" -Force
        $required = if ($isTemporary) { @("AADHAARCARD") } else { @("SEVENTWELVEEXTRACT", "SHOPACTLICENSE", "LANDOWNERCONSENT", "AADHAARCARD", "OWNERPHOTO") }
        $docs = $required |
            ForEach-Object { @{ tenantId = $TenantId; documentType = $_; fileStoreId = "local-test-$($_.ToLower())"; active = $true } }
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

if ($current -eq "PENDINGPAYMENT" -and $StopBeforePayment) {
    Write-Host "Stopped before payment: $script:AppNo is in PENDINGPAYMENT"
    return
}

# ---- PAY in cash at the counter ---------------------------------------------------------------------------
if ($current -eq "PENDINGPAYMENT" -and -not $SimulatePayment) {
    $counter = New-RequestInfo "EMPLOYEE" @("TL_CEMP") $TenantId

    $bill = (Invoke-Api "$BillingUrl/bill/v2/_fetchbill?tenantId=$TenantId&consumerCode=$script:AppNo&businessService=TL" @{ RequestInfo = $counter }).Bill[0]
    Write-Host ("  {0,-8} by {1,-18} -> bill {2}, amount {3}" -f "BILL", "billing-service", $bill.billNumber, $bill.totalAmount)

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

# ---- PAY simulated: publish the payment event collection-services would send ------------------------------
if ($current -eq "PENDINGPAYMENT") {
    $paymentEvent = @{
        RequestInfo = $citizen
        Payment     = @{ tenantId = $TenantId; paymentDetails = @(@{ businessService = "TL"; tenantId = $TenantId; bill = @{ consumerCode = $script:AppNo; tenantId = $TenantId } }) }
    } | ConvertTo-Json -Depth 20 -Compress
    $paymentEvent | & "$KafkaHome\bin\windows\kafka-console-producer.bat" --bootstrap-server localhost:9092 --topic egov.collection.payment-create 2>$null | Out-Null
    Write-Host ("  {0,-8} by {1,-18} -> (payment event published)" -f "PAY", "simulated payment")
    $current = (Wait-Status $citizen "APPROVED").status
}

$final = Get-License $citizen
Write-Host ""
Write-Host "Application : $($final.applicationNumber)"
Write-Host "Status      : $($final.status)"
Write-Host "License no. : $($final.licenseNumber)"
Write-Host "Issued date : $($final.issuedDate)   valid $($final.validFrom) - $($final.validTo)"
if ($final.status -ne "APPROVED" -or -not $final.licenseNumber) { throw "The application did not reach APPROVED with a license number." }
