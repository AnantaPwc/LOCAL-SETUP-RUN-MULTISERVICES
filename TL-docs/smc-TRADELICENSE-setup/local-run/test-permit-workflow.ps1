<#
Runs one application of a Sangamner certificate / NOC / permission service through its whole workflow on the
local stack:

  CLEAN_CERT  Cleanliness certificate   APPLY -> doc verifier -> field inspector -> HoD -> Chief Officer -> PAY -> APPROVED
  HEALTH_NOC  Health NOC                APPLY -> doc verifier -> field inspector -> Town Planning HoD -> License HoD
                                        [-Offensive: MARK_OFFENSIVE -> PAY publicity -> objections -> (hearing)]
                                        -> Chief Officer -> PAY -> APPROVED
  ADV_PERM    Advertisement permission  APPLY -> doc verifier -> field inspector -> HoD approves -> PAY -> APPROVED

  .\test-permit-workflow.ps1 -Service CLEAN_CERT
  .\test-permit-workflow.ps1 -Service HEALTH_NOC                                   # clinic, 2,000 sq. ft.: Rs. 6,000, 3 years
  .\test-permit-workflow.ps1 -Service HEALTH_NOC -Type NOC.HEALTH.SMC-N15 -Offensive
  .\test-permit-workflow.ps1 -Service HEALTH_NOC -Type NOC.HEALTH.SMC-N15 -Offensive -WithObjection
  .\test-permit-workflow.ps1 -Service HEALTH_NOC -Type NOC.HEALTH.SMC-N10          # salon: no fee, issued on approval
  .\test-permit-workflow.ps1 -Service ADV_PERM                                     # 2 banners of 12 x 10 ft, 3 days
  .\test-permit-workflow.ps1 -Service ADV_PERM -Type ADVERTISEMENT.DISPLAY.FLAGS -Reason GOVERNMENT   # free
  .\test-permit-workflow.ps1 -Service ADV_PERM -RequestFile .\body.json            # a request built elsewhere (the UI's)
  .\test-permit-workflow.ps1 -ApplicationNumber PB-TL-...                          # continue an application
  .\test-permit-workflow.ps1 -Service CLEAN_CERT -StopBeforePayment

The first request is src\test\resources\smc\<SERVICE>_create_request.json, the sample the unit tests use.

Needs the one-time setup of ..\README.md, section "Cleanliness certificate, health NOC, advertisement permission":
the three workflows and, in MDMS, the trade types, fee masters and tax heads.

-Offensive: objections are awaited tl.smc.noc.objection.window.days (7) days after the publicity charge is paid.
The script shows that NO_OBJECTION is refused before that; to go on in the same run, start tl-services with
"--tl.smc.noc.objection.window.days=0" (start-local.ps1 -NocObjectionDays 0), or use -WithObjection, which records
an objection and its hearing instead and needs no waiting.
#>
param(
    [ValidateSet("", "CLEAN_CERT", "HEALTH_NOC", "ADV_PERM")]
    [string]$Service = "",
    [string]$Type = "",
    [string]$Reason = "",
    [switch]$Offensive,
    [switch]$WithObjection,
    [string]$RequestFile = "",
    [string]$ApplicationNumber = "",
    [switch]$StopBeforePayment,
    [string]$PropertyId = "PG-PT-1013-008993",
    [string]$TenantId = "pg.smc",
    [string]$BaseUrl = "http://localhost:8079/tl-services/v1",
    [string]$BillingUrl = "http://localhost:8082/billing-service",
    [string]$CollectionUrl = "http://localhost:8095/collection-services"
)

$ErrorActionPreference = "Stop"
if (-not $Service -and -not $ApplicationNumber) { throw "Give -Service (CLEAN_CERT, HEALTH_NOC or ADV_PERM) or -ApplicationNumber (application to continue)." }

function New-RequestInfo([string]$UserType, [string[]]$Roles, [string]$RoleTenant) {
    $info = if ($UserType -eq "CITIZEN") {
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

function Step([string]$Action, [string]$Expected, [string]$Role, [string]$Comment) {
    $requestInfo = New-RequestInfo "EMPLOYEE" @($Role) $TenantId
    $license = Get-License $requestInfo
    $license.action = $Action
    $license | Add-Member -NotePropertyName comment -NotePropertyValue $Comment -Force
    $r = Invoke-Api "$BaseUrl/_update" @{ RequestInfo = $requestInfo; Licenses = @($license) }
    $status = $r.Licenses[0].status
    Write-Host ("  {0,-18} by {1,-18} -> {2}" -f $Action, $Role, $status)
    # an approved application with no fee payable is issued at once, without the payment step
    if ($status -eq "APPROVED" -and $Expected -eq "PENDINGPAYMENT") { $Expected = "APPROVED" }
    if ($status -ne $Expected) { throw "After $Action the status is '$status', expected '$Expected'" }
    Wait-Status $requestInfo $Expected
}

# The same step, expected to be refused with the given error code
function Step-Refused([string]$Action, [string]$Role, [string]$Comment, [string]$ErrorCode) {
    $requestInfo = New-RequestInfo "EMPLOYEE" @($Role) $TenantId
    $license = Get-License $requestInfo
    $license.action = $Action
    $license | Add-Member -NotePropertyName comment -NotePropertyValue $Comment -Force
    try { Invoke-Api "$BaseUrl/_update" @{ RequestInfo = $requestInfo; Licenses = @($license) } | Out-Null }
    catch {
        if ("$_" -notmatch $ErrorCode) { throw "Expected $Action to be refused with $ErrorCode, got: $_" }
        Write-Host ("  {0,-18} by {1,-18} -> refused: {2}" -f $Action, $Role, $ErrorCode)
        return
    }
    throw "$Action was accepted, expected it to be refused with $ErrorCode"
}

function Pay([string]$Expected) {
    $counter = New-RequestInfo "EMPLOYEE" @("TL_CEMP") $TenantId
    $bill = (Invoke-Api "$BillingUrl/bill/v2/_fetchbill?tenantId=$TenantId&consumerCode=$script:AppNo&businessService=TL" @{ RequestInfo = $counter }).Bill[0]
    $heads = ($bill.billDetails[0].billAccountDetails | ForEach-Object { "$($_.taxHeadCode) $($_.amount)" }) -join ", "
    Write-Host ("  {0,-18} by {1,-18} -> bill {2}, amount {3} ({4})" -f "BILL", "billing-service", $bill.billNumber, $bill.totalAmount, $heads)
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
    Write-Host ("  {0,-18} by {1,-18} -> receipt {2}, paid {3} ({4})" -f "PAY", "TL_CEMP (cash)", $paid.paymentDetails[0].receiptNumber, $paid.totalAmountPaid, $paid.paymentStatus)
    (Wait-Status (New-RequestInfo "CITIZEN" @("CITIZEN") "pg") $Expected).status
}

function Show-Date($Millis) { if ($Millis) { [DateTimeOffset]::FromUnixTimeMilliseconds([long]$Millis).ToOffset([TimeSpan]::FromMinutes(330)).ToString("dd-MM-yyyy") } else { "-" } }
function Show-Fee($License) { ($License.calculation.taxHeadEstimates | ForEach-Object { "$($_.taxHeadCode) $($_.estimateAmount)" }) -join ", " }

$citizen = New-RequestInfo "CITIZEN" @("CITIZEN") "pg"

# ---- APPLY: the application is created and submitted in one request, as the citizen form does ----------------
if ($ApplicationNumber) { $script:AppNo = $ApplicationNumber }
else {
    $file = if ($RequestFile) { $RequestFile } else { Join-Path $PSScriptRoot "..\..\..\src\test\resources\smc\${Service}_create_request.json" }
    $license = (Get-Content $file -Raw | ConvertFrom-Json).Licenses[0]
    $detail = $license.tradeLicenseDetail
    if (-not $RequestFile) {
        $license.tenantId = $TenantId
        if ($Type) { $detail.tradeUnits[0].tradeType = $Type }
        # document files are not looked at locally; every document needs its own id
        $stamp = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
        foreach ($document in $detail.applicationDocuments) { $document.fileStoreId = "local-test-$($document.documentType.ToLower())-$stamp" }
        if ($Service -eq "ADV_PERM") {
            $advertisement = $detail.additionalDetail.advertisement
            # from tomorrow, for 3 days
            $tomorrow = [DateTimeOffset]::new((Get-Date).Date.AddDays(1), [TimeSpan]::FromMinutes(330))
            $advertisement.fromDate = $tomorrow.ToUnixTimeMilliseconds()
            $advertisement.toDate = $tomorrow.AddDays(3).ToUnixTimeMilliseconds() - 1000
            if ($Reason) { $advertisement.reason = $Reason }
            if ($Type -like "*FLAGS") { $advertisement.length = $null; $advertisement.breadth = $null }
            if ($Type -like "*HOARDING" -or $Type -like "*LED") {
                $advertisement.length = 10; $advertisement.breadth = 10
                $detail.applicationDocuments += [pscustomobject]@{ documentType = "STABILITYCERTIFICATE"; fileStoreId = "local-test-stabilitycertificate-$stamp" }
                $detail.applicationDocuments += [pscustomobject]@{ documentType = "ELECTRICALSAFETYCERTIFICATE"; fileStoreId = "local-test-electricalsafetycertificate-$stamp" }
            }
        } else { $license.propertyId = $PropertyId }
    }
    $created = (Invoke-Api "$BaseUrl/_create" @{ RequestInfo = $citizen; Licenses = @($license) }).Licenses[0]
    $script:AppNo = $created.applicationNumber
    Write-Host ("  {0,-18} by {1,-18} -> {2}" -f "APPLY", "CITIZEN", $created.status)
    Write-Host "  estimated fee: $(Show-Fee $created)"
}

$application = Get-License $citizen
$Service = $application.workflowCode
Write-Host "Application: $script:AppNo ($Service, $($application.tradeLicenseDetail.tradeUnits[0].tradeType))"
Write-Host "  validity before approval: $(Show-Date $application.validFrom) to $(Show-Date $application.validTo)"
$current = $application.status

function Advance([string]$From, [string]$Action, [string]$To, [string]$Role, [string]$Comment) {
    if ($script:current -ne $From) { return }
    $script:current = (Step $Action $To $Role $Comment).status
}

Advance "APPLIED" "FORWARD" "FIELDINSPECTION" "TL_DOC_VERIFIER" "Documents verified"

if ($Service -eq "HEALTH_NOC") {
    Advance "FIELDINSPECTION" "FORWARD" "PENDINGTPVERIFICATION" "TL_FIELD_INSPECTOR" "Site inspected"
    Advance "PENDINGTPVERIFICATION" "FORWARD" "PENDINGHODVERIFICATION" "TP_HOD" "Building permission and sanctioned plan in order"
    if ($current -eq "PENDINGHODVERIFICATION") {
        $paid = (Get-License $citizen).tradeLicenseDetail.additionalDetail.noc.publicityPaidOn
        if ($Offensive -and -not $paid) {
            Advance "PENDINGHODVERIFICATION" "MARK_OFFENSIVE" "PUBLICITYPAYMENTPENDING" "TL_HOD" "Offensive business: paper publicity and objections"
        } else {
            Advance "PENDINGHODVERIFICATION" "FORWARD" "PENDINGAPPROVAL" "TL_HOD" "Recommended to the Chief Officer"
        }
    }
    if ($current -eq "PUBLICITYPAYMENTPENDING") {
        if ($StopBeforePayment) { Write-Host "Stopped before payment: $script:AppNo is in PUBLICITYPAYMENTPENDING"; return }
        $current = Pay "OBJECTIONWINDOW"
    }
    if ($current -eq "OBJECTIONWINDOW") {
        $noc = (Get-License $citizen).tradeLicenseDetail.additionalDetail.noc
        Write-Host "  publicity paid on $(Show-Date $noc.publicityPaidOn); objections awaited till $(Show-Date $noc.objectionWindowEndsOn)"
        if ($WithObjection) {
            Step-Refused "OBJECTION_RECEIVED" "TL_HOD" "" "NULL_OBJECTION_DETAILS"
            Advance "OBJECTIONWINDOW" "OBJECTION_RECEIVED" "HEARING" "TL_HOD" "R. Patil, neighbour: smell and waste water"
            Step-Refused "FORWARD" "TL_HOD" "" "NULL_HEARING_DECISION"
            Advance "HEARING" "FORWARD" "PENDINGAPPROVAL" "TL_HOD" "Heard both sides; waste to be removed daily. Objection closed"
        } elseif ([long]$noc.objectionWindowEndsOn -gt [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()) {
            Step-Refused "NO_OBJECTION" "TL_HOD" "No objection received" "OBJECTION_WINDOW_OPEN"
            Write-Host "Stopped: objections are awaited till $(Show-Date $noc.objectionWindowEndsOn). Continue then with -ApplicationNumber $script:AppNo"
            return
        } else {
            Advance "OBJECTIONWINDOW" "NO_OBJECTION" "PENDINGAPPROVAL" "TL_HOD" "No objection received"
        }
    }
    Advance "PENDINGAPPROVAL" "APPROVE" "PENDINGPAYMENT" "TL_APPROVER" "Approved"
}
elseif ($Service -eq "ADV_PERM") {
    Advance "FIELDINSPECTION" "FORWARD" "PENDINGHODVERIFICATION" "TL_FIELD_INSPECTOR" "Place inspected"
    Advance "PENDINGHODVERIFICATION" "APPROVE" "PENDINGPAYMENT" "TL_HOD" "Approved"
}
else {
    Advance "FIELDINSPECTION" "FORWARD" "PENDINGHODVERIFICATION" "TL_FIELD_INSPECTOR" "Site inspected"
    Advance "PENDINGHODVERIFICATION" "FORWARD" "PENDINGAPPROVAL" "TL_HOD" "Recommended to the Chief Officer"
    Advance "PENDINGAPPROVAL" "APPROVE" "PENDINGPAYMENT" "TL_APPROVER" "Approved"
}

# an application with no fee payable is issued on approval, without a bill
if ($current -eq "APPROVED") { Write-Host "  no fee payable: issued on approval, without payment" }

if ($current -eq "PENDINGPAYMENT") {
    if ($StopBeforePayment) { Write-Host "Stopped before payment: $script:AppNo is in PENDINGPAYMENT"; return }
    $current = Pay "APPROVED"
}

$final = Get-License $citizen
Write-Host ""
Write-Host "Application : $($final.applicationNumber) ($($final.workflowCode))"
Write-Host "Status      : $($final.status)"
Write-Host "Number      : $($final.licenseNumber)"
Write-Host "Valid       : $(Show-Date $final.validFrom) to $(Show-Date $final.validTo), issued $(Show-Date $final.issuedDate)"
if ($final.workflowCode -eq "HEALTH_NOC") { Write-Host "NOC record  : $($final.tradeLicenseDetail.additionalDetail.noc | ConvertTo-Json -Compress)" }
if ($final.status -ne "APPROVED") { throw "The application did not reach APPROVED (status $($final.status))." }
