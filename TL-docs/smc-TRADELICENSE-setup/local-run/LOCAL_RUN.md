# Running trade license locally, end to end

This guide starts tl-services and everything it calls on one Windows machine, so that
the trade license APIs (`_create`, `_search`, `_update`) can be tested and debugged without a deployed
environment. Only the Postgres database is remote.

It was last verified on 1 October 2026 on tenant `pg.smc`: both workflows, `TL_NEW` (Permanent) and `TTL_NEW`
(Temporary), run from `INITIATE` to `APPROVED` with a license number, and every send-back, resubmit and reject
transition works. `.\test-workflow.ps1` repeats that run, see [Whole workflow](#whole-workflow-in-one-command).

## What runs where

| Component | Port | Source folder (under `app-services`) | Notes |
|---|---|---|---|
| ZooKeeper | 2181 | `C:\Kafka\kafka_2.13-3.6.0` | stock config |
| Kafka | 9092 | `C:\Kafka\kafka_2.13-3.6.0` | stock config |
| egov-mdms-service | 8094 | `core-services\egov-mdms-service` | reads `mdms\data` |
| egov-persister | 8090 | `core-services\egov-persister` | writes what the services publish to Kafka into the database |
| user stub | 8091 | `local-run\user-stub.js` | stands in for egov-user, see [Limits](#limits) |
| property stub | 8087, 8089 | `local-run\property-stub.js` | stands in for property-services and ws-services, see [Limits](#limits) |
| egov-idgen | 8088 | `core-services\egov-idgen` | |
| egov-location | 8086 | `core-services\egov-location` | |
| egov-workflow-v2 | 8280 | `core-services\egov-workflow-v2` | |
| billing-service | 8082 | `business-services\billing-service` | |
| egov-apportion-service | 8093 | `business-services\egov-apportion-service` | splits a payment across tax heads |
| collection-services | 8095 | `business-services\collection-services` | counter payments and receipts |
| tl-calculator | 8085 | `municipal-services\tl-calculator` | |
| **tl-services** | **8079** | `municipal-services\tl-services` | the service under test |
| Postgres | remote | – | shared database, see [Shared database](#shared-database) |

`_create` calls them in this order: MDMS → tl-calculator (billing slabs) → egov-idgen → egov-location →
user → tl-calculator (estimate) → egov-workflow-v2 → Kafka → egov-persister → database.

## Prerequisites

- Windows with PowerShell 5.1 or later
- JDK 17, with `JAVA_HOME` pointing to it
- Maven 3.9 on the `PATH`
- Node.js (any version from 12) on the `PATH`, for the user stub
- Apache Kafka 3.6.0 unpacked at `C:\Kafka\kafka_2.13-3.6.0` (pass `-KafkaHome` to the script if it is elsewhere)
- Network access to the Postgres database, and its URL, user and password
- These three folders side by side:

```
UPYOG-SMC-CODE\
  app-services\              this repository
  mdms\                      MDMS data: mdms\data and mdms\master-config.json
  configs-scm\configs\       configs repository; egov-persister\*.yml is used
```

`psql` is optional; it is only used for the database checks at the end.

## One-time setup

### 1. Database connection

The scripts take the connection from three environment variables and pass it to every service. Set them in the
PowerShell window you start from (ask the team for the values; do not put them in a file that gets committed):

```powershell
$env:TL_DB_URL      = "jdbc:postgresql://<host>:5432/<database>?sslmode=require"
$env:TL_DB_USER     = "<user>"
$env:TL_DB_PASSWORD = '<password>'     # single quotes, so special characters are kept
```

These override whatever `spring.datasource.*` is in each service's `application.properties`, and Flyway is
switched off for every service, so no service changes the database schema.

### 2. Build the jars

```powershell
cd app-services\municipal-services\tl-services\docs\smc-setup\local-run
.\start-local.ps1 -Build
```

`-Build` builds only the services that have no jar in their `target` folder yet, then starts everything.
To build one service by hand:

```powershell
cd app-services\core-services\egov-workflow-v2
mvn "-Daether.artifactResolver.snapshotNormalization=false" -DskipTests clean package
```

Keep the `-Daether...` option: without it Maven tries to rewrite a shared snapshot jar in `.m2` and fails with
"Could not transfer artifact ... services-common" whenever another service that uses that jar is running.

### 3. MDMS

`start-local.ps1` starts egov-mdms-service from its jar with `mdms\data` and `mdms\master-config.json`. If you
already run it from the IDE on port 8094, the script leaves it alone; in that case check that its
`application.properties` has `egov.mdms.conf.path` and `masters.config.url` pointing at your `mdms` folder.
MDMS reads its files only at startup, so restart it after changing MDMS data.

Starting MDMS from the jar through the script has not been exercised yet (it was running from the IDE when
the scripts were tested).

### 4. Workflow configuration (already done for the shared database)

`TL_NEW` and `TTL_NEW` were loaded for tenant `pg` on 1 October 2026. On a new database, load them once after
the stack is up: post `src\main\resources\Workflows\TL_NEW.json` and `TTL_NEW.json` to
`http://localhost:8280/egov-workflow-v2/egov-wf/businessservice/_create`, after changing `tenantId` from `mh`
to `pg` and adding a `userInfo` to `RequestInfo`.

## Start and stop

```powershell
cd app-services\municipal-services\tl-services\docs\smc-setup\local-run
.\start-local.ps1                  # about 70-90 seconds
.\stop-local.ps1                   # stops the services, leaves Kafka running
.\stop-local.ps1 -IncludeKafka     # stops Kafka and ZooKeeper too
```

- A component whose port is already listening is skipped, so the script can be re-run at any time, for example
  after stopping one service to restart it.
- `stop-local.ps1` only stops what `start-local.ps1` started.
- Logs are in `UPYOG-SMC-CODE\local-run-logs\<service>.log`.

Options of `start-local.ps1`:

| Option | Effect |
|---|---|
| `-Build` | build any missing jar first |
| `-SkipDuesChecks` | start tl-services with the SMC property and water dues checks off |
| `-RealUser` | use the real egov-user and egov-enc-service instead of the stub, see [Real user service](#real-user-service) |
| `-KafkaHome <path>` | Kafka location, default `C:\Kafka\kafka_2.13-3.6.0` |

### After changing code

Stop that service, rebuild its jar, start again:

```powershell
Stop-Process -Id (Get-NetTCPConnection -State Listen -LocalPort 8079).OwningProcess -Force
cd app-services\municipal-services\tl-services
mvn "-Daether.artifactResolver.snapshotNormalization=false" -DskipTests clean package
cd docs\smc-setup\local-run
.\start-local.ps1
```

To debug tl-services from the IDE instead, stop it as above and run `org.egov.tl.Main` with the same program
arguments the script passes (the `$tl` list in `start-local.ps1`) and the three `SPRING_DATASOURCE_*`
environment variables plus `SPRING_FLYWAY_ENABLED=false`.

## Calling the APIs

There is no gateway locally, which changes two things compared with the deployed environment:

- `RequestInfo.authToken` is not checked. Any value works.
- `RequestInfo.userInfo` must be in the request body (the gateway normally adds it). Roles in it decide which
  workflow actions are allowed, so use the roles of the user you are simulating.

In Postman: import [SMC_TL_Local.postman_collection.json](SMC_TL_Local.postman_collection.json). It has the
citizen flows (Permanent and Temporary), the employee flow as TLSU1, the send-back / resubmit / reject path
and the supporting calls. Run a folder top to bottom or with the Collection Runner; each update request reads
the application with `_search` and builds its own body, so nothing has to be copied between requests. For a
single request by hand: method POST, header `Content-Type: application/json`, the URLs below, body raw JSON.

### Create

[create-request.json](create-request.json) is the body the UI sends for a new Permanent license
(`workflowCode: TL_NEW`, `action: INITIATE`).

```powershell
$r = Invoke-RestMethod -Method Post -Uri "http://localhost:8079/tl-services/v1/_create" `
       -ContentType "application/json" -InFile ".\create-request.json"
$r.Licenses[0] | Select-Object applicationNumber, status, workflowCode
```

Expected: `status = INITIATED`, `workflowCode = TL_NEW` and an `applicationNumber` such as
`PB-TL-2026-10-01-005875`. For a Temporary license use `workflowCode: TTL_NEW` and `licenseType: TEMPORARY`.

### Search

```powershell
$ri = '{"RequestInfo":{"apiId":"Rainmaker","userInfo":{"id":17253,"uuid":"57a3e9c0-fc9e-480c-bf12-2d6a964d134c","userName":"8908011908","type":"CITIZEN","tenantId":"pg","roles":[{"name":"Citizen","code":"CITIZEN","tenantId":"pg"}]}}}'

Invoke-RestMethod -Method Post -ContentType "application/json" -Body $ri `
  -Uri "http://localhost:8079/tl-services/v1/_search?tenantId=pg.smc&applicationNumber=<applicationNumber>"
```

Wait a few seconds after `_create` before searching: the license is written by the persister, not by
tl-services itself.

### Update (workflow actions)

`POST http://localhost:8079/tl-services/v1/_update`. Take the license object returned by `_search`, set
`action` to the next step, and send it as `{"RequestInfo": {...}, "Licenses": [ <license> ]}`.

| Action | From state | Role needed in `userInfo.roles` |
|---|---|---|
| `APPLY` | INITIATED → APPLIED | `CITIZEN` or `TL_CEMP` |
| `FORWARD` | APPLIED → FIELDINSPECTION | `TL_DOC_VERIFIER` |
| `FORWARD` | FIELDINSPECTION → PENDINGHODVERIFICATION | `TL_FIELD_INSPECTOR` |
| `FORWARD` | PENDINGHODVERIFICATION → PENDINGAPPROVAL | `TL_HOD` |
| `APPROVE` | PENDINGAPPROVAL → PENDINGPAYMENT | `TL_APPROVER` |
| `PAY` | PENDINGPAYMENT → APPROVED | payment event, see below |
| `SENDBACK` | one step back | the role of the current step |
| `SENDBACKTOCITIZEN` | APPLIED or FIELDINSPECTION → CITIZENACTIONREQUIRED | `TL_DOC_VERIFIER`, `TL_FIELD_INSPECTOR` |
| `RESUBMIT` | CITIZENACTIONREQUIRED → APPLIED | `CITIZEN` or `TL_CEMP` |
| `REJECT` | any employee step → REJECTED | the role of the current step |

For employee roles, give the role `tenantId: "pg.smc"`. A wrong role, a role of another city, or an action that
does not belong to the current state is rejected with `EG_WF_ERROR` (`INVALID ROLE` / `INVALID ACTION`).

What to know for each step:

- **`APPLY` and `RESUBMIT` run the SMC checks.** A Permanent application needs `propertyId`, the firm address,
  a land identifier, landowner name, each owner's name, mobile, 12-digit Aadhaar and residential address, and
  the six documents listed in [../README.md](../README.md). A Temporary one needs the owner fields, the
  employee names and the Aadhaar document. The request must carry these values itself; `_search` does not
  return the owner's Aadhaar or address while the user stub is in use.
- **Send `addressLine1` again on every update**, until the persister config is fixed, see
  [Troubleshooting](#troubleshooting).
- **Documents already saved must be sent back with their `id`.** Replacing them with new entries fails with
  `INVALID UPDATE: The id ... was not present in update request`.
- **`APPROVE` creates the demand.** tl-calculator calculates the fee and creates the demand through
  billing-service, as real rows in the shared database (`eg_tl_calculator_tradetype`, `egbs_demand_v1`,
  `egbs_demanddetail_v1`). Earlier steps only ask for an estimate and store nothing.
- **`PAY` cannot be sent through `_update`** (`Pay action cannot perform directly`). The application is paid
  through billing-service and collection-services, see [Cash payment](#cash-payment). collection-services
  then publishes a payment event on the Kafka topic `egov.collection.payment-create`; tl-services consumes it,
  moves the application to `APPROVED` and generates the license number.

### Cash payment

Two calls, made by a counter employee (role `TL_CEMP`, tenant `pg.smc`) once the application is in
`PENDINGPAYMENT`:

1. Generate the bill:
   `POST http://localhost:8082/billing-service/bill/v2/_fetchbill?tenantId=pg.smc&consumerCode=<applicationNumber>&businessService=TL`
   with body `{"RequestInfo": {...}}`. Take `Bill[0].id` and `Bill[0].totalAmount`.
2. Collect the payment: `POST http://localhost:8095/collection-services/payments/_create`

```json
{
  "RequestInfo": { "...": "counter employee" },
  "Payment": {
    "tenantId": "pg.smc",
    "paymentMode": "CASH",
    "totalDue": 500.00,
    "totalAmountPaid": 500.00,
    "paidBy": "OWNER",
    "payerName": "Local Test Owner",
    "mobileNumber": "7747474747",
    "paymentDetails": [
      { "businessService": "TL", "billId": "<Bill[0].id>", "totalDue": 500.00, "totalAmountPaid": 500.00 }
    ]
  }
}
```

The response holds the receipt number (`Payments[0].paymentDetails[0].receiptNumber`). A few seconds later the
demand is marked paid, the bill is `PAID` and the license is `APPROVED`.

Rules verified locally: the full amount must be paid (part payment and over payment are refused with
`INVALID_PAYMENTDETAIL`), `DD` is not an allowed mode for TL, and a bill cannot be paid twice
(`BILL_ALREADY_PAID`).

Tables written: `egbs_bill_v1`, `egbs_billdetail_v1`, `egbs_billaccountdetail_v1` (bill), `egcl_payment`,
`egcl_paymentdetail`, `egcl_bill`, `egcl_billdetial`, `egcl_billaccountdetail` (payment and receipt), and the
`collectionamount` and `ispaymentcompleted` columns of the demand.

### Whole workflow in one command

```powershell
.\test-workflow.ps1                                   # new Permanent application, INITIATE to APPROVED
.\test-workflow.ps1 -Temporary                        # new Temporary application
.\test-workflow.ps1 -ApplicationNumber PB-TL-...      # continue an existing application from its current state
.\test-workflow.ps1 -PropertyId PG-PT-1013-008993     # property used at APPLY (must have no unpaid PT demand)
.\test-workflow.ps1 -StopBeforePayment                # leave the application in PENDINGPAYMENT
.\test-workflow.ps1 -SimulatePayment                  # no collection-services: publish the payment event directly
```

It prints each transition and ends with the license number, or stops with the server's error. Expected output:

```
  INITIATE by CITIZEN            -> INITIATED
Application: PB-TL-2026-10-01-005877
  APPLY    by CITIZEN            -> APPLIED
  FORWARD  by TL_DOC_VERIFIER    -> FIELDINSPECTION
  FORWARD  by TL_FIELD_INSPECTOR -> PENDINGHODVERIFICATION
  FORWARD  by TL_HOD             -> PENDINGAPPROVAL
  APPROVE  by TL_APPROVER        -> PENDINGPAYMENT
  BILL     by billing-service    -> bill BILL-038575, amount 500.00
  PAY      by TL_CEMP (cash)     -> receipt 10/2026-27/000452, paid 500.00 (NEW)

Status      : APPROVED
License no. : PB-TL-2026-10-02-001290
```

Read the script for a working example of every request body. With `-SimulatePayment` no receipt is created
and the demand stays unpaid.

### Supporting services

All take the `$ri` body from the Search example unless shown otherwise.

| What | Call |
|---|---|
| Workflow history of an application | `POST http://localhost:8280/egov-workflow-v2/egov-wf/process/_search?tenantId=pg.smc&businessIds=<applicationNumber>&history=true` |
| Workflow configuration | `POST http://localhost:8280/egov-workflow-v2/egov-wf/businessservice/_search?tenantId=pg.smc&businessServices=TL_NEW` |
| Billing slabs (fees) | `POST http://localhost:8085/tl-calculator/billingslab/_search?tenantId=pg.smc&tradeType=GOODS.MANUFACTURE.SMC-01` |
| Localities | `POST http://localhost:8086/egov-location/location/v11/boundarys/_search?tenantId=pg.smc&hierarchyTypeCode=REVENUE&boundaryType=Locality` |
| Tax heads | `POST http://localhost:8082/billing-service/taxheads/_search?tenantId=pg.smc&service=TL` |
| MDMS master | `POST http://localhost:8094/egov-mdms-service/v1/_search` with body `{"RequestInfo":{},"MdmsCriteria":{"tenantId":"pg","moduleDetails":[{"moduleName":"TradeLicense","masterDetails":[{"name":"TradeType"}]}]}}` |

The MDMS checks in `../SMC_TL_MDMS_Check.postman_collection.json` also work against `http://localhost:8094`.
Avoid calling `egov-idgen/id/_generate` by hand: every call uses up a number from the shared sequence.

### Checking the database

```powershell
$env:PGPASSWORD = '<password>'; $env:PGSSLMODE = "require"
psql -h <host> -U <user> -d <database> -c "select applicationnumber, status, businessservice, workflowcode, applicationtype from eg_tl_tradelicense where applicationnumber = '<applicationNumber>'"
psql -h <host> -U <user> -d <database> -c "select businessservice, action from eg_wf_processinstance_v2 where businessid = '<applicationNumber>'"
```

`businessservice`, `workflowcode` and `applicationtype` must be filled. If they are NULL, the persister is
using the wrong config file, see [Troubleshooting](#troubleshooting).

## Limits

- **Owners are not real users.** `user-stub.js` answers in place of egov-user and writes nothing. Every owner
  gets the uuid of the logged-in user from `RequestInfo.userInfo`, and searches show the owner name as
  `STUB USER`. The owner's own name and mobile number are not stored. Reason: egov-user encrypts personal data
  through egov-enc-service, which can only read the database's keys with the environment's master password.
  A pass-through encryption service would write plain text into the shared `eg_user` table, so do not do that.
- **Use a `userInfo.uuid` that exists** in `eg_user`, otherwise the license points at a user nobody can find.
- **Property and water connection lookups are stubbed.** `property-stub.js` answers in place of
  property-services (every `propertyId` "exists") and ws-services (no water connections). The property tax
  dues check itself is real: it reads the property's unpaid PT demands from billing-service.
- **Only counter payment in cash is covered.** Online payment (egov-pg-service and a gateway), cheque and
  card payments, the receipt PDF and finance vouchers are not part of this stack.
- **Receipt numbers use the default format** (`10/2026-27/000452`), not the environment's
  (`TL/1013/2026-27/008387`), because the `receipt.id` format is not in the local MDMS data.
- **collection-services ignores program arguments.** Its `main` does not pass them to Spring, so
  `start-local.ps1` gives it its settings as `-Dkey=value` system properties.
- **Not running:** egov-localization, filestore, access control, pdf-service. Notifications (SMS, email,
  in-app) are switched off, and document `fileStoreId` values are not checked. After a payment tl-services and
  collection-services log notification errors (`NOTIFICATION_ERROR`, "Exception while fetching from
  localization"); they do not affect the result.
- **Localities are sample data.** The `pg.smc` boundary in the local MDMS data holds stock Jalandhar codes
  such as `JLC476`, not Sangamner wards.
- **Application numbers use the `PB-TL-...` format** from tl-services' properties, because the SMC ID formats
  (`../mdms_common-masters_IdFormat_SMC.json`) are not merged into the local MDMS data.

### Shared database

The database is shared with the deployed environment. Everything you create locally is real data there:
licenses, workflow records, demands, and one application number per `_create` attempt (even a failed one).
Use recognisable test names and do not run bulk tests.

## Using the server's real services (recommended when the cluster is up)

When the deployed environment is running and you have its kubeconfig (`C:\Users\.kube\config`), the services
that cannot run locally can be borrowed from the cluster instead of using the stand-ins:

```powershell
.\connect-server.ps1 -Mdms       # port-forwards egov-user, egov-enc-service, property-services, ws-services, MDMS
.\start-local.ps1 -RealUser      # skips everything already listening, points the services at the real user service
.\test-workflow.ps1
.\connect-server.ps1 -Stop       # when finished
```

Verified on 3 October 2026: both citizen flows and the employee flow run to `APPROVED` with cash payment this
way. Differences from the stand-in mode:

- Every application owner becomes a real citizen user in the shared `eg_user` table (one new user per
  application, as on the server).
- Property existence and water connections are checked for real, so `-PropertyId` must be an existing property
  without unpaid PT demands.
- With `-Mdms` the master data is the server's, not your local `mdms` folder. Leave `-Mdms` out to test local
  MDMS changes (then egov-mdms-service must run locally on 8094).
- The forwards stop when the cluster stops or the connection drops; run `connect-server.ps1` again.

**Never put a made-up user uuid in `RequestInfo.userInfo`.** The uuid of whoever performs a step is stored in the
workflow history, and the deployed workflow service looks every one of them up: one unknown uuid makes the
citizen's "My Applications" page fail with `INVALID UUID: User not found`. The test scripts therefore act as the
real employee TLSU1 and add the role a step needs in the request (roles are trusted locally).

## Testing in the browser (no React build)

`ui-proxy.js` serves the deployed UI on `http://localhost:3000` and sends the trade license, calculator,
workflow, billing and collection calls to the local stack; everything else (login, master data, files, PDFs)
goes to the server. It adds the logged-in user to each local call, as the deployed gateway does.

```powershell
.\connect-server.ps1 -Mdms       # the proxy resolves login tokens through the forwarded user service
.\start-local.ps1 -RealUser
node ui-proxy.js                 # keep this window open; it prints every call and where it went
```

Then open `http://localhost:3000/upyog-ui/citizen` or `http://localhost:3000/upyog-ui/employee` and log in as on
the real site. Use a separate browser profile or incognito window per user.

- Calls marked `LOCAL` in the proxy output ran on your machine, `SERVER` on the deployed environment.
- The gateway's role-to-API permission check is not done by the proxy.
- The server's inbox and search index do not see applications created through the local services; open them by
  application number if they are missing from an inbox.
- To send more (or fewer) services to the local stack, edit `LOCAL_ROUTES` at the top of `ui-proxy.js`.

## Real user service run locally

When the environment's `master.password`, `master.salt` and `master.initialvector` are known:

1. Put them in `core-services\egov-enc-service\src\main\resources\application.properties` (do not commit).
2. Rebuild egov-enc-service.
3. Make sure Redis is running on port 6379.
4. `.\stop-local.ps1`, then `.\start-local.ps1 -RealUser`.

egov-enc-service then starts on 1234 and egov-user on 8081, and the other services use them instead of the
stub. With wrong values egov-enc-service exits at startup with `AEADBadTagException: Tag mismatch!`; it fails
before writing anything. This path has not been tested, because the values were not available.

Never call `_rotatekey` or `_rotateallkeys` on a local egov-enc-service: that rewrites the shared keys.

## Troubleshooting

| Symptom | Cause and fix |
|---|---|
| `kafka did not come up (attempt 1), retrying` | Normal after a quick stop and start: ZooKeeper keeps the old broker registration for about 18 seconds. The script retries by itself. |
| Kafka never starts; `kafka.log` shows errors about log files or `AccessDeniedException` | Kafka on Windows can corrupt its data folder. Stop Kafka and ZooKeeper, delete `C:\tmp\kafka-logs` and `C:\tmp\zookeeper`, start again. Only unprocessed local messages are lost. |
| `<service> did not start on port ...` | Read `local-run-logs\<service>.log`. Usual causes: wrong database variables, MDMS not running, port taken by another program. |
| Build fails with `Could not transfer artifact ... services-common` | A running service has the jar locked. Build with `-Daether.artifactResolver.snapshotNormalization=false` as shown above. |
| `_create` returns `ENCRYPTION_ERROR` | A service is pointed at the real egov-user without a working egov-enc-service. Start without `-RealUser`. |
| `_create` returns `EG_WF_ERROR ... No bussinessService object found for businessSerice: TL_NEW` | The workflow configuration is missing in the database, see One-time setup step 4. |
| `_create` returns 200 but the row has NULL `businessservice` / `workflowcode` / `applicationtype` | The persister loaded `tl-services\src\main\resources\tradelicense.yml`, which is out of date. It must load `configs-scm\configs\egov-persister\tradelicense.yml` (the script does). Load only one of the three `tradelicense*.yml` files in that folder; they cover the same topics. |
| `_create` returns 200 but nothing is in the database | The persister or Kafka is down, or the insert failed. Check `egov-persister.log` for `PSQLException`. |
| `_search` finds nothing right after `_create` | The persister has not written it yet. Wait a few seconds. |
| After any `_update` the address loses `addressLine1` (and `RESUBMIT` then fails with `NULL_FIRMADDRESS`) | Bug in `configs-scm\configs\egov-persister\tradelicense.yml`: the `UPDATE eg_tl_address` mapping reads `address.addressline1` / `address.addressline2`, but the fields are `addressLine1` / `addressLine2`, so NULL is written. Until the config is corrected, send `addressLine1` again in every update request. |
| `SENDBACKTOCITIZEN` returns `INVALID_ASSIGNEE: Cannot assign to the user` | The workflow service could not confirm the owner has the `CITIZEN` role. With the stub this means an old `user-stub.js` is running; restart it. |
| `APPLY` returns `PROPERTY_TAX_DUES_PENDING` | Working as designed: the property has unpaid PT demands. Use another `-PropertyId`. |
| A request seems to hang, or the log shows `UnknownHostException: dev.digit.org` | A service was started without its host overrides and is using the defaults in `application.properties`. Start it through `start-local.ps1`. |
