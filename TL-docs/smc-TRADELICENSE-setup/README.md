# SMC trade license setup

Data to load for the Sangamner Municipal Council trade licenses TL_NEW (Permanent), TTL_NEW (Temporary) and
TL_RENEW (renewal of Permanent), state tenant `pg`, city tenant `pg.smc`. Load in the order below.

## 1. MDMS (state `pg`)

Merge each file's array into the same master of the MDMS data repo the server reads, then restart egov-mdms-service
(it reads the files only at startup).

| File | Master | Change |
|---|---|---|
| `mdms_TradeLicense_TradeType_SMC.json` | `TradeLicense.TradeType` | Append the 53 Annexure 1 business types, codes `CATEGORY.SUBCATEGORY.SMC-nn` (nn = Sr. No.). See [annexure1_codes.md](annexure1_codes.md) |
| `data/pg/TradeLicense/StructureType.json` (in the mdms repo) | `TradeLicense.StructureType` | TL's own structure types incl. `MOVABLE.HANDCART`, `MOVABLE.VEHICLE`, `MOVABLE.STALL`. tl-services and tl-calculator read it from the `TradeLicense` module (register it as state-level in `master-config.json`); `common-masters.StructureType` stays unchanged for other modules |
| `mdms_TradeLicense_documentObj_SMC.json` | `TradeLicense.documentObj` | **Replace** `documentObj[0].allowedDocs`: the document list the TL UI shows for upload |
| `mdms_TradeLicense_LegalStatus_SMC.json` | `TradeLicense.LegalStatus` | New master: Owned / Rented / Leased / Other |
| `mdms_common-masters_IdFormat_SMC.json` | `common-masters.IdFormat` | Optional: the number formats of the seven services, see [Numbers](#numbers). tl-services already sends the same formats, so load it only to change a format without a release |
| `mdms_ACCESSCONTROL-ROLES_roles_SMC.json` | `ACCESSCONTROL-ROLES.roles` | Append the `TL_HOD` role |
| `mdms_ACCESSCONTROL-ROLEACTIONS_roleactions_SMC.json` | `ACCESSCONTROL-ROLEACTIONS.roleactions` | Append 73 entries giving `TL_HOD` the same API access as `TL_APPROVER` |

## 2. Localization

`POST /localization/messages/v1/_upsert` with an employee token (replace `{{authToken}}`), one call per file:

- `localization_rainmaker-tl_en_IN.json`, `localization_rainmaker-tl_mr_IN.json`: business type and category names
- `localization_smc_masters_en_IN.json`, `localization_smc_masters_mr_IN.json`: structure types, documents, legal status, TL_HOD role

## 3. License Charge Master (tl-calculator database)

Run `billingslab_TL_SMC_Annexure1.sql` on the tl-calculator database (`psql -f`). It inserts 52 Permanent slabs
(Annexure 1 rates) and 53 Temporary slabs (Rs. 500). It is re-runnable: existing rows are skipped.

The calculator matches `structuretype = <license structure> OR structuretype = 'ALL'`, but the billingslab/_create API
rejects `ALL` because it is not an MDMS StructureType. Using the API would need one slab per structure type, so the
SQL inserts one row per business type with `structuretype = 'ALL'`. Load the MDMS trade types first: tl-services accepts
a business type only when it has a billing slab, and the UI lists it only when it is in MDMS.

## 4. Workflow

Load `src/main/resources/Workflows/TL_NEW.json` and `TTL_NEW.json` with
`POST /egov-workflow-v2/egov-wf/businessservice/_create`, after changing `tenantId` from `mh` to `pg`.

## 4a. Movable business types (Temporary license, movable trade)

The 20 business types of the council's list "Movable licenses items" (Pan Shop, Vada Pav Sales, ... Beauty Parlour).
The citizen screen offers them when the applicant answers "No" to the immovable structure question, and the
53 Annexure 1 types otherwise.

| What | File | Change |
|---|---|---|
| `TradeLicense.TradeType` | `mdms_TradeLicense_TradeType_SMC_movable.json` | Append 20 types, codes `GOODS.MOVABLE.SMC-Mnn` / `SERVICES.MOVABLE.SMC-Mnn` (nn = Sr. No.), each with `"movable": true`. That flag is what the UI filters on |
| License Charge Master | `billingslab_TL_SMC_movable.sql` | 20 Temporary slabs of Rs. 500. Re-runnable. Without them tl-services refuses the type (`INVALID TRADETYPE`) |
| Localization | `localization_rainmaker-tl_en_IN.json`, `localization_rainmaker-tl_mr_IN.json` | 21 new messages each (the 20 names and the sub-category "Movable trade"). The Marathi names are a translation, to be checked by the council |

tl-services does not check that a movable license uses a movable business type; only the screen does.

## 5. Renewal: permanent license (TL_RENEW) and temporary license (TTL_RENEW)

Service codes `TL_RENEW` and `TTL_RENEW` (sent as `workflowCode`, with `applicationType: RENEWAL`). A permanent
license is renewed only under `TL_RENEW`, a temporary one only under `TTL_RENEW`. Load after steps 1 to 4a:

| What | File | Change |
|---|---|---|
| Workflow | `src/main/resources/Workflows/TL_RENEW.json`, `TTL_RENEW.json` | Same states, roles and SLAs as `TL_NEW` / `TTL_NEW`. Load like step 4 |
| License Charge Master, permanent | `billingslab_TL_SMC_Annexure1_renewal.sql` | Copies every Permanent slab to `applicationtype = RENEWAL` with the same rate (52 rows). Re-runnable |
| License Charge Master, temporary | `billingslab_TL_SMC_temporary_renewal.sql` | Copies every Temporary slab (53 Annexure 1 + 20 movable types) to `applicationtype = RENEWAL`, Rs. 500 (73 rows). Re-runnable |
| `TradeLicense.Penalty` | `mdms_TradeLicense_Penalty_SMC.json` | Append: 100% from 1 April, effective 2026-27. This is the double fee of a late renewal |
| `egf-master.FinancialYear` | `mdms_egf-master_FinancialYear_SMC.json` | Append the next financial year (2027-28, module `TL`). A license valid till 31 March 2027 is renewed for 2027-28, so this year must exist before the first renewal is made |
| `BillingService.TaxPeriod` | `mdms_BillingService_TaxPeriod_SMC.json` | Append the tax periods of 2027-28 (service `TL`); billing-service refuses a demand without one |

Add the next financial year and its tax period to MDMS every year, before renewals for it start.
`TradeLicense.Rebate` needs no change: `TL_RENEW` gives no rebate.

How a renewal works:

- **Request.** Search the license by its number, then send that license to `_update` (or `_create`) with
  `applicationType: RENEWAL`, `workflowCode: TL_RENEW`, `action: INITIATE`. tl-services creates a new application
  with a new application number and the **same license number**; `additionalDetail.previousApplicationNumber`
  points to the application it renews.
- **License renewed.** The number must belong to an issued (`APPROVED`) or `EXPIRED` Permanent license. A second
  renewal is refused while one is under scrutiny (`RENEWAL_IN_PROCESS`) or once the license is renewed for that year
  (`LICENSE_ALREADY_RENEWED`). The type of business cannot change (`INVALID_TRADETYPE`).
- **Financial year.** Set by tl-services, whatever the request says: the year after the one the license is valid
  for, or the current year when the license has already lapsed. It is fixed at creation, together with the
  application date.
- **On submission** (`APPLY` / `RESUBMIT`): the same checks as `TL_NEW` (owner, firm address and PIN, land identifier,
  landowner, property tax and water dues = 0), with the documents of `tl.smc.renewal.required.documents`:
  `AADHAARCARD`, `SHOPACTLICENSE`, `PREVIOUSLICENSE`. A temporary renewal is checked like `TTL_NEW` (no location or
  dues for a movable trade), with `tl.smc.temporary.renewal.required.documents`: `AADHAARCARD`, `PREVIOUSLICENSE`.
- **Fee.** Annexure 1 rate of the business type, or Rs. 500 for a temporary license (tax head `TL_RENEWAL_TAX`). When the application date is after
  31 March of the expiring year, tax head `TL_RENEWAL_PENALTY` adds 100% of it. The application date decides, not the
  date of approval. As for `TL_NEW`, only an estimate is returned until the Chief Officer approves; the demand (LOI)
  is raised at `PENDINGPAYMENT`.
- **After payment** the renewal is `APPROVED` with the new validity. The previous application keeps its own
  validity and is expired by the expiry job like any other license.

`local-run/test-renewal-workflow.ps1 -LicenseNumber <number>` runs a renewal end to end on the local stack; it picks
`TL_RENEW` or `TTL_RENEW` from the type of the license.

**Citizen screens** (`modules/tl/src/pages/citizen/Renewal`): `SMCRenewalList` (route `renewal-list`) lists the
applicant's issued licenses, finds any license by number, and starts or continues a renewal; `SMCRenewalForm`
(route `renewal/:applicationNumber/:tenantId`) shows the pre-filled renewal, takes the documents and submits it.
The requests are built by `convertToRenewalInitiate` and `convertToRenewalApply` in the module's `utils`.

## 6. Cleanliness certificate, health NOC, advertisement permission

Three more services run on the trade license tables and APIs (`/tl-services/v1/_create`, `_update`, `_search`,
`businessService: TL`). The service code is sent as `workflowCode`; `applicationType` is `NEW`.

| Code | Service | Levels | Validity | Fee |
|---|---|---|---|---|
| `CLEAN_CERT` | Cleanliness Certificate | Clerk → License HoD → Chief Officer | 1 year from approval | Rs. 1,000 |
| `HEALTH_NOC` | No Objection Certificate (Health License) | Clerk → Town Planning HoD → License HoD → Chief Officer | 3 years, 1 year or one-time, by type of business | Annexure 2; Rs. 2,000 paper publicity if offensive |
| `ADV_PERM` | Advertisement / hoarding / flex / flags permission | Clerk → License HoD (approves) | From date to To date | Annexure 3: advertisement charge + permission fee |

### Setup, after steps 1 to 5

| What | File | Change |
|---|---|---|
| Workflows | `src/main/resources/Workflows/CLEAN_CERT.json`, `HEALTH_NOC.json`, `ADV_PERM.json` | Load like step 4, or with `local-run/load-permit-workflows.ps1 -Create` |
| `TradeLicense.TradeType` | `mdms_TradeLicense_TradeType_SMC_permits.json` | Append 33 types: 4 of the cleanliness certificate (`CLEANLINESS.CERTIFICATE.SMC-Cnn`), the 24 of Annexure 2 (`NOC.HEALTH.SMC-Nnn`, nn = Sr. No.) and 5 advertisement types (`ADVERTISEMENT.DISPLAY.*`). Each carries its service in `service` and has `type: SMC_PERMIT`, so the trade license screens, which list type `TL`, do not show them |
| `TradeLicense.NocBusinessType` | `mdms_TradeLicense_NocBusinessType_SMC.json` | New master, Annexure 2 item 2: `fee`, or `minFee` and `perSqftRate` (clinic), and `validityType` (`3_YEARS`, `ANNUAL`, `ONE_TIME`) |
| `TradeLicense.AdvertisementRate` | `mdms_TradeLicense_AdvertisementRate_SMC.json` | New master, Annexure 3: per advertisement type the rate unit, size limit (`maxSqft`), permission fee and the rates per category |
| `TradeLicense.AdvertisementReason` | `mdms_TradeLicense_AdvertisementReason_SMC.json` | New master: the reasons of the form and the Annexure 3 category each is charged as |
| `TradeLicense.AdvertisementLocation` | `mdms_TradeLicense_AdvertisementLocation_SMC.json` | New master. **Sample entries**: replace them by the council's list of places |
| `TradeLicense.FlatCharges` | `mdms_TradeLicense_FlatCharges_SMC.json` | New master: `CLEAN_CERT` 1,000, `PAPER_PUBLICITY` 2,000 |
| `master-config.json` | `mdms_master-config_TradeLicense_SMC_permits.json` | Add the five new masters to the `TradeLicense` section as state-level. Without it MDMS does not return them for `pg.smc` |
| `BillingService.TaxHeadMaster` | `mdms_BillingService_TaxHeadMaster_SMC_permits.json` | Append `TL_CLEAN_CERT_FEE`, `TL_NOC_FEE`, `TL_NOC_PUBLICITY_FEE`, `TL_ADV_CHARGE`, `TL_ADV_PERMISSION_FEE` (service `TL`) |
| Roles | `mdms_ACCESSCONTROL-ROLES_roles_SMC.json`, `mdms_ACCESSCONTROL-ROLEACTIONS_roleactions_SMC.json` | Now also hold `TP_HOD` (Town Planning HoD) with the API access of `TL_HOD`. Give the role to the officer in HRMS |
| Localization | `localization_smc_permits_en_IN.json`, `localization_smc_permits_mr_IN.json` | Names of the 33 types, the new statuses and actions, documents and fee heads. The Marathi is a translation, to be checked by the council |

No billing slabs: tl-calculator reads these fees from the MDMS masters (`SMCPermitCalculation`). Restart
egov-mdms-service after merging the files.

### Rules

- **Submission** (`APPLY` on `_create`, or `RESUBMIT`). A cleanliness certificate is checked like `TL_NEW` without the
  machines; a health NOC needs the applicant (and partners), the premises with property tax number and at least one of
  Survey / GAT / CTS / Plot / House No., and its area when the fee is per sq. ft. Both need nil property tax and water
  dues. An advertisement needs one applicant with email, type, reason, From date (not before today) and To date,
  place (`AdvertisementLocation`), whose place it is (`PUBLIC`, `PRIVATE`, `GOVERNMENT`), number of boards, the size
  of a board (not for flags) and the flex printer's name and contact. It has no property and no dues check.
- **Size limit**, per board: banner / flex 300 sq. ft., permanent hoarding 400, LED screen / wall 100
  (`SIZE_LIMIT_EXCEEDED` on submission).
- **Documents** (`tl.smc.cleanliness.*`, `tl.smc.noc.*`, `tl.smc.adv.*` in `application.properties`):

  | Service | Required |
  |---|---|
  | `CLEAN_CERT` | `SEVENTWELVEEXTRACT`, `PROPERTYEXTRACT`, `AADHAARCARD`, `PROPERTYTAXRECEIPT`, `SHOPACTLICENSE`; `LANDOWNERCONSENT` when the place is not owned; `LIFTLICENSE` is optional |
  | `HEALTH_NOC` | `SEVENTWELVEEXTRACT`, `PROPERTYEXTRACT`, `AADHAARCARD`, `PROPERTYTAXRECEIPT`, `LANDOWNERCONSENT`, `BUILDINGPERMISSION` |
  | `ADV_PERM` | `ADCOPY`, `AADHAARCARD`, `PROPERTYEXTRACT`, `NODUESCERTIFICATE`, `SELFDECLARATION`; private place: `SEVENTWELVEEXTRACT`, `LANDOWNERCONSENT`; Govt. place: `GOVTNOC`; reason `PROFESSIONAL`: `SHOPACTLICENSE`; permanent hoarding / LED: `STABILITYCERTIFICATE`, `ELECTRICALSAFETYCERTIFICATE` |

- **Scrutiny.** Once submitted, the applicant's details cannot be changed by an officer. A `REJECT` needs its reason
  in the comment. The decisions of a health NOC are recorded in `additionalDetail.noc`, by tl-services only:
  - License HoD, `FORWARD`: not offensive. `MARK_OFFENSIVE`: the LOI of the paper publicity charge is raised
    (status `PUBLICITYPAYMENTPENDING`).
  - Its payment opens the objection period (`OBJECTIONWINDOW`, `tl.smc.noc.objection.window.days` = 7).
    `NO_OBJECTION` is refused before it is over (`OBJECTION_WINDOW_OPEN`). `OBJECTION_RECEIVED` takes the objector and
    objection from the comment and moves to `HEARING`; there `FORWARD` (objection closed) or `REJECT`, with the
    decision in the comment.
- **Approval** (`APPROVE` by the Chief Officer; by the License HoD for an advertisement) sets the validity and raises
  the LOI. Cleanliness certificate: today to today + 1 year − 1 day. Health NOC: 3 years, 1 year, or no end date for
  a one-time type. Advertisement: From date to To date; it cannot be approved after the To date.
- **Fee.** Cleanliness: `FlatCharges.CLEAN_CERT`. Health NOC: the fee of the type; for a type with `perSqftRate`, the
  higher of `minFee` and rate × area. Advertisement (days = To − From + 1):
  banner / flex = boards × days × (base rate + (area − 100, if more) × excess rate); flags = Rs. 50 × flags;
  permanent hoarding = Rs. 20 × area × boards × years (days / 365, rounded up); LED = Rs. 20 × area × boards ×
  months (days / 30, rounded up); plus the permission fee of the type. A Government / public-interest advertisement
  pays nothing.
- **No fee payable** (Rs. 0, e.g. a salon NOC, a Government advertisement): the application is issued on approval,
  without a demand, since a bill of Rs. 0 cannot be paid.
- A certificate, NOC or permission gets a number of the license number series. It is not renewed (`TL_RENEW` refuses
  it) and gets no renewal reminder; the expiry job expires it after its validity.

`local-run/test-permit-workflow.ps1 -Service <code>` runs one application end to end on the local stack.

**Citizen screen** (`modules/tl/src/pages/citizen/Permit/SMCPermitForm.js`): one form per service, routes
`cleanliness-certificate`, `health-noc` and `advertisement-permission`, and `permit/:applicationNumber/:tenantId` to
correct an application that was sent back. The request is built by `convertToSMCPermit` and the form is checked by
`validateSMCPermitForm` (`utils/smcPermit.js`). Employees use the trade license application screen; the workflow
actions of each service appear in its action menu.

## Numbers

`SMC`, the service, the date on which the number is given, and a running number shared by all services
(sequences `SEQ_EG_TL_APL` for applications and `SEQ_EG_PT_LN` for issued numbers, as before). An application
number and an issued number have the same form; only the running number tells them apart:

| Service | Application number | Issued number |
|---|---|---|
| `TL_NEW` | `SMC-TL-2026-10-12-006060` | `SMC-TL-2026-10-12-001350` |
| `TTL_NEW` | `SMC-TTL-…` | `SMC-TTL-…` |
| `TL_RENEW` | `SMC-TLR-…` | the license number it renews |
| `TTL_RENEW` | `SMC-TTLR-…` | the license number it renews |
| `CLEAN_CERT` | `SMC-CC-…` | `SMC-CC-…` |
| `HEALTH_NOC` | `SMC-NOC-…` | `SMC-NOC-…` |
| `ADV_PERM` | `SMC-ADV-…` | `SMC-ADV-…` |

The formats are `tl.smc.application.number.formats` and `tl.smc.license.number.formats` in `application.properties`.
tl-services asks idgen for the id `tl.aplnumber.<service>` / `tl.licensenumber.<service>`; a format of that name in
`common-masters.IdFormat` replaces the one of the properties. Applications made before 11 October 2026 keep their
`PB-TL-…` numbers. Applications of 11 and 12 October 2026 carry the form tried first, with `APP` and the
financial year (`SMC-TL-APP-2026-27-006051`, three of them with the prefix `SAMN`).

## Letter of Intimation (LOI)

Printed for all seven services while a payment is due: after approval (`PENDINGPAYMENT`) and, for an offensive
health NOC, for the paper publicity charge (`PUBLICITYPAYMENTPENDING`). The employee finds "Print Letter of
Intimation (LOI)" in the Take Action menu next to Pay and in the download menu; the citizen has a button next to
Make Payment.

- pdf-service key `tl-loi`; `data-config/tl-loi.json` and `format-config/tl-loi.json` are generated by
  `local-run/build-pdf-configs.js`, like the receipt and the certificate, with the council seal embedded.
  Add both files to the `DATA_CONFIG_URLS` / `FORMAT_CONFIG_URLS` of the deployed pdf-service.
- Request: `{ RequestInfo, Licenses: [ { ...license, loi: { charges, totalAmount } } ] }`, where `charges` are the
  `billAccountDetails` of the bill and `totalAmount` its total. The screens fetch the bill and build it with
  `convertToSMCLetterOfIntimation` (`utils/smcPermit.js`). Lines of Rs. 0 are not printed.
- LOI number: `LOI/<application number>`. No number is stored.
- **LOI validity period (days) is not known yet**: it prints as a blank to fill in by hand. Set
  `LOI_VALIDITY_DAYS` in `build-pdf-configs.js` once the council gives it.
- Samples: `local-run/pdf-samples/LOI-sample-*.pdf`.

## Postman

- `SMC_TL_MDMS_Check.postman_collection.json`: checks every MDMS master TL needs (run after loading MDMS).
- `SMC_TL_End_to_End.postman_collection.json`: full test of TL_NEW and TTL_NEW: logins per role, one-time setup
  (workflows, localization), pre-checks (locality, property, dues), document upload, the 8 workflow steps up to the
  license, a draft-then-submit case and 15 negative tests. Each request saves what the next one needs.
- `local-run/SMC_TL_Permits_Local.postman_collection.json`: `CLEAN_CERT`, `HEALTH_NOC` and `ADV_PERM` against the
  local stack: setup check, one full run per service (including an offensive health NOC with objection and hearing,
  and a free Government advertisement issued on approval), 8 refused applications and the supporting calls.

## Document codes

The TL UI uploads documents under the `documentType` codes of `documentObj` (no dots), and tl-services checks the same
codes (`tl.smc.permanent.required.documents` / `tl.smc.temporary.required.documents`):

The lists are those of the council's application form (10 October 2026):

| Code | Document | Permanent | Temporary (movable) |
|---|---|---|---|
| `SEVENTWELVEEXTRACT` | Ownership document / sale deed / 7/12 extract | Required | – |
| `SHOPACTLICENSE` | Shop and Establishment registration / license | Required | – |
| `LANDOWNERCONSENT` | Owner consent letter / rent agreement for tenant premises | Required when the legal status of the place is not `OWNED` (`tl.smc.tenant.premises.required.documents`) | – |
| `AADHAARCARD` | Aadhaar card, self-attested copy | Required | Required |
| `OWNERPHOTO` | Passport-size photograph | Required | – |
| `OTHERPERMISSION` | Other permission / NOC, if applicable | Optional | Optional |
| `PREVIOUSLICENSE` | Previous license copy (renewal) | – | – |

When an `OTHERPERMISSION` document is uploaded, the applicant names it; the text is saved in
`additionalDetail.otherPermissionDetail`. `PROPERTYEXTRACT` and `PROPERTYTAXRECEIPT` are no longer asked for.
A Temporary license on an immovable structure (accepted by the API, not offered on the screen) needs
`SEVENTWELVEEXTRACT` and `AADHAARCARD`, plus `LANDOWNERCONSENT` when the place is not owned.

A Temporary license (`TTL_NEW`) is for a movable trade (`structureType` `MOVABLE.*`) or an immovable one
(`IMMOVABLE.*`); a Permanent one is always immovable. An immovable trade, Permanent or Temporary, needs the
property tax number, firm address, PIN, locality, a land identifier, landowner, legal status and nil property tax
and water dues. A movable trade needs none of these. Both kinds of Temporary license list the employees by name
(`additionalDetail.employeeNames`) and cost Rs. 500. The lists are `tl.smc.permanent.required.documents`,
`tl.smc.temporary.immovable.required.documents` and `tl.smc.temporary.required.documents`.

tl-services sets the financial year of a new license to the current one, whatever the request names.

A renewal (`TL_RENEW`) requires `AADHAARCARD`, `SHOPACTLICENSE` and `PREVIOUSLICENSE` (`tl.smc.renewal.required.documents`).

The citizen UI asks for the list of the chosen license (`getTLDocuments` in the tl module's `utils`);
tl-services enforces the same list on submission. Keep the two in step when a list changes.

## Needs confirmation

- **Sr. 9 Tyre vulcanizing:** fee not legible, so no Permanent slab is created. A Permanent application for it fails with
  "No BillingSlab Found" until the fee is added.
- **Sr. 10, 11, 12:** fees marked (verify) in the spec: Bidi factory 100, Rava mill 5,000, Cotton carding 2,500.
- **Sr. 49 Hotel – small:** fee is Rs. 0. The LOI will be for Rs. 0, which cannot be paid, so the application would stay
  in PENDINGPAYMENT. Confirm whether these businesses are exempt or need a different fee.
- **Role actions** are copied from `TL_APPROVER` in the local MDMS repo. If the server's action ids differ, copy the
  server's `TL_APPROVER` entries instead.
- **Categories** (Manufacturing, Retail, Wholesale, General services, Hotel/restaurant/lodging) are a proposed grouping for
  the UI dropdowns; they do not affect fees.
