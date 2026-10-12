<#
Runs one Permanent (TL_NEW) application entirely from the employee side, as one existing employee with the
roles that employee really has in the database:

  create at the counter -> search -> APPLY -> FORWARD x3 -> APPROVE -> bill -> cash payment -> APPROVED

  .\test-employee-workflow.ps1                      # as TLSU1 of pg.smc
  .\test-employee-workflow.ps1 -StandInRole TL_HOD  # if the employee lacks a role, do that one step with a
                                                    # made-up employee holding it, so the rest can be tested

There is no login locally (no gateway, no real user service), so the password is not used or checked. The
employee's uuid, id and roles below were read from eg_user / eg_userrole_v1 / eg_hrms_employee.
#>
param(
    [string]$EmployeeCode = "TLSU1",
    [string]$EmployeeUuid = "73e6bb90-e1d0-4835-99d5-adc277877af6",
    [int]$EmployeeId = 10059,
    # TLSU1 was given TL_HOD on 4 Oct 2026 (row in eg_userrole_v1), so no stand-in is needed any more
    [string[]]$EmployeeRoles = @("EMPLOYEE", "TL_APPROVER", "TL_CEMP", "TL_DOC_VERIFIER", "TL_FIELD_INSPECTOR", "TL_HOD"),
    [string[]]$StandInRole = @(),
    [string]$PropertyId = "PG-PT-1013-008993",
    [string]$TenantId = "pg.smc",
    [string]$BaseUrl = "http://localhost:8079/tl-services/v1",
    [string]$BillingUrl = "http://localhost:8082/billing-service",
    [string]$CollectionUrl = "http://localhost:8095/collection-services"
)

$ErrorActionPreference = "Stop"

function New-EmployeeInfo([string]$Uuid, [int]$Id, [string]$Code, [string[]]$Roles) {
    @{ apiId = "Rainmaker"; authToken = "not-checked-locally"; msgId = "local|en_IN"
       userInfo = @{ id = $Id; uuid = $Uuid; userName = $Code; name = $Code; type = "EMPLOYEE"; tenantId = $TenantId
                     roles = @($Roles | ForEach-Object { @{ code = $_; name = $_; tenantId = $TenantId } }) } }
}
$employee = New-EmployeeInfo $EmployeeUuid $EmployeeId $EmployeeCode $EmployeeRoles

function Invoke-Api([string]$Url, $Body) {
    $json = $Body | ConvertTo-Json -Depth 30
    try {
        $r = Invoke-WebRequest -Method Post -Uri $Url -ContentType "application/json" -Body ([Text.Encoding]::UTF8.GetBytes($json)) -UseBasicParsing -TimeoutSec 120
        return ($r.Content | ConvertFrom-Json)
    }
    catch {
        $detail = $_.Exception.Message
        if ($_.Exception.Response) {
            $text = (New-Object IO.StreamReader($_.Exception.Response.GetResponseStream())).ReadToEnd()
            try { $detail = (($text | ConvertFrom-Json).Errors | ForEach-Object { "$($_.code): $($_.message)" }) -join " | " } catch { $detail = $text }
        }
        throw $detail
    }
}

function Get-License {
    for ($i = 0; $i -lt 15; $i++) {
        $s = Invoke-Api "$BaseUrl/_search?tenantId=$TenantId&applicationNumber=$script:AppNo" @{ RequestInfo = $employee }
        if (@($s.Licenses).Count -eq 1 -and $s.Licenses[0]) { return $s.Licenses[0] }
        Start-Sleep -Seconds 2
    }
    throw "Application $script:AppNo not found by _search"
}

function Wait-Status([string]$Expected) {
    for ($i = 0; $i -lt 20; $i++) {
        $l = Get-License
        if ($l.status -eq $Expected) { return $l }
        Start-Sleep -Seconds 2
    }
    throw "Application $script:AppNo is in status '$($l.status)', expected '$Expected'"
}

function Step([string]$Action, [string]$NeededRole, [string]$Expected, [scriptblock]$Change) {
    $license = Get-License
    $license.action = $Action
    $license.tradeLicenseDetail.address.addressLine1 = "gh"   # the persister update mapping would otherwise blank it
    if ($Change) { & $Change $license }
    $label = "{0,-8} needs {1,-18}" -f $Action, $NeededRole
    try {
        $r = Invoke-Api "$BaseUrl/_update" @{ RequestInfo = $employee; Licenses = @($license) }
        Write-Host "  $label -> $($r.Licenses[0].status)   (as $EmployeeCode)"
    }
    catch {
        Write-Host "  $label -> REFUSED for $EmployeeCode : $_"
        if ($StandInRole -notcontains $NeededRole) { throw "$EmployeeCode cannot do $Action here (role $NeededRole is missing). Re-run with -StandInRole $NeededRole to continue past this step." }
        # Stand-in: the same real employee, with the missing role added in RequestInfo (trusted locally).
        # A made-up uuid must not be used: it is stored in the workflow history and breaks the deployed
        # workflow search, which looks every user up.
        $standIn = New-EmployeeInfo $EmployeeUuid $EmployeeId $EmployeeCode ($EmployeeRoles + $NeededRole)
        $r = Invoke-Api "$BaseUrl/_update" @{ RequestInfo = $standIn; Licenses = @($license) }
        Write-Host "  $label -> $($r.Licenses[0].status)   (as $EmployeeCode with $NeededRole added locally)"
    }
    Wait-Status $Expected | Out-Null
}

Write-Host "Employee $EmployeeCode ($EmployeeUuid), roles: $($EmployeeRoles -join ', ')"

# ---- create at the counter --------------------------------------------------------------------------------
$create = Get-Content "$PSScriptRoot\create-request.json" -Raw | ConvertFrom-Json
$create.RequestInfo = $employee
$create.Licenses[0].tradeLicenseDetail.channel = "COUNTER"
$created = Invoke-Api "$BaseUrl/_create" $create
$script:AppNo = $created.Licenses[0].applicationNumber
Write-Host ("  {0,-8} needs {1,-18} -> {2}   (as {3})" -f "INITIATE", "TL_CEMP", $created.Licenses[0].status, $EmployeeCode)
Write-Host "Application: $script:AppNo"

# ---- search -----------------------------------------------------------------------------------------------
$found = Get-License
Write-Host ("  {0,-8} {1,-24} -> found, status {2}, channel {3}" -f "SEARCH", "by application number", $found.status, $found.tradeLicenseDetail.channel)
$byStatus = Invoke-Api "$BaseUrl/_search?tenantId=$TenantId&status=INITIATED&limit=50" @{ RequestInfo = $employee }
Write-Host ("  {0,-8} {1,-24} -> {2} application(s), includes this one: {3}" -f "SEARCH", "by status INITIATED", @($byStatus.Licenses).Count, [bool](@($byStatus.Licenses.applicationNumber) -contains $script:AppNo))

# ---- workflow ---------------------------------------------------------------------------------------------
Step "APPLY" "TL_CEMP" "APPLIED" {
    param($l)
    $l.propertyId = $PropertyId
    $owner = $l.tradeLicenseDetail.owners[0]
    $owner.name = "Local Test Owner"
    $owner.mobileNumber = "7747474747"
    $owner | Add-Member -NotePropertyName aadhaarNumber -NotePropertyValue "234567894821" -Force
    $owner | Add-Member -NotePropertyName permanentAddress -NotePropertyValue "12, Test Colony, Sangamner" -Force
    $docs = @("SEVENTWELVEEXTRACT", "SHOPACTLICENSE", "LANDOWNERCONSENT", "AADHAARCARD", "OWNERPHOTO") |
        ForEach-Object { @{ tenantId = $TenantId; documentType = $_; fileStoreId = "local-test-$($_.ToLower())"; active = $true } }
    $l.tradeLicenseDetail | Add-Member -NotePropertyName applicationDocuments -NotePropertyValue @($docs) -Force
}
Step "FORWARD" "TL_DOC_VERIFIER"    "FIELDINSPECTION"
Step "FORWARD" "TL_FIELD_INSPECTOR" "PENDINGHODVERIFICATION"
Step "FORWARD" "TL_HOD"             "PENDINGAPPROVAL"
Step "APPROVE" "TL_APPROVER"        "PENDINGPAYMENT"

# ---- cash payment at the counter --------------------------------------------------------------------------
$bill = (Invoke-Api "$BillingUrl/bill/v2/_fetchbill?tenantId=$TenantId&consumerCode=$script:AppNo&businessService=TL" @{ RequestInfo = $employee }).Bill[0]
Write-Host ("  {0,-8} {1,-24} -> bill {2}, amount {3}   (as {4})" -f "BILL", "billing-service", $bill.billNumber, $bill.totalAmount, $EmployeeCode)
$payment = @{
    RequestInfo = $employee
    Payment     = @{
        tenantId = $TenantId; paymentMode = "CASH"; totalDue = $bill.totalAmount; totalAmountPaid = $bill.totalAmount
        paidBy = "OWNER"; payerName = "OWNER"; mobileNumber = "8908011908"   # existing test citizen, no new user is created
        paymentDetails = @(@{ businessService = "TL"; billId = $bill.id; totalDue = $bill.totalAmount; totalAmountPaid = $bill.totalAmount })
    }
}
$paid = (Invoke-Api "$CollectionUrl/payments/_create" $payment).Payments[0]
Write-Host ("  {0,-8} {1,-24} -> receipt {2}, paid {3}   (as {4})" -f "PAY", "cash, collection-services", $paid.paymentDetails[0].receiptNumber, $paid.totalAmountPaid, $EmployeeCode)

$final = Wait-Status "APPROVED"
$payments = Invoke-Api "$CollectionUrl/payments/TL/_search?tenantId=$TenantId&consumerCodes=$script:AppNo" @{ RequestInfo = $employee }
Write-Host ("  {0,-8} {1,-24} -> {2} payment(s) found for the application" -f "SEARCH", "payments", @($payments.Payments).Count)

Write-Host ""
Write-Host "Application : $($final.applicationNumber)"
Write-Host "Status      : $($final.status)"
Write-Host "License no. : $($final.licenseNumber)"
