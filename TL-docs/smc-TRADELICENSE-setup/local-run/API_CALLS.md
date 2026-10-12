# Trade license API calls, step by step

Recorded on the local stack by `capture-api-calls.ps1` for application `PB-TL-2026-10-02-005879` (Permanent, `TL_NEW`),
license number `PB-TL-2026-10-02-001289`. The bodies below are the real requests and responses.
The same JSON is in [api-samples/](api-samples/), one file per request and response.

Locally there is no gateway, so `RequestInfo.userInfo` is sent in the body and `authToken` is not checked.
On a deployed environment the gateway fills `userInfo` from the token.

| # | Step | Sent by | Call | Status after |
|---|---|---|---|---|
| 1 | INITIATE (create the application) | Citizen | `POST /tl-services/v1/_create` | INITIATED |
| 2 | SEARCH (read the application) | Citizen | `POST /tl-services/v1/_search?tenantId=pg.smc&applicationNumber=PB-TL-2026-10-02-005879` | INITIATED |
| 3 | APPLY (submit the application) | Citizen | `POST /tl-services/v1/_update` | APPLIED |
| 4 | FORWARD (document verification) | TL_DOC_VERIFIER | `POST /tl-services/v1/_update` | FIELDINSPECTION |
| 5 | FORWARD (field inspection) | TL_FIELD_INSPECTOR | `POST /tl-services/v1/_update` | PENDINGHODVERIFICATION |
| 6 | FORWARD (HOD verification) | TL_HOD | `POST /tl-services/v1/_update` | PENDINGAPPROVAL |
| 7 | APPROVE | TL_APPROVER | `POST /tl-services/v1/_update` | PENDINGPAYMENT |
| 8 | PAY (payment event) | collection-services (simulated) | `KAFKA topic egov.collection.payment-create` | APPROVED |
| 9 | SEARCH (approved license) | Citizen | `POST /tl-services/v1/_search?tenantId=pg.smc&applicationNumber=PB-TL-2026-10-02-005879` | APPROVED |

## 1. INITIATE (create the application)

- **Sent by:** Citizen
- **Call:** `POST http://localhost:8079/tl-services/v1/_create`
- Saves a draft. Only the license type and structure are validated at this stage.

Calls tl-services makes to other services while handling it, in order:

1. `POST http://localhost:8094/egov-mdms-service/v1/_search`
2. `POST http://localhost:8085/tl-calculator/billingslab/_search?tenantId=pg.smc`
3. `POST http://localhost:8088/egov-idgen/id/_generate`
4. `POST http://localhost:8086/egov-location/location/v11/boundarys/_search?tenantId=pg.smc&hierarchyTypeCode=REVENUE&boundaryType=Locality&codes=JLC476`
5. `POST http://localhost:8091/user/users/_createnovalidate`
6. `POST http://localhost:8085/tl-calculator/v1/_estimate`
7. `POST http://localhost:8280/egov-workflow-v2/egov-wf/process/_transition`
8. `POST http://localhost:8087/property-services/property/_search?tenantId=pg.smc&propertyIds=`

<details><summary>Request body</summary>

```json
{
    "Licenses":  [
                     {
                         "tenantId":  "pg.smc",
                         "businessService":  "TL",
                         "workflowCode":  "TL_NEW",
                         "licenseType":  "PERMANENT",
                         "applicationType":  "NEW",
                         "action":  "INITIATE",
                         "financialYear":  "2026-27",
                         "commencementDate":  1790812800000,
                         "tradeName":  "Cahndan",
                         "propertyId":  "",
                         "tradeLicenseDetail":  {
                                                    "channel":  "CITIZEN",
                                                    "structureType":  "IMMOVABLE.PUCCA",
                                                    "subOwnerShipCategory":  "INDIVIDUAL.SINGLEOWNER",
                                                    "noOfEmployees":  2,
                                                    "operationalArea":  1,
                                                    "surveyNo":  "1",
                                                    "address":  {
                                                                    "tenantId":  "pg.smc",
                                                                    "addressLine1":  "gh",
                                                                    "pincode":  "876655",
                                                                    "locality":  {
                                                                                     "code":  "JLC476"
                                                                                 }
                                                                },
                                                    "tradeUnits":  [
                                                                       {
                                                                           "tradeType":  "GOODS.MANUFACTURE.SMC-01",
                                                                           "uom":  null,
                                                                           "uomValue":  null
                                                                       }
                                                                   ],
                                                    "owners":  [
                                                                   {
                                                                       "name":  "chndndn",
                                                                       "mobileNumber":  "7747474747",
                                                                       "aadhaarNumber":  null,
                                                                       "fatherOrHusbandName":  "chndndn",
                                                                       "relationship":  "FATHER",
                                                                       "gender":  "MALE",
                                                                       "permanentAddress":  "ggggfg",
                                                                       "emailId":  null,
                                                                       "isPrimaryOwner":  true,
                                                                       "additionalDetails":  {
                                                                                                 "ownerSequence":  0,
                                                                                                 "name":  "chndndn",
                                                                                                 "aadhaarNumber":  null,
                                                                                                 "residentialAddress":  "ggggfg",
                                                                                                 "isprimaryowner":  true
                                                                                             },
                                                                       "dob":  null
                                                                   }
                                                               ],
                                                    "additionalDetail":  {
                                                                             "isImmovableStructure":  true,
                                                                             "firmRegistrationNo":  null,
                                                                             "legalStatus":  "OWNED",
                                                                             "noOfMachines":  2,
                                                                             "gatNo":  "2",
                                                                             "ctsNo":  "3",
                                                                             "plotNo":  "4",
                                                                             "landownerName":  "asit",
                                                                             "propertyId":  "",
                                                                             "isSameAsPropertyOwner":  null,
                                                                             "tradeGstNo":  null,
                                                                             "totalMachines":  2,
                                                                             "surveyNo":  "1",
                                                                             "propertyTaxNo":  null,
                                                                             "ownershipType":  null
                                                                         },
                                                    "applicationDocuments":  [

                                                                             ],
                                                    "accessories":  null
                                                },
                         "wfDocuments":  [

                                         ]
                     }
                 ],
    "RequestInfo":  {
                        "apiId":  "Rainmaker",
                        "authToken":  "not-checked-locally",
                        "msgId":  "local|en_IN",
                        "userInfo":  {
                                         "id":  17253,
                                         "uuid":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                         "userName":  "8908011908",
                                         "name":  "OWNER",
                                         "mobileNumber":  "8908011908",
                                         "type":  "CITIZEN",
                                         "tenantId":  "pg",
                                         "roles":  [
                                                       {
                                                           "code":  "CITIZEN",
                                                           "name":  "CITIZEN",
                                                           "tenantId":  "pg"
                                                       }
                                                   ]
                                     }
                    }
}
```

</details>

<details><summary>Response body (HTTP 200)</summary>

```json
{
    "ResponseInfo":  {
                         "apiId":  "Rainmaker",
                         "ver":  null,
                         "ts":  null,
                         "resMsgId":  "uief87324",
                         "msgId":  "local|en_IN",
                         "status":  "successful"
                     },
    "Licenses":  [
                     {
                         "comment":  null,
                         "id":  "2ca4d4e1-4847-4bcd-8928-06ce9058ce70",
                         "tenantId":  "pg.smc",
                         "businessService":  "TL",
                         "licenseType":  "PERMANENT",
                         "applicationType":  "NEW",
                         "workflowCode":  "TL_NEW",
                         "licenseNumber":  null,
                         "applicationNumber":  "PB-TL-2026-10-02-005879",
                         "oldLicenseNumber":  null,
                         "propertyId":  "",
                         "oldPropertyId":  null,
                         "accountId":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                         "tradeName":  "Cahndan",
                         "applicationDate":  1790879670758,
                         "commencementDate":  1790812800000,
                         "issuedDate":  null,
                         "financialYear":  "2026-27",
                         "validFrom":  1775001600000,
                         "validTo":  1806537599000,
                         "action":  "INITIATE",
                         "assignee":  null,
                         "wfDocuments":  [

                                         ],
                         "status":  "INITIATED",
                         "tradeLicenseDetail":  {
                                                    "id":  "ed7fcb86-52e9-4d7b-bc0c-04abef18f29d",
                                                    "surveyNo":  "1",
                                                    "subOwnerShipCategory":  "INDIVIDUAL.SINGLEOWNER",
                                                    "structureType":  "IMMOVABLE.PUCCA",
                                                    "operationalArea":  1.0,
                                                    "noOfEmployees":  2,
                                                    "adhocExemption":  null,
                                                    "adhocPenalty":  null,
                                                    "adhocExemptionReason":  null,
                                                    "adhocPenaltyReason":  null,
                                                    "owners":  [
                                                                   {
                                                                       "id":  17253,
                                                                       "uuid":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                       "userName":  "c58f64fa-6993-43e0-b752-f1cc7c9ebe0c",
                                                                       "password":  null,
                                                                       "salutation":  null,
                                                                       "name":  "chndndn",
                                                                       "gender":  "MALE",
                                                                       "mobileNumber":  "7747474747",
                                                                       "emailId":  null,
                                                                       "altContactNumber":  null,
                                                                       "pan":  null,
                                                                       "aadhaarNumber":  null,
                                                                       "permanentAddress":  "ggggfg",
                                                                       "permanentCity":  null,
                                                                       "permanentPinCode":  null,
                                                                       "correspondenceCity":  null,
                                                                       "correspondencePinCode":  null,
                                                                       "correspondenceAddress":  null,
                                                                       "active":  true,
                                                                       "dob":  null,
                                                                       "pwdExpiryDate":  null,
                                                                       "locale":  null,
                                                                       "type":  "CITIZEN",
                                                                       "signature":  null,
                                                                       "accountLocked":  null,
                                                                       "roles":  [
                                                                                     {
                                                                                         "id":  null,
                                                                                         "name":  "Citizen",
                                                                                         "code":  "CITIZEN",
                                                                                         "tenantId":  "pg"
                                                                                     }
                                                                                 ],
                                                                       "fatherOrHusbandName":  "chndndn",
                                                                       "bloodGroup":  null,
                                                                       "identificationMark":  null,
                                                                       "photo":  null,
                                                                       "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                       "createdDate":  1790879670850,
                                                                       "lastModifiedBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                       "lastModifiedDate":  1790879670850,
                                                                       "otpReference":  null,
                                                                       "tenantId":  "pg",
                                                                       "isPrimaryOwner":  true,
                                                                       "ownerShipPercentage":  null,
                                                                       "ownerType":  null,
                                                                       "institutionId":  null,
                                                                       "additionalDetails":  {
                                                                                                 "ownerSequence":  0,
                                                                                                 "name":  "chndndn",
                                                                                                 "aadhaarNumber":  null,
                                                                                                 "residentialAddress":  "ggggfg",
                                                                                                 "isprimaryowner":  true
                                                                                             },
                                                                       "documents":  null,
                                                                       "userActive":  true,
                                                                       "relationship":  "FATHER"
                                                                   }
                                                               ],
                                                    "channel":  "CITIZEN",
                                                    "address":  {
                                                                    "id":  "29ee3a78-2f9c-4d71-9808-673f1e82d8f2",
                                                                    "tenantId":  "pg.smc",
                                                                    "doorNo":  null,
                                                                    "latitude":  null,
                                                                    "longitude":  null,
                                                                    "addressId":  null,
                                                                    "addressNumber":  null,
                                                                    "type":  null,
                                                                    "addressLine1":  "gh",
                                                                    "addressLine2":  null,
                                                                    "landmark":  null,
                                                                    "city":  null,
                                                                    "pincode":  "876655",
                                                                    "detail":  null,
                                                                    "buildingName":  null,
                                                                    "street":  null,
                                                                    "locality":  {
                                                                                     "code":  "JLC476",
                                                                                     "name":  "Main Road Abadpura",
                                                                                     "label":  "Locality",
                                                                                     "latitude":  null,
                                                                                     "longitude":  null,
                                                                                     "children":  [

                                                                                                  ],
                                                                                     "materializedPath":  null
                                                                                 }
                                                                },
                                                    "tradeUnits":  [
                                                                       {
                                                                           "id":  "523a8023-02f0-4b80-90d1-b36f902ce98c",
                                                                           "tenantId":  "pg.smc",
                                                                           "active":  true,
                                                                           "tradeType":  "GOODS.MANUFACTURE.SMC-01",
                                                                           "uom":  null,
                                                                           "uomValue":  null,
                                                                           "auditDetails":  null
                                                                       }
                                                                   ],
                                                    "accessories":  null,
                                                    "applicationDocuments":  [

                                                                             ],
                                                    "verificationDocuments":  null,
                                                    "additionalDetail":  {
                                                                             "isImmovableStructure":  true,
                                                                             "firmRegistrationNo":  null,
                                                                             "legalStatus":  "OWNED",
                                                                             "noOfMachines":  2,
                                                                             "gatNo":  "2",
                                                                             "ctsNo":  "3",
                                                                             "plotNo":  "4",
                                                                             "landownerName":  "asit",
                                                                             "propertyId":  "",
                                                                             "isSameAsPropertyOwner":  null,
                                                                             "tradeGstNo":  null,
                                                                             "totalMachines":  2,
                                                                             "surveyNo":  "1",
                                                                             "propertyTaxNo":  null,
                                                                             "ownershipType":  null
                                                                         },
                                                    "institution":  null,
                                                    "auditDetails":  {
                                                                         "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                         "lastModifiedBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                         "createdTime":  1790879670758,
                                                                         "lastModifiedTime":  1790879670758
                                                                     }
                                                },
                         "calculation":  {
                                             "applicationNumber":  null,
                                             "tradeLicense":  null,
                                             "tenantId":  "pg.smc",
                                             "taxHeadEstimates":  [
                                                                      {
                                                                          "taxHeadCode":  "TL_TAX",
                                                                          "estimateAmount":  500.0,
                                                                          "category":  "TAX"
                                                                      }
                                                                  ],
                                             "tradeTypeBillingIds":  {
                                                                         "id":  "80991716-eb4f-49f0-8005-80a3ccd79f14",
                                                                         "fee":  500.0,
                                                                         "billingSlabIds":  [
                                                                                                "45fbed61-eda8-a9f3-482f-8df916722e6d|0|523a8023-02f0-4b80-90d1-b36f902ce98c"
                                                                                            ]
                                                                     },
                                             "accessoryBillingIds":  null
                                         },
                         "auditDetails":  {
                                              "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                              "lastModifiedBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                              "createdTime":  1790879670758,
                                              "lastModifiedTime":  1790879670758
                                          },
                         "fileStoreId":  null
                     }
                 ],
    "Count":  0,
    "applicationsIssued":  0,
    "applicationsRenewed":  0,
    "applicationValidity":  0
}
```

</details>

## 2. SEARCH (read the application)

- **Sent by:** Citizen
- **Call:** `POST http://localhost:8079/tl-services/v1/_search?tenantId=pg.smc&applicationNumber=PB-TL-2026-10-02-005879`
- Every update below starts from this response: take Licenses[0], change the action, send it back.

Calls tl-services makes to other services while handling it, in order:

1. `POST http://localhost:8086/egov-location/location/v11/boundarys/_search?tenantId=pg.smc&hierarchyTypeCode=REVENUE&boundaryType=Locality&codes=JLC476`
2. `POST http://localhost:8091/user/_search`

<details><summary>Request body</summary>

```json
{
    "RequestInfo":  {
                        "apiId":  "Rainmaker",
                        "authToken":  "not-checked-locally",
                        "msgId":  "local|en_IN",
                        "userInfo":  {
                                         "id":  17253,
                                         "uuid":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                         "userName":  "8908011908",
                                         "name":  "OWNER",
                                         "mobileNumber":  "8908011908",
                                         "type":  "CITIZEN",
                                         "tenantId":  "pg",
                                         "roles":  [
                                                       {
                                                           "code":  "CITIZEN",
                                                           "name":  "CITIZEN",
                                                           "tenantId":  "pg"
                                                       }
                                                   ]
                                     }
                    }
}
```

</details>

<details><summary>Response body (HTTP 200)</summary>

```json
{
    "ResponseInfo":  {
                         "apiId":  "Rainmaker",
                         "ver":  null,
                         "ts":  null,
                         "resMsgId":  "uief87324",
                         "msgId":  "local|en_IN",
                         "status":  "successful"
                     },
    "Licenses":  [
                     {
                         "comment":  null,
                         "id":  "2ca4d4e1-4847-4bcd-8928-06ce9058ce70",
                         "tenantId":  "pg.smc",
                         "businessService":  "TL",
                         "licenseType":  "PERMANENT",
                         "applicationType":  "NEW",
                         "workflowCode":  "TL_NEW",
                         "licenseNumber":  null,
                         "applicationNumber":  "PB-TL-2026-10-02-005879",
                         "oldLicenseNumber":  null,
                         "propertyId":  "",
                         "oldPropertyId":  null,
                         "accountId":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                         "tradeName":  "Cahndan",
                         "applicationDate":  1790879670758,
                         "commencementDate":  1790812800000,
                         "issuedDate":  null,
                         "financialYear":  "2026-27",
                         "validFrom":  1775001600000,
                         "validTo":  1806537599000,
                         "action":  "INITIATE",
                         "assignee":  null,
                         "wfDocuments":  null,
                         "status":  "INITIATED",
                         "tradeLicenseDetail":  {
                                                    "id":  "ed7fcb86-52e9-4d7b-bc0c-04abef18f29d",
                                                    "surveyNo":  "1",
                                                    "subOwnerShipCategory":  "INDIVIDUAL.SINGLEOWNER",
                                                    "structureType":  "IMMOVABLE.PUCCA",
                                                    "operationalArea":  1.0,
                                                    "noOfEmployees":  2,
                                                    "adhocExemption":  null,
                                                    "adhocPenalty":  null,
                                                    "adhocExemptionReason":  null,
                                                    "adhocPenaltyReason":  null,
                                                    "owners":  [
                                                                   {
                                                                       "id":  17253,
                                                                       "uuid":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                       "userName":  "8908011908",
                                                                       "password":  null,
                                                                       "salutation":  null,
                                                                       "name":  "OWNER",
                                                                       "gender":  null,
                                                                       "mobileNumber":  "8908011908",
                                                                       "emailId":  null,
                                                                       "altContactNumber":  null,
                                                                       "pan":  null,
                                                                       "aadhaarNumber":  null,
                                                                       "permanentAddress":  null,
                                                                       "permanentCity":  null,
                                                                       "permanentPinCode":  null,
                                                                       "correspondenceCity":  null,
                                                                       "correspondencePinCode":  null,
                                                                       "correspondenceAddress":  null,
                                                                       "active":  true,
                                                                       "dob":  null,
                                                                       "pwdExpiryDate":  null,
                                                                       "locale":  null,
                                                                       "type":  "CITIZEN",
                                                                       "signature":  null,
                                                                       "accountLocked":  null,
                                                                       "roles":  [
                                                                                     {
                                                                                         "id":  null,
                                                                                         "name":  "CITIZEN",
                                                                                         "code":  "CITIZEN",
                                                                                         "tenantId":  "pg"
                                                                                     }
                                                                                 ],
                                                                       "fatherOrHusbandName":  null,
                                                                       "bloodGroup":  null,
                                                                       "identificationMark":  null,
                                                                       "photo":  null,
                                                                       "createdBy":  null,
                                                                       "createdDate":  1790899474000,
                                                                       "lastModifiedBy":  null,
                                                                       "lastModifiedDate":  1790899474000,
                                                                       "otpReference":  null,
                                                                       "tenantId":  "pg",
                                                                       "isPrimaryOwner":  true,
                                                                       "ownerShipPercentage":  null,
                                                                       "ownerType":  null,
                                                                       "institutionId":  null,
                                                                       "additionalDetails":  {
                                                                                                 "name":  "chndndn",
                                                                                                 "aadhaarNumber":  null,
                                                                                                 "ownerSequence":  0,
                                                                                                 "isprimaryowner":  true,
                                                                                                 "residentialAddress":  "ggggfg"
                                                                                             },
                                                                       "documents":  null,
                                                                       "userActive":  true,
                                                                       "relationship":  "FATHER"
                                                                   }
                                                               ],
                                                    "channel":  "CITIZEN",
                                                    "address":  {
                                                                    "id":  "29ee3a78-2f9c-4d71-9808-673f1e82d8f2",
                                                                    "tenantId":  "pg.smc",
                                                                    "doorNo":  null,
                                                                    "latitude":  null,
                                                                    "longitude":  null,
                                                                    "addressId":  null,
                                                                    "addressNumber":  null,
                                                                    "type":  null,
                                                                    "addressLine1":  "gh",
                                                                    "addressLine2":  null,
                                                                    "landmark":  null,
                                                                    "city":  null,
                                                                    "pincode":  "876655",
                                                                    "detail":  null,
                                                                    "buildingName":  null,
                                                                    "street":  null,
                                                                    "locality":  {
                                                                                     "code":  "JLC476",
                                                                                     "name":  "Main Road Abadpura",
                                                                                     "label":  "Locality",
                                                                                     "latitude":  null,
                                                                                     "longitude":  null,
                                                                                     "children":  [

                                                                                                  ],
                                                                                     "materializedPath":  null
                                                                                 }
                                                                },
                                                    "tradeUnits":  [
                                                                       {
                                                                           "id":  "523a8023-02f0-4b80-90d1-b36f902ce98c",
                                                                           "tenantId":  "pg.smc",
                                                                           "active":  true,
                                                                           "tradeType":  "GOODS.MANUFACTURE.SMC-01",
                                                                           "uom":  null,
                                                                           "uomValue":  null,
                                                                           "auditDetails":  null
                                                                       }
                                                                   ],
                                                    "accessories":  null,
                                                    "applicationDocuments":  null,
                                                    "verificationDocuments":  null,
                                                    "additionalDetail":  {
                                                                             "ctsNo":  "3",
                                                                             "gatNo":  "2",
                                                                             "plotNo":  "4",
                                                                             "surveyNo":  "1",
                                                                             "propertyId":  "",
                                                                             "tradeGstNo":  null,
                                                                             "legalStatus":  "OWNED",
                                                                             "noOfMachines":  2,
                                                                             "landownerName":  "asit",
                                                                             "ownershipType":  null,
                                                                             "propertyTaxNo":  null,
                                                                             "totalMachines":  2,
                                                                             "firmRegistrationNo":  null,
                                                                             "isImmovableStructure":  true,
                                                                             "isSameAsPropertyOwner":  null
                                                                         },
                                                    "institution":  null,
                                                    "auditDetails":  {
                                                                         "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                         "lastModifiedBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                         "createdTime":  1790879670758,
                                                                         "lastModifiedTime":  1790879670758
                                                                     }
                                                },
                         "calculation":  null,
                         "auditDetails":  {
                                              "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                              "lastModifiedBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                              "createdTime":  1790879670758,
                                              "lastModifiedTime":  1790879670758
                                          },
                         "fileStoreId":  null
                     }
                 ],
    "Count":  1,
    "applicationsIssued":  6,
    "applicationsRenewed":  0,
    "applicationValidity":  1
}
```

</details>

## 3. APPLY (submit the application)

- **Sent by:** Citizen
- **Call:** `POST http://localhost:8079/tl-services/v1/_update`
- Changes to the searched license: action, propertyId, owner name / mobile / Aadhaar / address, addressLine1 and the six documents. All SMC checks run here.

Calls tl-services makes to other services while handling it, in order:

1. `POST http://localhost:8094/egov-mdms-service/v1/_search`
2. `POST http://localhost:8085/tl-calculator/billingslab/_search?tenantId=pg.smc`
3. `POST http://localhost:8280/egov-workflow-v2/egov-wf/businessservice/_search?tenantId=pg.smc&businessServices=TL_NEW`
4. `POST http://localhost:8086/egov-location/location/v11/boundarys/_search?tenantId=pg.smc&hierarchyTypeCode=REVENUE&boundaryType=Locality&codes=JLC476`
5. `POST http://localhost:8091/user/_search`
6. `POST http://localhost:8087/property-services/property/_search?tenantId=pg.smc&propertyIds=PG-PT-1013-008993`
7. `POST http://localhost:8082/billing-service/demand/_search?tenantId=pg.smc&businessService=PT&consumerCode=PG-PT-1013-008993&isPaymentCompleted=false`
8. `POST http://localhost:8089/ws-services/wc/_search?tenantId=pg.smc&propertyId=PG-PT-1013-008993&searchType=CONNECTION`
9. `POST http://localhost:8280/egov-workflow-v2/egov-wf/process/_transition`
10. `POST http://localhost:8091/user/_search`
11. `POST http://localhost:8091/user/users/_updatenovalidate`
12. `POST http://localhost:8085/tl-calculator/v1/_estimate`
13. `POST http://localhost:8087/property-services/property/_search?tenantId=pg.smc&propertyIds=`

<details><summary>Request body</summary>

```json
{
    "RequestInfo":  {
                        "apiId":  "Rainmaker",
                        "authToken":  "not-checked-locally",
                        "msgId":  "local|en_IN",
                        "userInfo":  {
                                         "id":  17253,
                                         "uuid":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                         "userName":  "8908011908",
                                         "name":  "OWNER",
                                         "mobileNumber":  "8908011908",
                                         "type":  "CITIZEN",
                                         "tenantId":  "pg",
                                         "roles":  [
                                                       {
                                                           "code":  "CITIZEN",
                                                           "name":  "CITIZEN",
                                                           "tenantId":  "pg"
                                                       }
                                                   ]
                                     }
                    },
    "Licenses":  [
                     {
                         "comment":  null,
                         "id":  "2ca4d4e1-4847-4bcd-8928-06ce9058ce70",
                         "tenantId":  "pg.smc",
                         "businessService":  "TL",
                         "licenseType":  "PERMANENT",
                         "applicationType":  "NEW",
                         "workflowCode":  "TL_NEW",
                         "licenseNumber":  null,
                         "applicationNumber":  "PB-TL-2026-10-02-005879",
                         "oldLicenseNumber":  null,
                         "propertyId":  "PG-PT-1013-008993",
                         "oldPropertyId":  null,
                         "accountId":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                         "tradeName":  "Cahndan",
                         "applicationDate":  1790879670758,
                         "commencementDate":  1790812800000,
                         "issuedDate":  null,
                         "financialYear":  "2026-27",
                         "validFrom":  1775001600000,
                         "validTo":  1806537599000,
                         "action":  "APPLY",
                         "assignee":  null,
                         "wfDocuments":  null,
                         "status":  "INITIATED",
                         "tradeLicenseDetail":  {
                                                    "id":  "ed7fcb86-52e9-4d7b-bc0c-04abef18f29d",
                                                    "surveyNo":  "1",
                                                    "subOwnerShipCategory":  "INDIVIDUAL.SINGLEOWNER",
                                                    "structureType":  "IMMOVABLE.PUCCA",
                                                    "operationalArea":  1.0,
                                                    "noOfEmployees":  2,
                                                    "adhocExemption":  null,
                                                    "adhocPenalty":  null,
                                                    "adhocExemptionReason":  null,
                                                    "adhocPenaltyReason":  null,
                                                    "owners":  [
                                                                   {
                                                                       "id":  17253,
                                                                       "uuid":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                       "userName":  "8908011908",
                                                                       "password":  null,
                                                                       "salutation":  null,
                                                                       "name":  "Local Test Owner",
                                                                       "gender":  null,
                                                                       "mobileNumber":  "7747474747",
                                                                       "emailId":  null,
                                                                       "altContactNumber":  null,
                                                                       "pan":  null,
                                                                       "permanentCity":  null,
                                                                       "permanentPinCode":  null,
                                                                       "correspondenceCity":  null,
                                                                       "correspondencePinCode":  null,
                                                                       "correspondenceAddress":  null,
                                                                       "active":  true,
                                                                       "dob":  null,
                                                                       "pwdExpiryDate":  null,
                                                                       "locale":  null,
                                                                       "type":  "CITIZEN",
                                                                       "signature":  null,
                                                                       "accountLocked":  null,
                                                                       "roles":  [
                                                                                     {
                                                                                         "id":  null,
                                                                                         "name":  "CITIZEN",
                                                                                         "code":  "CITIZEN",
                                                                                         "tenantId":  "pg"
                                                                                     }
                                                                                 ],
                                                                       "fatherOrHusbandName":  null,
                                                                       "bloodGroup":  null,
                                                                       "identificationMark":  null,
                                                                       "photo":  null,
                                                                       "createdBy":  null,
                                                                       "createdDate":  1790899474000,
                                                                       "lastModifiedBy":  null,
                                                                       "lastModifiedDate":  1790899474000,
                                                                       "otpReference":  null,
                                                                       "tenantId":  "pg",
                                                                       "isPrimaryOwner":  true,
                                                                       "ownerShipPercentage":  null,
                                                                       "ownerType":  null,
                                                                       "institutionId":  null,
                                                                       "additionalDetails":  {
                                                                                                 "name":  "chndndn",
                                                                                                 "aadhaarNumber":  null,
                                                                                                 "ownerSequence":  0,
                                                                                                 "isprimaryowner":  true,
                                                                                                 "residentialAddress":  "ggggfg"
                                                                                             },
                                                                       "documents":  null,
                                                                       "userActive":  true,
                                                                       "relationship":  "FATHER",
                                                                       "aadhaarNumber":  "234567894821",
                                                                       "permanentAddress":  "12, Test Colony, Sangamner"
                                                                   }
                                                               ],
                                                    "channel":  "CITIZEN",
                                                    "address":  {
                                                                    "id":  "29ee3a78-2f9c-4d71-9808-673f1e82d8f2",
                                                                    "tenantId":  "pg.smc",
                                                                    "doorNo":  null,
                                                                    "latitude":  null,
                                                                    "longitude":  null,
                                                                    "addressId":  null,
                                                                    "addressNumber":  null,
                                                                    "type":  null,
                                                                    "addressLine1":  "gh",
                                                                    "addressLine2":  null,
                                                                    "landmark":  null,
                                                                    "city":  null,
                                                                    "pincode":  "876655",
                                                                    "detail":  null,
                                                                    "buildingName":  null,
                                                                    "street":  null,
                                                                    "locality":  {
                                                                                     "code":  "JLC476",
                                                                                     "name":  "Main Road Abadpura",
                                                                                     "label":  "Locality",
                                                                                     "latitude":  null,
                                                                                     "longitude":  null,
                                                                                     "children":  [

                                                                                                  ],
                                                                                     "materializedPath":  null
                                                                                 }
                                                                },
                                                    "tradeUnits":  [
                                                                       {
                                                                           "id":  "523a8023-02f0-4b80-90d1-b36f902ce98c",
                                                                           "tenantId":  "pg.smc",
                                                                           "active":  true,
                                                                           "tradeType":  "GOODS.MANUFACTURE.SMC-01",
                                                                           "uom":  null,
                                                                           "uomValue":  null,
                                                                           "auditDetails":  null
                                                                       }
                                                                   ],
                                                    "accessories":  null,
                                                    "verificationDocuments":  null,
                                                    "additionalDetail":  {
                                                                             "ctsNo":  "3",
                                                                             "gatNo":  "2",
                                                                             "plotNo":  "4",
                                                                             "surveyNo":  "1",
                                                                             "propertyId":  "",
                                                                             "tradeGstNo":  null,
                                                                             "legalStatus":  "OWNED",
                                                                             "noOfMachines":  2,
                                                                             "landownerName":  "asit",
                                                                             "ownershipType":  null,
                                                                             "propertyTaxNo":  null,
                                                                             "totalMachines":  2,
                                                                             "firmRegistrationNo":  null,
                                                                             "isImmovableStructure":  true,
                                                                             "isSameAsPropertyOwner":  null
                                                                         },
                                                    "institution":  null,
                                                    "auditDetails":  {
                                                                         "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                         "lastModifiedBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                         "createdTime":  1790879670758,
                                                                         "lastModifiedTime":  1790879670758
                                                                     },
                                                    "applicationDocuments":  [
                                                                                 {
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "SEVENTWELVEEXTRACT",
                                                                                     "fileStoreId":  "local-test-seventwelveextract",
                                                                                     "active":  true
                                                                                 },
                                                                                 {
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "PROPERTYEXTRACT",
                                                                                     "fileStoreId":  "local-test-propertyextract",
                                                                                     "active":  true
                                                                                 },
                                                                                 {
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "AADHAARCARD",
                                                                                     "fileStoreId":  "local-test-aadhaarcard",
                                                                                     "active":  true
                                                                                 },
                                                                                 {
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "PROPERTYTAXRECEIPT",
                                                                                     "fileStoreId":  "local-test-propertytaxreceipt",
                                                                                     "active":  true
                                                                                 },
                                                                                 {
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "LANDOWNERCONSENT",
                                                                                     "fileStoreId":  "local-test-landownerconsent",
                                                                                     "active":  true
                                                                                 },
                                                                                 {
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "SHOPACTLICENSE",
                                                                                     "fileStoreId":  "local-test-shopactlicense",
                                                                                     "active":  true
                                                                                 }
                                                                             ]
                                                },
                         "calculation":  null,
                         "auditDetails":  {
                                              "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                              "lastModifiedBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                              "createdTime":  1790879670758,
                                              "lastModifiedTime":  1790879670758
                                          },
                         "fileStoreId":  null
                     }
                 ]
}
```

</details>

<details><summary>Response body (HTTP 200)</summary>

```json
{
    "ResponseInfo":  {
                         "apiId":  "Rainmaker",
                         "ver":  null,
                         "ts":  null,
                         "resMsgId":  "uief87324",
                         "msgId":  "local|en_IN",
                         "status":  "successful"
                     },
    "Licenses":  [
                     {
                         "comment":  null,
                         "id":  "2ca4d4e1-4847-4bcd-8928-06ce9058ce70",
                         "tenantId":  "pg.smc",
                         "businessService":  "TL",
                         "licenseType":  "PERMANENT",
                         "applicationType":  "NEW",
                         "workflowCode":  "TL_NEW",
                         "licenseNumber":  null,
                         "applicationNumber":  "PB-TL-2026-10-02-005879",
                         "oldLicenseNumber":  null,
                         "propertyId":  "PG-PT-1013-008993",
                         "oldPropertyId":  null,
                         "accountId":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                         "tradeName":  "Cahndan",
                         "applicationDate":  1790879670758,
                         "commencementDate":  1790812800000,
                         "issuedDate":  null,
                         "financialYear":  "2026-27",
                         "validFrom":  1775001600000,
                         "validTo":  1806537599000,
                         "action":  "APPLY",
                         "assignee":  null,
                         "wfDocuments":  null,
                         "status":  "APPLIED",
                         "tradeLicenseDetail":  {
                                                    "id":  "ed7fcb86-52e9-4d7b-bc0c-04abef18f29d",
                                                    "surveyNo":  "1",
                                                    "subOwnerShipCategory":  "INDIVIDUAL.SINGLEOWNER",
                                                    "structureType":  "IMMOVABLE.PUCCA",
                                                    "operationalArea":  1.0,
                                                    "noOfEmployees":  2,
                                                    "adhocExemption":  null,
                                                    "adhocPenalty":  null,
                                                    "adhocExemptionReason":  null,
                                                    "adhocPenaltyReason":  null,
                                                    "owners":  [
                                                                   {
                                                                       "id":  17253,
                                                                       "uuid":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                       "userName":  "8908011908",
                                                                       "password":  null,
                                                                       "salutation":  null,
                                                                       "name":  "Local Test Owner",
                                                                       "gender":  null,
                                                                       "mobileNumber":  "7747474747",
                                                                       "emailId":  null,
                                                                       "altContactNumber":  null,
                                                                       "pan":  null,
                                                                       "aadhaarNumber":  "234567894821",
                                                                       "permanentAddress":  "12, Test Colony, Sangamner",
                                                                       "permanentCity":  null,
                                                                       "permanentPinCode":  null,
                                                                       "correspondenceCity":  null,
                                                                       "correspondencePinCode":  null,
                                                                       "correspondenceAddress":  null,
                                                                       "active":  true,
                                                                       "dob":  null,
                                                                       "pwdExpiryDate":  null,
                                                                       "locale":  null,
                                                                       "type":  "CITIZEN",
                                                                       "signature":  null,
                                                                       "accountLocked":  null,
                                                                       "roles":  [
                                                                                     {
                                                                                         "id":  null,
                                                                                         "name":  "CITIZEN",
                                                                                         "code":  "CITIZEN",
                                                                                         "tenantId":  "pg"
                                                                                     }
                                                                                 ],
                                                                       "fatherOrHusbandName":  null,
                                                                       "bloodGroup":  null,
                                                                       "identificationMark":  null,
                                                                       "photo":  null,
                                                                       "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                       "createdDate":  1790879677925,
                                                                       "lastModifiedBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                       "lastModifiedDate":  1790879677925,
                                                                       "otpReference":  null,
                                                                       "tenantId":  "pg",
                                                                       "isPrimaryOwner":  true,
                                                                       "ownerShipPercentage":  null,
                                                                       "ownerType":  null,
                                                                       "institutionId":  null,
                                                                       "additionalDetails":  {
                                                                                                 "name":  "chndndn",
                                                                                                 "aadhaarNumber":  null,
                                                                                                 "ownerSequence":  0,
                                                                                                 "isprimaryowner":  true,
                                                                                                 "residentialAddress":  "ggggfg"
                                                                                             },
                                                                       "documents":  null,
                                                                       "userActive":  true,
                                                                       "relationship":  "FATHER"
                                                                   }
                                                               ],
                                                    "channel":  "CITIZEN",
                                                    "address":  {
                                                                    "id":  "29ee3a78-2f9c-4d71-9808-673f1e82d8f2",
                                                                    "tenantId":  "pg.smc",
                                                                    "doorNo":  null,
                                                                    "latitude":  null,
                                                                    "longitude":  null,
                                                                    "addressId":  null,
                                                                    "addressNumber":  null,
                                                                    "type":  null,
                                                                    "addressLine1":  "gh",
                                                                    "addressLine2":  null,
                                                                    "landmark":  null,
                                                                    "city":  null,
                                                                    "pincode":  "876655",
                                                                    "detail":  null,
                                                                    "buildingName":  null,
                                                                    "street":  null,
                                                                    "locality":  {
                                                                                     "code":  "JLC476",
                                                                                     "name":  "Main Road Abadpura",
                                                                                     "label":  "Locality",
                                                                                     "latitude":  null,
                                                                                     "longitude":  null,
                                                                                     "children":  [

                                                                                                  ],
                                                                                     "materializedPath":  null
                                                                                 }
                                                                },
                                                    "tradeUnits":  [
                                                                       {
                                                                           "id":  "523a8023-02f0-4b80-90d1-b36f902ce98c",
                                                                           "tenantId":  "pg.smc",
                                                                           "active":  true,
                                                                           "tradeType":  "GOODS.MANUFACTURE.SMC-01",
                                                                           "uom":  null,
                                                                           "uomValue":  null,
                                                                           "auditDetails":  null
                                                                       }
                                                                   ],
                                                    "accessories":  null,
                                                    "applicationDocuments":  [
                                                                                 {
                                                                                     "id":  "da52048e-a740-47a5-a981-f35088dc3b13",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "SEVENTWELVEEXTRACT",
                                                                                     "fileStoreId":  "local-test-seventwelveextract",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "572bbe0a-8176-4772-b57e-6084e6586a1c",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "PROPERTYEXTRACT",
                                                                                     "fileStoreId":  "local-test-propertyextract",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "bebb2fb1-5ebd-4c0e-bb5d-f38838ffb4db",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "AADHAARCARD",
                                                                                     "fileStoreId":  "local-test-aadhaarcard",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "1d9e819b-2674-4203-b055-624bd9bd06a2",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "PROPERTYTAXRECEIPT",
                                                                                     "fileStoreId":  "local-test-propertytaxreceipt",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "1d03afb8-3264-44c5-b0f1-d6eb4e346c10",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "LANDOWNERCONSENT",
                                                                                     "fileStoreId":  "local-test-landownerconsent",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "911173e4-35a1-4f00-bb55-04623faec1da",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "SHOPACTLICENSE",
                                                                                     "fileStoreId":  "local-test-shopactlicense",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 }
                                                                             ],
                                                    "verificationDocuments":  null,
                                                    "additionalDetail":  {
                                                                             "ctsNo":  "3",
                                                                             "gatNo":  "2",
                                                                             "plotNo":  "4",
                                                                             "surveyNo":  "1",
                                                                             "propertyId":  "",
                                                                             "tradeGstNo":  null,
                                                                             "legalStatus":  "OWNED",
                                                                             "noOfMachines":  2,
                                                                             "landownerName":  "asit",
                                                                             "ownershipType":  null,
                                                                             "propertyTaxNo":  null,
                                                                             "totalMachines":  2,
                                                                             "firmRegistrationNo":  null,
                                                                             "isImmovableStructure":  true,
                                                                             "isSameAsPropertyOwner":  null,
                                                                             "propertyTaxDues":  0,
                                                                             "waterDues":  0
                                                                         },
                                                    "institution":  null,
                                                    "auditDetails":  {
                                                                         "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                         "lastModifiedBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                         "createdTime":  1790879670758,
                                                                         "lastModifiedTime":  1790879677795
                                                                     }
                                                },
                         "calculation":  {
                                             "applicationNumber":  null,
                                             "tradeLicense":  null,
                                             "tenantId":  "pg.smc",
                                             "taxHeadEstimates":  [
                                                                      {
                                                                          "taxHeadCode":  "TL_TAX",
                                                                          "estimateAmount":  500.0,
                                                                          "category":  "TAX"
                                                                      }
                                                                  ],
                                             "tradeTypeBillingIds":  {
                                                                         "id":  "2b872000-6774-4a39-aab9-f128f70392e7",
                                                                         "fee":  500.0,
                                                                         "billingSlabIds":  [
                                                                                                "45fbed61-eda8-a9f3-482f-8df916722e6d|0|523a8023-02f0-4b80-90d1-b36f902ce98c"
                                                                                            ]
                                                                     },
                                             "accessoryBillingIds":  null
                                         },
                         "auditDetails":  {
                                              "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                              "lastModifiedBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                              "createdTime":  1790879670758,
                                              "lastModifiedTime":  1790879677795
                                          },
                         "fileStoreId":  null
                     }
                 ],
    "Count":  0,
    "applicationsIssued":  0,
    "applicationsRenewed":  0,
    "applicationValidity":  0
}
```

</details>

## 4. FORWARD (document verification)

- **Sent by:** TL_DOC_VERIFIER
- **Call:** `POST http://localhost:8079/tl-services/v1/_update`
- Change to the searched license: action = FORWARD. The role in RequestInfo.userInfo.roles must be TL_DOC_VERIFIER for tenant pg.smc.

Calls tl-services makes to other services while handling it, in order:

1. `POST http://localhost:8094/egov-mdms-service/v1/_search`
2. `POST http://localhost:8085/tl-calculator/billingslab/_search?tenantId=pg.smc`
3. `POST http://localhost:8280/egov-workflow-v2/egov-wf/businessservice/_search?tenantId=pg.smc&businessServices=TL_NEW`
4. `POST http://localhost:8086/egov-location/location/v11/boundarys/_search?tenantId=pg.smc&hierarchyTypeCode=REVENUE&boundaryType=Locality&codes=JLC476`
5. `POST http://localhost:8091/user/_search`
6. `POST http://localhost:8087/property-services/property/_search?tenantId=pg.smc&propertyIds=PG-PT-1013-008993`
7. `POST http://localhost:8280/egov-workflow-v2/egov-wf/process/_transition`
8. `POST http://localhost:8091/user/_search`
9. `POST http://localhost:8091/user/users/_updatenovalidate`
10. `POST http://localhost:8085/tl-calculator/v1/_estimate`
11. `POST http://localhost:8087/property-services/property/_search?tenantId=pg.smc&propertyIds=`

<details><summary>Request body</summary>

```json
{
    "RequestInfo":  {
                        "apiId":  "Rainmaker",
                        "authToken":  "not-checked-locally",
                        "msgId":  "local|en_IN",
                        "userInfo":  {
                                         "id":  1,
                                         "uuid":  "local-test-employee",
                                         "userName":  "LOCALEMP",
                                         "name":  "Local Test Employee",
                                         "mobileNumber":  "9999999999",
                                         "type":  "EMPLOYEE",
                                         "tenantId":  "pg.smc",
                                         "roles":  [
                                                       {
                                                           "code":  "TL_DOC_VERIFIER",
                                                           "name":  "TL_DOC_VERIFIER",
                                                           "tenantId":  "pg.smc"
                                                       }
                                                   ]
                                     }
                    },
    "Licenses":  [
                     {
                         "comment":  null,
                         "id":  "2ca4d4e1-4847-4bcd-8928-06ce9058ce70",
                         "tenantId":  "pg.smc",
                         "businessService":  "TL",
                         "licenseType":  "PERMANENT",
                         "applicationType":  "NEW",
                         "workflowCode":  "TL_NEW",
                         "licenseNumber":  null,
                         "applicationNumber":  "PB-TL-2026-10-02-005879",
                         "oldLicenseNumber":  null,
                         "propertyId":  "PG-PT-1013-008993",
                         "oldPropertyId":  null,
                         "accountId":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                         "tradeName":  "Cahndan",
                         "applicationDate":  1790879670758,
                         "commencementDate":  1790812800000,
                         "issuedDate":  null,
                         "financialYear":  "2026-27",
                         "validFrom":  1775001600000,
                         "validTo":  1806537599000,
                         "action":  "FORWARD",
                         "assignee":  null,
                         "wfDocuments":  null,
                         "status":  "APPLIED",
                         "tradeLicenseDetail":  {
                                                    "id":  "ed7fcb86-52e9-4d7b-bc0c-04abef18f29d",
                                                    "surveyNo":  "1",
                                                    "subOwnerShipCategory":  "INDIVIDUAL.SINGLEOWNER",
                                                    "structureType":  "IMMOVABLE.PUCCA",
                                                    "operationalArea":  1.0,
                                                    "noOfEmployees":  2,
                                                    "adhocExemption":  null,
                                                    "adhocPenalty":  null,
                                                    "adhocExemptionReason":  null,
                                                    "adhocPenaltyReason":  null,
                                                    "owners":  [
                                                                   {
                                                                       "id":  17253,
                                                                       "uuid":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                       "userName":  "8908011908",
                                                                       "password":  null,
                                                                       "salutation":  null,
                                                                       "name":  "OWNER",
                                                                       "gender":  null,
                                                                       "mobileNumber":  "8908011908",
                                                                       "emailId":  null,
                                                                       "altContactNumber":  null,
                                                                       "pan":  null,
                                                                       "aadhaarNumber":  null,
                                                                       "permanentAddress":  null,
                                                                       "permanentCity":  null,
                                                                       "permanentPinCode":  null,
                                                                       "correspondenceCity":  null,
                                                                       "correspondencePinCode":  null,
                                                                       "correspondenceAddress":  null,
                                                                       "active":  true,
                                                                       "dob":  null,
                                                                       "pwdExpiryDate":  null,
                                                                       "locale":  null,
                                                                       "type":  "CITIZEN",
                                                                       "signature":  null,
                                                                       "accountLocked":  null,
                                                                       "roles":  [
                                                                                     {
                                                                                         "id":  null,
                                                                                         "name":  "CITIZEN",
                                                                                         "code":  "CITIZEN",
                                                                                         "tenantId":  "pg"
                                                                                     }
                                                                                 ],
                                                                       "fatherOrHusbandName":  null,
                                                                       "bloodGroup":  null,
                                                                       "identificationMark":  null,
                                                                       "photo":  null,
                                                                       "createdBy":  null,
                                                                       "createdDate":  1790899481000,
                                                                       "lastModifiedBy":  null,
                                                                       "lastModifiedDate":  1790899481000,
                                                                       "otpReference":  null,
                                                                       "tenantId":  "pg",
                                                                       "isPrimaryOwner":  true,
                                                                       "ownerShipPercentage":  null,
                                                                       "ownerType":  null,
                                                                       "institutionId":  null,
                                                                       "additionalDetails":  {
                                                                                                 "name":  "chndndn",
                                                                                                 "aadhaarNumber":  null,
                                                                                                 "ownerSequence":  0,
                                                                                                 "isprimaryowner":  true,
                                                                                                 "residentialAddress":  "ggggfg"
                                                                                             },
                                                                       "documents":  null,
                                                                       "userActive":  true,
                                                                       "relationship":  "FATHER"
                                                                   }
                                                               ],
                                                    "channel":  "CITIZEN",
                                                    "address":  {
                                                                    "id":  "29ee3a78-2f9c-4d71-9808-673f1e82d8f2",
                                                                    "tenantId":  "pg.smc",
                                                                    "doorNo":  null,
                                                                    "latitude":  null,
                                                                    "longitude":  null,
                                                                    "addressId":  null,
                                                                    "addressNumber":  null,
                                                                    "type":  null,
                                                                    "addressLine1":  "gh",
                                                                    "addressLine2":  null,
                                                                    "landmark":  null,
                                                                    "city":  null,
                                                                    "pincode":  "876655",
                                                                    "detail":  null,
                                                                    "buildingName":  null,
                                                                    "street":  null,
                                                                    "locality":  {
                                                                                     "code":  "JLC476",
                                                                                     "name":  "Main Road Abadpura",
                                                                                     "label":  "Locality",
                                                                                     "latitude":  null,
                                                                                     "longitude":  null,
                                                                                     "children":  [

                                                                                                  ],
                                                                                     "materializedPath":  null
                                                                                 }
                                                                },
                                                    "tradeUnits":  [
                                                                       {
                                                                           "id":  "523a8023-02f0-4b80-90d1-b36f902ce98c",
                                                                           "tenantId":  "pg.smc",
                                                                           "active":  true,
                                                                           "tradeType":  "GOODS.MANUFACTURE.SMC-01",
                                                                           "uom":  null,
                                                                           "uomValue":  null,
                                                                           "auditDetails":  null
                                                                       }
                                                                   ],
                                                    "accessories":  null,
                                                    "applicationDocuments":  [
                                                                                 {
                                                                                     "id":  "911173e4-35a1-4f00-bb55-04623faec1da",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "SHOPACTLICENSE",
                                                                                     "fileStoreId":  "local-test-shopactlicense",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "1d03afb8-3264-44c5-b0f1-d6eb4e346c10",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "LANDOWNERCONSENT",
                                                                                     "fileStoreId":  "local-test-landownerconsent",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "1d9e819b-2674-4203-b055-624bd9bd06a2",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "PROPERTYTAXRECEIPT",
                                                                                     "fileStoreId":  "local-test-propertytaxreceipt",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "bebb2fb1-5ebd-4c0e-bb5d-f38838ffb4db",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "AADHAARCARD",
                                                                                     "fileStoreId":  "local-test-aadhaarcard",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "572bbe0a-8176-4772-b57e-6084e6586a1c",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "PROPERTYEXTRACT",
                                                                                     "fileStoreId":  "local-test-propertyextract",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "da52048e-a740-47a5-a981-f35088dc3b13",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "SEVENTWELVEEXTRACT",
                                                                                     "fileStoreId":  "local-test-seventwelveextract",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 }
                                                                             ],
                                                    "verificationDocuments":  null,
                                                    "additionalDetail":  {
                                                                             "ctsNo":  "3",
                                                                             "gatNo":  "2",
                                                                             "plotNo":  "4",
                                                                             "surveyNo":  "1",
                                                                             "waterDues":  0,
                                                                             "propertyId":  "",
                                                                             "tradeGstNo":  null,
                                                                             "legalStatus":  "OWNED",
                                                                             "noOfMachines":  2,
                                                                             "landownerName":  "asit",
                                                                             "ownershipType":  null,
                                                                             "propertyTaxNo":  null,
                                                                             "totalMachines":  2,
                                                                             "propertyTaxDues":  0,
                                                                             "firmRegistrationNo":  null,
                                                                             "isImmovableStructure":  true,
                                                                             "isSameAsPropertyOwner":  null
                                                                         },
                                                    "institution":  null,
                                                    "auditDetails":  {
                                                                         "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                         "lastModifiedBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                         "createdTime":  1790879670758,
                                                                         "lastModifiedTime":  1790879670758
                                                                     }
                                                },
                         "calculation":  null,
                         "auditDetails":  {
                                              "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                              "lastModifiedBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                              "createdTime":  1790879670758,
                                              "lastModifiedTime":  1790879677795
                                          },
                         "fileStoreId":  null
                     }
                 ]
}
```

</details>

<details><summary>Response body (HTTP 200)</summary>

```json
{
    "ResponseInfo":  {
                         "apiId":  "Rainmaker",
                         "ver":  null,
                         "ts":  null,
                         "resMsgId":  "uief87324",
                         "msgId":  "local|en_IN",
                         "status":  "successful"
                     },
    "Licenses":  [
                     {
                         "comment":  null,
                         "id":  "2ca4d4e1-4847-4bcd-8928-06ce9058ce70",
                         "tenantId":  "pg.smc",
                         "businessService":  "TL",
                         "licenseType":  "PERMANENT",
                         "applicationType":  "NEW",
                         "workflowCode":  "TL_NEW",
                         "licenseNumber":  null,
                         "applicationNumber":  "PB-TL-2026-10-02-005879",
                         "oldLicenseNumber":  null,
                         "propertyId":  "PG-PT-1013-008993",
                         "oldPropertyId":  null,
                         "accountId":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                         "tradeName":  "Cahndan",
                         "applicationDate":  1790879670758,
                         "commencementDate":  1790812800000,
                         "issuedDate":  null,
                         "financialYear":  "2026-27",
                         "validFrom":  1775001600000,
                         "validTo":  1806537599000,
                         "action":  "FORWARD",
                         "assignee":  null,
                         "wfDocuments":  null,
                         "status":  "FIELDINSPECTION",
                         "tradeLicenseDetail":  {
                                                    "id":  "ed7fcb86-52e9-4d7b-bc0c-04abef18f29d",
                                                    "surveyNo":  "1",
                                                    "subOwnerShipCategory":  "INDIVIDUAL.SINGLEOWNER",
                                                    "structureType":  "IMMOVABLE.PUCCA",
                                                    "operationalArea":  1.0,
                                                    "noOfEmployees":  2,
                                                    "adhocExemption":  null,
                                                    "adhocPenalty":  null,
                                                    "adhocExemptionReason":  null,
                                                    "adhocPenaltyReason":  null,
                                                    "owners":  [
                                                                   {
                                                                       "id":  1,
                                                                       "uuid":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                       "userName":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                       "password":  null,
                                                                       "salutation":  null,
                                                                       "name":  "OWNER",
                                                                       "gender":  null,
                                                                       "mobileNumber":  "8908011908",
                                                                       "emailId":  null,
                                                                       "altContactNumber":  null,
                                                                       "pan":  null,
                                                                       "aadhaarNumber":  null,
                                                                       "permanentAddress":  null,
                                                                       "permanentCity":  null,
                                                                       "permanentPinCode":  null,
                                                                       "correspondenceCity":  null,
                                                                       "correspondencePinCode":  null,
                                                                       "correspondenceAddress":  null,
                                                                       "active":  true,
                                                                       "dob":  null,
                                                                       "pwdExpiryDate":  null,
                                                                       "locale":  null,
                                                                       "type":  "CITIZEN",
                                                                       "signature":  null,
                                                                       "accountLocked":  null,
                                                                       "roles":  [
                                                                                     {
                                                                                         "id":  null,
                                                                                         "name":  "CITIZEN",
                                                                                         "code":  "CITIZEN",
                                                                                         "tenantId":  "pg"
                                                                                     }
                                                                                 ],
                                                                       "fatherOrHusbandName":  null,
                                                                       "bloodGroup":  null,
                                                                       "identificationMark":  null,
                                                                       "photo":  null,
                                                                       "createdBy":  "local-test-employee",
                                                                       "createdDate":  1790879681722,
                                                                       "lastModifiedBy":  "local-test-employee",
                                                                       "lastModifiedDate":  1790879681722,
                                                                       "otpReference":  null,
                                                                       "tenantId":  "pg",
                                                                       "isPrimaryOwner":  true,
                                                                       "ownerShipPercentage":  null,
                                                                       "ownerType":  null,
                                                                       "institutionId":  null,
                                                                       "additionalDetails":  {
                                                                                                 "name":  "chndndn",
                                                                                                 "aadhaarNumber":  null,
                                                                                                 "ownerSequence":  0,
                                                                                                 "isprimaryowner":  true,
                                                                                                 "residentialAddress":  "ggggfg"
                                                                                             },
                                                                       "documents":  null,
                                                                       "userActive":  true,
                                                                       "relationship":  "FATHER"
                                                                   }
                                                               ],
                                                    "channel":  "CITIZEN",
                                                    "address":  {
                                                                    "id":  "29ee3a78-2f9c-4d71-9808-673f1e82d8f2",
                                                                    "tenantId":  "pg.smc",
                                                                    "doorNo":  null,
                                                                    "latitude":  null,
                                                                    "longitude":  null,
                                                                    "addressId":  null,
                                                                    "addressNumber":  null,
                                                                    "type":  null,
                                                                    "addressLine1":  "gh",
                                                                    "addressLine2":  null,
                                                                    "landmark":  null,
                                                                    "city":  null,
                                                                    "pincode":  "876655",
                                                                    "detail":  null,
                                                                    "buildingName":  null,
                                                                    "street":  null,
                                                                    "locality":  {
                                                                                     "code":  "JLC476",
                                                                                     "name":  "Main Road Abadpura",
                                                                                     "label":  "Locality",
                                                                                     "latitude":  null,
                                                                                     "longitude":  null,
                                                                                     "children":  [

                                                                                                  ],
                                                                                     "materializedPath":  null
                                                                                 }
                                                                },
                                                    "tradeUnits":  [
                                                                       {
                                                                           "id":  "523a8023-02f0-4b80-90d1-b36f902ce98c",
                                                                           "tenantId":  "pg.smc",
                                                                           "active":  true,
                                                                           "tradeType":  "GOODS.MANUFACTURE.SMC-01",
                                                                           "uom":  null,
                                                                           "uomValue":  null,
                                                                           "auditDetails":  null
                                                                       }
                                                                   ],
                                                    "accessories":  null,
                                                    "applicationDocuments":  [
                                                                                 {
                                                                                     "id":  "911173e4-35a1-4f00-bb55-04623faec1da",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "SHOPACTLICENSE",
                                                                                     "fileStoreId":  "local-test-shopactlicense",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "1d03afb8-3264-44c5-b0f1-d6eb4e346c10",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "LANDOWNERCONSENT",
                                                                                     "fileStoreId":  "local-test-landownerconsent",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "1d9e819b-2674-4203-b055-624bd9bd06a2",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "PROPERTYTAXRECEIPT",
                                                                                     "fileStoreId":  "local-test-propertytaxreceipt",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "bebb2fb1-5ebd-4c0e-bb5d-f38838ffb4db",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "AADHAARCARD",
                                                                                     "fileStoreId":  "local-test-aadhaarcard",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "572bbe0a-8176-4772-b57e-6084e6586a1c",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "PROPERTYEXTRACT",
                                                                                     "fileStoreId":  "local-test-propertyextract",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "da52048e-a740-47a5-a981-f35088dc3b13",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "SEVENTWELVEEXTRACT",
                                                                                     "fileStoreId":  "local-test-seventwelveextract",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 }
                                                                             ],
                                                    "verificationDocuments":  null,
                                                    "additionalDetail":  {
                                                                             "ctsNo":  "3",
                                                                             "gatNo":  "2",
                                                                             "plotNo":  "4",
                                                                             "surveyNo":  "1",
                                                                             "waterDues":  0,
                                                                             "propertyId":  "",
                                                                             "tradeGstNo":  null,
                                                                             "legalStatus":  "OWNED",
                                                                             "noOfMachines":  2,
                                                                             "landownerName":  "asit",
                                                                             "ownershipType":  null,
                                                                             "propertyTaxNo":  null,
                                                                             "totalMachines":  2,
                                                                             "propertyTaxDues":  0,
                                                                             "firmRegistrationNo":  null,
                                                                             "isImmovableStructure":  true,
                                                                             "isSameAsPropertyOwner":  null
                                                                         },
                                                    "institution":  null,
                                                    "auditDetails":  {
                                                                         "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                         "lastModifiedBy":  "local-test-employee",
                                                                         "createdTime":  1790879670758,
                                                                         "lastModifiedTime":  1790879681592
                                                                     }
                                                },
                         "calculation":  {
                                             "applicationNumber":  null,
                                             "tradeLicense":  null,
                                             "tenantId":  "pg.smc",
                                             "taxHeadEstimates":  [
                                                                      {
                                                                          "taxHeadCode":  "TL_TAX",
                                                                          "estimateAmount":  500.0,
                                                                          "category":  "TAX"
                                                                      }
                                                                  ],
                                             "tradeTypeBillingIds":  {
                                                                         "id":  "f99eb93f-f857-4d58-bc02-c1ea43aace66",
                                                                         "fee":  500.0,
                                                                         "billingSlabIds":  [
                                                                                                "45fbed61-eda8-a9f3-482f-8df916722e6d|0|523a8023-02f0-4b80-90d1-b36f902ce98c"
                                                                                            ]
                                                                     },
                                             "accessoryBillingIds":  null
                                         },
                         "auditDetails":  {
                                              "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                              "lastModifiedBy":  "local-test-employee",
                                              "createdTime":  1790879670758,
                                              "lastModifiedTime":  1790879681592
                                          },
                         "fileStoreId":  null
                     }
                 ],
    "Count":  0,
    "applicationsIssued":  0,
    "applicationsRenewed":  0,
    "applicationValidity":  0
}
```

</details>

## 5. FORWARD (field inspection)

- **Sent by:** TL_FIELD_INSPECTOR
- **Call:** `POST http://localhost:8079/tl-services/v1/_update`
- Change to the searched license: action = FORWARD. The role in RequestInfo.userInfo.roles must be TL_FIELD_INSPECTOR for tenant pg.smc.

Calls tl-services makes to other services while handling it, in order:

1. `POST http://localhost:8094/egov-mdms-service/v1/_search`
2. `POST http://localhost:8085/tl-calculator/billingslab/_search?tenantId=pg.smc`
3. `POST http://localhost:8280/egov-workflow-v2/egov-wf/businessservice/_search?tenantId=pg.smc&businessServices=TL_NEW`
4. `POST http://localhost:8086/egov-location/location/v11/boundarys/_search?tenantId=pg.smc&hierarchyTypeCode=REVENUE&boundaryType=Locality&codes=JLC476`
5. `POST http://localhost:8091/user/_search`
6. `POST http://localhost:8087/property-services/property/_search?tenantId=pg.smc&propertyIds=PG-PT-1013-008993`
7. `POST http://localhost:8280/egov-workflow-v2/egov-wf/process/_transition`
8. `POST http://localhost:8091/user/_search`
9. `POST http://localhost:8091/user/users/_updatenovalidate`
10. `POST http://localhost:8085/tl-calculator/v1/_estimate`
11. `POST http://localhost:8087/property-services/property/_search?tenantId=pg.smc&propertyIds=`

<details><summary>Request body</summary>

```json
{
    "RequestInfo":  {
                        "apiId":  "Rainmaker",
                        "authToken":  "not-checked-locally",
                        "msgId":  "local|en_IN",
                        "userInfo":  {
                                         "id":  1,
                                         "uuid":  "local-test-employee",
                                         "userName":  "LOCALEMP",
                                         "name":  "Local Test Employee",
                                         "mobileNumber":  "9999999999",
                                         "type":  "EMPLOYEE",
                                         "tenantId":  "pg.smc",
                                         "roles":  [
                                                       {
                                                           "code":  "TL_FIELD_INSPECTOR",
                                                           "name":  "TL_FIELD_INSPECTOR",
                                                           "tenantId":  "pg.smc"
                                                       }
                                                   ]
                                     }
                    },
    "Licenses":  [
                     {
                         "comment":  null,
                         "id":  "2ca4d4e1-4847-4bcd-8928-06ce9058ce70",
                         "tenantId":  "pg.smc",
                         "businessService":  "TL",
                         "licenseType":  "PERMANENT",
                         "applicationType":  "NEW",
                         "workflowCode":  "TL_NEW",
                         "licenseNumber":  null,
                         "applicationNumber":  "PB-TL-2026-10-02-005879",
                         "oldLicenseNumber":  null,
                         "propertyId":  "PG-PT-1013-008993",
                         "oldPropertyId":  null,
                         "accountId":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                         "tradeName":  "Cahndan",
                         "applicationDate":  1790879670758,
                         "commencementDate":  1790812800000,
                         "issuedDate":  null,
                         "financialYear":  "2026-27",
                         "validFrom":  1775001600000,
                         "validTo":  1806537599000,
                         "action":  "FORWARD",
                         "assignee":  null,
                         "wfDocuments":  null,
                         "status":  "FIELDINSPECTION",
                         "tradeLicenseDetail":  {
                                                    "id":  "ed7fcb86-52e9-4d7b-bc0c-04abef18f29d",
                                                    "surveyNo":  "1",
                                                    "subOwnerShipCategory":  "INDIVIDUAL.SINGLEOWNER",
                                                    "structureType":  "IMMOVABLE.PUCCA",
                                                    "operationalArea":  1.0,
                                                    "noOfEmployees":  2,
                                                    "adhocExemption":  null,
                                                    "adhocPenalty":  null,
                                                    "adhocExemptionReason":  null,
                                                    "adhocPenaltyReason":  null,
                                                    "owners":  [
                                                                   {
                                                                       "id":  17253,
                                                                       "uuid":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                       "userName":  "8908011908",
                                                                       "password":  null,
                                                                       "salutation":  null,
                                                                       "name":  "OWNER",
                                                                       "gender":  null,
                                                                       "mobileNumber":  "8908011908",
                                                                       "emailId":  null,
                                                                       "altContactNumber":  null,
                                                                       "pan":  null,
                                                                       "aadhaarNumber":  null,
                                                                       "permanentAddress":  null,
                                                                       "permanentCity":  null,
                                                                       "permanentPinCode":  null,
                                                                       "correspondenceCity":  null,
                                                                       "correspondencePinCode":  null,
                                                                       "correspondenceAddress":  null,
                                                                       "active":  true,
                                                                       "dob":  null,
                                                                       "pwdExpiryDate":  null,
                                                                       "locale":  null,
                                                                       "type":  "CITIZEN",
                                                                       "signature":  null,
                                                                       "accountLocked":  null,
                                                                       "roles":  [
                                                                                     {
                                                                                         "id":  null,
                                                                                         "name":  "CITIZEN",
                                                                                         "code":  "CITIZEN",
                                                                                         "tenantId":  "pg"
                                                                                     }
                                                                                 ],
                                                                       "fatherOrHusbandName":  null,
                                                                       "bloodGroup":  null,
                                                                       "identificationMark":  null,
                                                                       "photo":  null,
                                                                       "createdBy":  null,
                                                                       "createdDate":  1790899485000,
                                                                       "lastModifiedBy":  null,
                                                                       "lastModifiedDate":  1790899485000,
                                                                       "otpReference":  null,
                                                                       "tenantId":  "pg",
                                                                       "isPrimaryOwner":  true,
                                                                       "ownerShipPercentage":  null,
                                                                       "ownerType":  null,
                                                                       "institutionId":  null,
                                                                       "additionalDetails":  {
                                                                                                 "name":  "chndndn",
                                                                                                 "aadhaarNumber":  null,
                                                                                                 "ownerSequence":  0,
                                                                                                 "isprimaryowner":  true,
                                                                                                 "residentialAddress":  "ggggfg"
                                                                                             },
                                                                       "documents":  null,
                                                                       "userActive":  true,
                                                                       "relationship":  "FATHER"
                                                                   }
                                                               ],
                                                    "channel":  "CITIZEN",
                                                    "address":  {
                                                                    "id":  "29ee3a78-2f9c-4d71-9808-673f1e82d8f2",
                                                                    "tenantId":  "pg.smc",
                                                                    "doorNo":  null,
                                                                    "latitude":  null,
                                                                    "longitude":  null,
                                                                    "addressId":  null,
                                                                    "addressNumber":  null,
                                                                    "type":  null,
                                                                    "addressLine1":  "gh",
                                                                    "addressLine2":  null,
                                                                    "landmark":  null,
                                                                    "city":  null,
                                                                    "pincode":  "876655",
                                                                    "detail":  null,
                                                                    "buildingName":  null,
                                                                    "street":  null,
                                                                    "locality":  {
                                                                                     "code":  "JLC476",
                                                                                     "name":  "Main Road Abadpura",
                                                                                     "label":  "Locality",
                                                                                     "latitude":  null,
                                                                                     "longitude":  null,
                                                                                     "children":  [

                                                                                                  ],
                                                                                     "materializedPath":  null
                                                                                 }
                                                                },
                                                    "tradeUnits":  [
                                                                       {
                                                                           "id":  "523a8023-02f0-4b80-90d1-b36f902ce98c",
                                                                           "tenantId":  "pg.smc",
                                                                           "active":  true,
                                                                           "tradeType":  "GOODS.MANUFACTURE.SMC-01",
                                                                           "uom":  null,
                                                                           "uomValue":  null,
                                                                           "auditDetails":  null
                                                                       }
                                                                   ],
                                                    "accessories":  null,
                                                    "applicationDocuments":  [
                                                                                 {
                                                                                     "id":  "911173e4-35a1-4f00-bb55-04623faec1da",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "SHOPACTLICENSE",
                                                                                     "fileStoreId":  "local-test-shopactlicense",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "1d03afb8-3264-44c5-b0f1-d6eb4e346c10",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "LANDOWNERCONSENT",
                                                                                     "fileStoreId":  "local-test-landownerconsent",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "1d9e819b-2674-4203-b055-624bd9bd06a2",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "PROPERTYTAXRECEIPT",
                                                                                     "fileStoreId":  "local-test-propertytaxreceipt",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "bebb2fb1-5ebd-4c0e-bb5d-f38838ffb4db",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "AADHAARCARD",
                                                                                     "fileStoreId":  "local-test-aadhaarcard",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "572bbe0a-8176-4772-b57e-6084e6586a1c",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "PROPERTYEXTRACT",
                                                                                     "fileStoreId":  "local-test-propertyextract",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "da52048e-a740-47a5-a981-f35088dc3b13",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "SEVENTWELVEEXTRACT",
                                                                                     "fileStoreId":  "local-test-seventwelveextract",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 }
                                                                             ],
                                                    "verificationDocuments":  null,
                                                    "additionalDetail":  {
                                                                             "ctsNo":  "3",
                                                                             "gatNo":  "2",
                                                                             "plotNo":  "4",
                                                                             "surveyNo":  "1",
                                                                             "waterDues":  0,
                                                                             "propertyId":  "",
                                                                             "tradeGstNo":  null,
                                                                             "legalStatus":  "OWNED",
                                                                             "noOfMachines":  2,
                                                                             "landownerName":  "asit",
                                                                             "ownershipType":  null,
                                                                             "propertyTaxNo":  null,
                                                                             "totalMachines":  2,
                                                                             "propertyTaxDues":  0,
                                                                             "firmRegistrationNo":  null,
                                                                             "isImmovableStructure":  true,
                                                                             "isSameAsPropertyOwner":  null
                                                                         },
                                                    "institution":  null,
                                                    "auditDetails":  {
                                                                         "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                         "lastModifiedBy":  "local-test-employee",
                                                                         "createdTime":  1790879670758,
                                                                         "lastModifiedTime":  1790879670758
                                                                     }
                                                },
                         "calculation":  null,
                         "auditDetails":  {
                                              "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                              "lastModifiedBy":  "local-test-employee",
                                              "createdTime":  1790879670758,
                                              "lastModifiedTime":  1790879681592
                                          },
                         "fileStoreId":  null
                     }
                 ]
}
```

</details>

<details><summary>Response body (HTTP 200)</summary>

```json
{
    "ResponseInfo":  {
                         "apiId":  "Rainmaker",
                         "ver":  null,
                         "ts":  null,
                         "resMsgId":  "uief87324",
                         "msgId":  "local|en_IN",
                         "status":  "successful"
                     },
    "Licenses":  [
                     {
                         "comment":  null,
                         "id":  "2ca4d4e1-4847-4bcd-8928-06ce9058ce70",
                         "tenantId":  "pg.smc",
                         "businessService":  "TL",
                         "licenseType":  "PERMANENT",
                         "applicationType":  "NEW",
                         "workflowCode":  "TL_NEW",
                         "licenseNumber":  null,
                         "applicationNumber":  "PB-TL-2026-10-02-005879",
                         "oldLicenseNumber":  null,
                         "propertyId":  "PG-PT-1013-008993",
                         "oldPropertyId":  null,
                         "accountId":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                         "tradeName":  "Cahndan",
                         "applicationDate":  1790879670758,
                         "commencementDate":  1790812800000,
                         "issuedDate":  null,
                         "financialYear":  "2026-27",
                         "validFrom":  1775001600000,
                         "validTo":  1806537599000,
                         "action":  "FORWARD",
                         "assignee":  null,
                         "wfDocuments":  null,
                         "status":  "PENDINGHODVERIFICATION",
                         "tradeLicenseDetail":  {
                                                    "id":  "ed7fcb86-52e9-4d7b-bc0c-04abef18f29d",
                                                    "surveyNo":  "1",
                                                    "subOwnerShipCategory":  "INDIVIDUAL.SINGLEOWNER",
                                                    "structureType":  "IMMOVABLE.PUCCA",
                                                    "operationalArea":  1.0,
                                                    "noOfEmployees":  2,
                                                    "adhocExemption":  null,
                                                    "adhocPenalty":  null,
                                                    "adhocExemptionReason":  null,
                                                    "adhocPenaltyReason":  null,
                                                    "owners":  [
                                                                   {
                                                                       "id":  1,
                                                                       "uuid":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                       "userName":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                       "password":  null,
                                                                       "salutation":  null,
                                                                       "name":  "OWNER",
                                                                       "gender":  null,
                                                                       "mobileNumber":  "8908011908",
                                                                       "emailId":  null,
                                                                       "altContactNumber":  null,
                                                                       "pan":  null,
                                                                       "aadhaarNumber":  null,
                                                                       "permanentAddress":  null,
                                                                       "permanentCity":  null,
                                                                       "permanentPinCode":  null,
                                                                       "correspondenceCity":  null,
                                                                       "correspondencePinCode":  null,
                                                                       "correspondenceAddress":  null,
                                                                       "active":  true,
                                                                       "dob":  null,
                                                                       "pwdExpiryDate":  null,
                                                                       "locale":  null,
                                                                       "type":  "CITIZEN",
                                                                       "signature":  null,
                                                                       "accountLocked":  null,
                                                                       "roles":  [
                                                                                     {
                                                                                         "id":  null,
                                                                                         "name":  "CITIZEN",
                                                                                         "code":  "CITIZEN",
                                                                                         "tenantId":  "pg"
                                                                                     }
                                                                                 ],
                                                                       "fatherOrHusbandName":  null,
                                                                       "bloodGroup":  null,
                                                                       "identificationMark":  null,
                                                                       "photo":  null,
                                                                       "createdBy":  "local-test-employee",
                                                                       "createdDate":  1790879685539,
                                                                       "lastModifiedBy":  "local-test-employee",
                                                                       "lastModifiedDate":  1790879685539,
                                                                       "otpReference":  null,
                                                                       "tenantId":  "pg",
                                                                       "isPrimaryOwner":  true,
                                                                       "ownerShipPercentage":  null,
                                                                       "ownerType":  null,
                                                                       "institutionId":  null,
                                                                       "additionalDetails":  {
                                                                                                 "name":  "chndndn",
                                                                                                 "aadhaarNumber":  null,
                                                                                                 "ownerSequence":  0,
                                                                                                 "isprimaryowner":  true,
                                                                                                 "residentialAddress":  "ggggfg"
                                                                                             },
                                                                       "documents":  null,
                                                                       "userActive":  true,
                                                                       "relationship":  "FATHER"
                                                                   }
                                                               ],
                                                    "channel":  "CITIZEN",
                                                    "address":  {
                                                                    "id":  "29ee3a78-2f9c-4d71-9808-673f1e82d8f2",
                                                                    "tenantId":  "pg.smc",
                                                                    "doorNo":  null,
                                                                    "latitude":  null,
                                                                    "longitude":  null,
                                                                    "addressId":  null,
                                                                    "addressNumber":  null,
                                                                    "type":  null,
                                                                    "addressLine1":  "gh",
                                                                    "addressLine2":  null,
                                                                    "landmark":  null,
                                                                    "city":  null,
                                                                    "pincode":  "876655",
                                                                    "detail":  null,
                                                                    "buildingName":  null,
                                                                    "street":  null,
                                                                    "locality":  {
                                                                                     "code":  "JLC476",
                                                                                     "name":  "Main Road Abadpura",
                                                                                     "label":  "Locality",
                                                                                     "latitude":  null,
                                                                                     "longitude":  null,
                                                                                     "children":  [

                                                                                                  ],
                                                                                     "materializedPath":  null
                                                                                 }
                                                                },
                                                    "tradeUnits":  [
                                                                       {
                                                                           "id":  "523a8023-02f0-4b80-90d1-b36f902ce98c",
                                                                           "tenantId":  "pg.smc",
                                                                           "active":  true,
                                                                           "tradeType":  "GOODS.MANUFACTURE.SMC-01",
                                                                           "uom":  null,
                                                                           "uomValue":  null,
                                                                           "auditDetails":  null
                                                                       }
                                                                   ],
                                                    "accessories":  null,
                                                    "applicationDocuments":  [
                                                                                 {
                                                                                     "id":  "911173e4-35a1-4f00-bb55-04623faec1da",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "SHOPACTLICENSE",
                                                                                     "fileStoreId":  "local-test-shopactlicense",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "1d03afb8-3264-44c5-b0f1-d6eb4e346c10",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "LANDOWNERCONSENT",
                                                                                     "fileStoreId":  "local-test-landownerconsent",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "1d9e819b-2674-4203-b055-624bd9bd06a2",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "PROPERTYTAXRECEIPT",
                                                                                     "fileStoreId":  "local-test-propertytaxreceipt",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "bebb2fb1-5ebd-4c0e-bb5d-f38838ffb4db",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "AADHAARCARD",
                                                                                     "fileStoreId":  "local-test-aadhaarcard",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "572bbe0a-8176-4772-b57e-6084e6586a1c",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "PROPERTYEXTRACT",
                                                                                     "fileStoreId":  "local-test-propertyextract",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "da52048e-a740-47a5-a981-f35088dc3b13",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "SEVENTWELVEEXTRACT",
                                                                                     "fileStoreId":  "local-test-seventwelveextract",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 }
                                                                             ],
                                                    "verificationDocuments":  null,
                                                    "additionalDetail":  {
                                                                             "ctsNo":  "3",
                                                                             "gatNo":  "2",
                                                                             "plotNo":  "4",
                                                                             "surveyNo":  "1",
                                                                             "waterDues":  0,
                                                                             "propertyId":  "",
                                                                             "tradeGstNo":  null,
                                                                             "legalStatus":  "OWNED",
                                                                             "noOfMachines":  2,
                                                                             "landownerName":  "asit",
                                                                             "ownershipType":  null,
                                                                             "propertyTaxNo":  null,
                                                                             "totalMachines":  2,
                                                                             "propertyTaxDues":  0,
                                                                             "firmRegistrationNo":  null,
                                                                             "isImmovableStructure":  true,
                                                                             "isSameAsPropertyOwner":  null
                                                                         },
                                                    "institution":  null,
                                                    "auditDetails":  {
                                                                         "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                         "lastModifiedBy":  "local-test-employee",
                                                                         "createdTime":  1790879670758,
                                                                         "lastModifiedTime":  1790879685410
                                                                     }
                                                },
                         "calculation":  {
                                             "applicationNumber":  null,
                                             "tradeLicense":  null,
                                             "tenantId":  "pg.smc",
                                             "taxHeadEstimates":  [
                                                                      {
                                                                          "taxHeadCode":  "TL_TAX",
                                                                          "estimateAmount":  500.0,
                                                                          "category":  "TAX"
                                                                      }
                                                                  ],
                                             "tradeTypeBillingIds":  {
                                                                         "id":  "f3755f32-b211-4607-b7ea-380f64ea5dda",
                                                                         "fee":  500.0,
                                                                         "billingSlabIds":  [
                                                                                                "45fbed61-eda8-a9f3-482f-8df916722e6d|0|523a8023-02f0-4b80-90d1-b36f902ce98c"
                                                                                            ]
                                                                     },
                                             "accessoryBillingIds":  null
                                         },
                         "auditDetails":  {
                                              "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                              "lastModifiedBy":  "local-test-employee",
                                              "createdTime":  1790879670758,
                                              "lastModifiedTime":  1790879685410
                                          },
                         "fileStoreId":  null
                     }
                 ],
    "Count":  0,
    "applicationsIssued":  0,
    "applicationsRenewed":  0,
    "applicationValidity":  0
}
```

</details>

## 6. FORWARD (HOD verification)

- **Sent by:** TL_HOD
- **Call:** `POST http://localhost:8079/tl-services/v1/_update`
- Change to the searched license: action = FORWARD. The role in RequestInfo.userInfo.roles must be TL_HOD for tenant pg.smc.

Calls tl-services makes to other services while handling it, in order:

1. `POST http://localhost:8094/egov-mdms-service/v1/_search`
2. `POST http://localhost:8085/tl-calculator/billingslab/_search?tenantId=pg.smc`
3. `POST http://localhost:8280/egov-workflow-v2/egov-wf/businessservice/_search?tenantId=pg.smc&businessServices=TL_NEW`
4. `POST http://localhost:8086/egov-location/location/v11/boundarys/_search?tenantId=pg.smc&hierarchyTypeCode=REVENUE&boundaryType=Locality&codes=JLC476`
5. `POST http://localhost:8091/user/_search`
6. `POST http://localhost:8087/property-services/property/_search?tenantId=pg.smc&propertyIds=PG-PT-1013-008993`
7. `POST http://localhost:8280/egov-workflow-v2/egov-wf/process/_transition`
8. `POST http://localhost:8091/user/_search`
9. `POST http://localhost:8091/user/users/_updatenovalidate`
10. `POST http://localhost:8085/tl-calculator/v1/_estimate`
11. `POST http://localhost:8087/property-services/property/_search?tenantId=pg.smc&propertyIds=`

<details><summary>Request body</summary>

```json
{
    "RequestInfo":  {
                        "apiId":  "Rainmaker",
                        "authToken":  "not-checked-locally",
                        "msgId":  "local|en_IN",
                        "userInfo":  {
                                         "id":  1,
                                         "uuid":  "local-test-employee",
                                         "userName":  "LOCALEMP",
                                         "name":  "Local Test Employee",
                                         "mobileNumber":  "9999999999",
                                         "type":  "EMPLOYEE",
                                         "tenantId":  "pg.smc",
                                         "roles":  [
                                                       {
                                                           "code":  "TL_HOD",
                                                           "name":  "TL_HOD",
                                                           "tenantId":  "pg.smc"
                                                       }
                                                   ]
                                     }
                    },
    "Licenses":  [
                     {
                         "comment":  null,
                         "id":  "2ca4d4e1-4847-4bcd-8928-06ce9058ce70",
                         "tenantId":  "pg.smc",
                         "businessService":  "TL",
                         "licenseType":  "PERMANENT",
                         "applicationType":  "NEW",
                         "workflowCode":  "TL_NEW",
                         "licenseNumber":  null,
                         "applicationNumber":  "PB-TL-2026-10-02-005879",
                         "oldLicenseNumber":  null,
                         "propertyId":  "PG-PT-1013-008993",
                         "oldPropertyId":  null,
                         "accountId":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                         "tradeName":  "Cahndan",
                         "applicationDate":  1790879670758,
                         "commencementDate":  1790812800000,
                         "issuedDate":  null,
                         "financialYear":  "2026-27",
                         "validFrom":  1775001600000,
                         "validTo":  1806537599000,
                         "action":  "FORWARD",
                         "assignee":  null,
                         "wfDocuments":  null,
                         "status":  "PENDINGHODVERIFICATION",
                         "tradeLicenseDetail":  {
                                                    "id":  "ed7fcb86-52e9-4d7b-bc0c-04abef18f29d",
                                                    "surveyNo":  "1",
                                                    "subOwnerShipCategory":  "INDIVIDUAL.SINGLEOWNER",
                                                    "structureType":  "IMMOVABLE.PUCCA",
                                                    "operationalArea":  1.0,
                                                    "noOfEmployees":  2,
                                                    "adhocExemption":  null,
                                                    "adhocPenalty":  null,
                                                    "adhocExemptionReason":  null,
                                                    "adhocPenaltyReason":  null,
                                                    "owners":  [
                                                                   {
                                                                       "id":  17253,
                                                                       "uuid":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                       "userName":  "8908011908",
                                                                       "password":  null,
                                                                       "salutation":  null,
                                                                       "name":  "OWNER",
                                                                       "gender":  null,
                                                                       "mobileNumber":  "8908011908",
                                                                       "emailId":  null,
                                                                       "altContactNumber":  null,
                                                                       "pan":  null,
                                                                       "aadhaarNumber":  null,
                                                                       "permanentAddress":  null,
                                                                       "permanentCity":  null,
                                                                       "permanentPinCode":  null,
                                                                       "correspondenceCity":  null,
                                                                       "correspondencePinCode":  null,
                                                                       "correspondenceAddress":  null,
                                                                       "active":  true,
                                                                       "dob":  null,
                                                                       "pwdExpiryDate":  null,
                                                                       "locale":  null,
                                                                       "type":  "CITIZEN",
                                                                       "signature":  null,
                                                                       "accountLocked":  null,
                                                                       "roles":  [
                                                                                     {
                                                                                         "id":  null,
                                                                                         "name":  "CITIZEN",
                                                                                         "code":  "CITIZEN",
                                                                                         "tenantId":  "pg"
                                                                                     }
                                                                                 ],
                                                                       "fatherOrHusbandName":  null,
                                                                       "bloodGroup":  null,
                                                                       "identificationMark":  null,
                                                                       "photo":  null,
                                                                       "createdBy":  null,
                                                                       "createdDate":  1790899488000,
                                                                       "lastModifiedBy":  null,
                                                                       "lastModifiedDate":  1790899488000,
                                                                       "otpReference":  null,
                                                                       "tenantId":  "pg",
                                                                       "isPrimaryOwner":  true,
                                                                       "ownerShipPercentage":  null,
                                                                       "ownerType":  null,
                                                                       "institutionId":  null,
                                                                       "additionalDetails":  {
                                                                                                 "name":  "chndndn",
                                                                                                 "aadhaarNumber":  null,
                                                                                                 "ownerSequence":  0,
                                                                                                 "isprimaryowner":  true,
                                                                                                 "residentialAddress":  "ggggfg"
                                                                                             },
                                                                       "documents":  null,
                                                                       "userActive":  true,
                                                                       "relationship":  "FATHER"
                                                                   }
                                                               ],
                                                    "channel":  "CITIZEN",
                                                    "address":  {
                                                                    "id":  "29ee3a78-2f9c-4d71-9808-673f1e82d8f2",
                                                                    "tenantId":  "pg.smc",
                                                                    "doorNo":  null,
                                                                    "latitude":  null,
                                                                    "longitude":  null,
                                                                    "addressId":  null,
                                                                    "addressNumber":  null,
                                                                    "type":  null,
                                                                    "addressLine1":  "gh",
                                                                    "addressLine2":  null,
                                                                    "landmark":  null,
                                                                    "city":  null,
                                                                    "pincode":  "876655",
                                                                    "detail":  null,
                                                                    "buildingName":  null,
                                                                    "street":  null,
                                                                    "locality":  {
                                                                                     "code":  "JLC476",
                                                                                     "name":  "Main Road Abadpura",
                                                                                     "label":  "Locality",
                                                                                     "latitude":  null,
                                                                                     "longitude":  null,
                                                                                     "children":  [

                                                                                                  ],
                                                                                     "materializedPath":  null
                                                                                 }
                                                                },
                                                    "tradeUnits":  [
                                                                       {
                                                                           "id":  "523a8023-02f0-4b80-90d1-b36f902ce98c",
                                                                           "tenantId":  "pg.smc",
                                                                           "active":  true,
                                                                           "tradeType":  "GOODS.MANUFACTURE.SMC-01",
                                                                           "uom":  null,
                                                                           "uomValue":  null,
                                                                           "auditDetails":  null
                                                                       }
                                                                   ],
                                                    "accessories":  null,
                                                    "applicationDocuments":  [
                                                                                 {
                                                                                     "id":  "911173e4-35a1-4f00-bb55-04623faec1da",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "SHOPACTLICENSE",
                                                                                     "fileStoreId":  "local-test-shopactlicense",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "1d03afb8-3264-44c5-b0f1-d6eb4e346c10",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "LANDOWNERCONSENT",
                                                                                     "fileStoreId":  "local-test-landownerconsent",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "1d9e819b-2674-4203-b055-624bd9bd06a2",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "PROPERTYTAXRECEIPT",
                                                                                     "fileStoreId":  "local-test-propertytaxreceipt",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "bebb2fb1-5ebd-4c0e-bb5d-f38838ffb4db",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "AADHAARCARD",
                                                                                     "fileStoreId":  "local-test-aadhaarcard",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "572bbe0a-8176-4772-b57e-6084e6586a1c",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "PROPERTYEXTRACT",
                                                                                     "fileStoreId":  "local-test-propertyextract",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "da52048e-a740-47a5-a981-f35088dc3b13",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "SEVENTWELVEEXTRACT",
                                                                                     "fileStoreId":  "local-test-seventwelveextract",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 }
                                                                             ],
                                                    "verificationDocuments":  null,
                                                    "additionalDetail":  {
                                                                             "ctsNo":  "3",
                                                                             "gatNo":  "2",
                                                                             "plotNo":  "4",
                                                                             "surveyNo":  "1",
                                                                             "waterDues":  0,
                                                                             "propertyId":  "",
                                                                             "tradeGstNo":  null,
                                                                             "legalStatus":  "OWNED",
                                                                             "noOfMachines":  2,
                                                                             "landownerName":  "asit",
                                                                             "ownershipType":  null,
                                                                             "propertyTaxNo":  null,
                                                                             "totalMachines":  2,
                                                                             "propertyTaxDues":  0,
                                                                             "firmRegistrationNo":  null,
                                                                             "isImmovableStructure":  true,
                                                                             "isSameAsPropertyOwner":  null
                                                                         },
                                                    "institution":  null,
                                                    "auditDetails":  {
                                                                         "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                         "lastModifiedBy":  "local-test-employee",
                                                                         "createdTime":  1790879670758,
                                                                         "lastModifiedTime":  1790879670758
                                                                     }
                                                },
                         "calculation":  null,
                         "auditDetails":  {
                                              "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                              "lastModifiedBy":  "local-test-employee",
                                              "createdTime":  1790879670758,
                                              "lastModifiedTime":  1790879685410
                                          },
                         "fileStoreId":  null
                     }
                 ]
}
```

</details>

<details><summary>Response body (HTTP 200)</summary>

```json
{
    "ResponseInfo":  {
                         "apiId":  "Rainmaker",
                         "ver":  null,
                         "ts":  null,
                         "resMsgId":  "uief87324",
                         "msgId":  "local|en_IN",
                         "status":  "successful"
                     },
    "Licenses":  [
                     {
                         "comment":  null,
                         "id":  "2ca4d4e1-4847-4bcd-8928-06ce9058ce70",
                         "tenantId":  "pg.smc",
                         "businessService":  "TL",
                         "licenseType":  "PERMANENT",
                         "applicationType":  "NEW",
                         "workflowCode":  "TL_NEW",
                         "licenseNumber":  null,
                         "applicationNumber":  "PB-TL-2026-10-02-005879",
                         "oldLicenseNumber":  null,
                         "propertyId":  "PG-PT-1013-008993",
                         "oldPropertyId":  null,
                         "accountId":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                         "tradeName":  "Cahndan",
                         "applicationDate":  1790879670758,
                         "commencementDate":  1790812800000,
                         "issuedDate":  null,
                         "financialYear":  "2026-27",
                         "validFrom":  1775001600000,
                         "validTo":  1806537599000,
                         "action":  "FORWARD",
                         "assignee":  null,
                         "wfDocuments":  null,
                         "status":  "PENDINGAPPROVAL",
                         "tradeLicenseDetail":  {
                                                    "id":  "ed7fcb86-52e9-4d7b-bc0c-04abef18f29d",
                                                    "surveyNo":  "1",
                                                    "subOwnerShipCategory":  "INDIVIDUAL.SINGLEOWNER",
                                                    "structureType":  "IMMOVABLE.PUCCA",
                                                    "operationalArea":  1.0,
                                                    "noOfEmployees":  2,
                                                    "adhocExemption":  null,
                                                    "adhocPenalty":  null,
                                                    "adhocExemptionReason":  null,
                                                    "adhocPenaltyReason":  null,
                                                    "owners":  [
                                                                   {
                                                                       "id":  1,
                                                                       "uuid":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                       "userName":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                       "password":  null,
                                                                       "salutation":  null,
                                                                       "name":  "OWNER",
                                                                       "gender":  null,
                                                                       "mobileNumber":  "8908011908",
                                                                       "emailId":  null,
                                                                       "altContactNumber":  null,
                                                                       "pan":  null,
                                                                       "aadhaarNumber":  null,
                                                                       "permanentAddress":  null,
                                                                       "permanentCity":  null,
                                                                       "permanentPinCode":  null,
                                                                       "correspondenceCity":  null,
                                                                       "correspondencePinCode":  null,
                                                                       "correspondenceAddress":  null,
                                                                       "active":  true,
                                                                       "dob":  null,
                                                                       "pwdExpiryDate":  null,
                                                                       "locale":  null,
                                                                       "type":  "CITIZEN",
                                                                       "signature":  null,
                                                                       "accountLocked":  null,
                                                                       "roles":  [
                                                                                     {
                                                                                         "id":  null,
                                                                                         "name":  "CITIZEN",
                                                                                         "code":  "CITIZEN",
                                                                                         "tenantId":  "pg"
                                                                                     }
                                                                                 ],
                                                                       "fatherOrHusbandName":  null,
                                                                       "bloodGroup":  null,
                                                                       "identificationMark":  null,
                                                                       "photo":  null,
                                                                       "createdBy":  "local-test-employee",
                                                                       "createdDate":  1790879689299,
                                                                       "lastModifiedBy":  "local-test-employee",
                                                                       "lastModifiedDate":  1790879689299,
                                                                       "otpReference":  null,
                                                                       "tenantId":  "pg",
                                                                       "isPrimaryOwner":  true,
                                                                       "ownerShipPercentage":  null,
                                                                       "ownerType":  null,
                                                                       "institutionId":  null,
                                                                       "additionalDetails":  {
                                                                                                 "name":  "chndndn",
                                                                                                 "aadhaarNumber":  null,
                                                                                                 "ownerSequence":  0,
                                                                                                 "isprimaryowner":  true,
                                                                                                 "residentialAddress":  "ggggfg"
                                                                                             },
                                                                       "documents":  null,
                                                                       "userActive":  true,
                                                                       "relationship":  "FATHER"
                                                                   }
                                                               ],
                                                    "channel":  "CITIZEN",
                                                    "address":  {
                                                                    "id":  "29ee3a78-2f9c-4d71-9808-673f1e82d8f2",
                                                                    "tenantId":  "pg.smc",
                                                                    "doorNo":  null,
                                                                    "latitude":  null,
                                                                    "longitude":  null,
                                                                    "addressId":  null,
                                                                    "addressNumber":  null,
                                                                    "type":  null,
                                                                    "addressLine1":  "gh",
                                                                    "addressLine2":  null,
                                                                    "landmark":  null,
                                                                    "city":  null,
                                                                    "pincode":  "876655",
                                                                    "detail":  null,
                                                                    "buildingName":  null,
                                                                    "street":  null,
                                                                    "locality":  {
                                                                                     "code":  "JLC476",
                                                                                     "name":  "Main Road Abadpura",
                                                                                     "label":  "Locality",
                                                                                     "latitude":  null,
                                                                                     "longitude":  null,
                                                                                     "children":  [

                                                                                                  ],
                                                                                     "materializedPath":  null
                                                                                 }
                                                                },
                                                    "tradeUnits":  [
                                                                       {
                                                                           "id":  "523a8023-02f0-4b80-90d1-b36f902ce98c",
                                                                           "tenantId":  "pg.smc",
                                                                           "active":  true,
                                                                           "tradeType":  "GOODS.MANUFACTURE.SMC-01",
                                                                           "uom":  null,
                                                                           "uomValue":  null,
                                                                           "auditDetails":  null
                                                                       }
                                                                   ],
                                                    "accessories":  null,
                                                    "applicationDocuments":  [
                                                                                 {
                                                                                     "id":  "911173e4-35a1-4f00-bb55-04623faec1da",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "SHOPACTLICENSE",
                                                                                     "fileStoreId":  "local-test-shopactlicense",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "1d03afb8-3264-44c5-b0f1-d6eb4e346c10",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "LANDOWNERCONSENT",
                                                                                     "fileStoreId":  "local-test-landownerconsent",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "1d9e819b-2674-4203-b055-624bd9bd06a2",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "PROPERTYTAXRECEIPT",
                                                                                     "fileStoreId":  "local-test-propertytaxreceipt",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "bebb2fb1-5ebd-4c0e-bb5d-f38838ffb4db",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "AADHAARCARD",
                                                                                     "fileStoreId":  "local-test-aadhaarcard",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "572bbe0a-8176-4772-b57e-6084e6586a1c",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "PROPERTYEXTRACT",
                                                                                     "fileStoreId":  "local-test-propertyextract",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "da52048e-a740-47a5-a981-f35088dc3b13",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "SEVENTWELVEEXTRACT",
                                                                                     "fileStoreId":  "local-test-seventwelveextract",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 }
                                                                             ],
                                                    "verificationDocuments":  null,
                                                    "additionalDetail":  {
                                                                             "ctsNo":  "3",
                                                                             "gatNo":  "2",
                                                                             "plotNo":  "4",
                                                                             "surveyNo":  "1",
                                                                             "waterDues":  0,
                                                                             "propertyId":  "",
                                                                             "tradeGstNo":  null,
                                                                             "legalStatus":  "OWNED",
                                                                             "noOfMachines":  2,
                                                                             "landownerName":  "asit",
                                                                             "ownershipType":  null,
                                                                             "propertyTaxNo":  null,
                                                                             "totalMachines":  2,
                                                                             "propertyTaxDues":  0,
                                                                             "firmRegistrationNo":  null,
                                                                             "isImmovableStructure":  true,
                                                                             "isSameAsPropertyOwner":  null
                                                                         },
                                                    "institution":  null,
                                                    "auditDetails":  {
                                                                         "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                         "lastModifiedBy":  "local-test-employee",
                                                                         "createdTime":  1790879670758,
                                                                         "lastModifiedTime":  1790879670758
                                                                     }
                                                },
                         "calculation":  {
                                             "applicationNumber":  null,
                                             "tradeLicense":  null,
                                             "tenantId":  "pg.smc",
                                             "taxHeadEstimates":  [
                                                                      {
                                                                          "taxHeadCode":  "TL_TAX",
                                                                          "estimateAmount":  500.0,
                                                                          "category":  "TAX"
                                                                      }
                                                                  ],
                                             "tradeTypeBillingIds":  {
                                                                         "id":  "a8080a4b-d68c-4d23-9a88-00aad1831775",
                                                                         "fee":  500.0,
                                                                         "billingSlabIds":  [
                                                                                                "45fbed61-eda8-a9f3-482f-8df916722e6d|0|523a8023-02f0-4b80-90d1-b36f902ce98c"
                                                                                            ]
                                                                     },
                                             "accessoryBillingIds":  null
                                         },
                         "auditDetails":  {
                                              "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                              "lastModifiedBy":  "local-test-employee",
                                              "createdTime":  1790879670758,
                                              "lastModifiedTime":  1790879689184
                                          },
                         "fileStoreId":  null
                     }
                 ],
    "Count":  0,
    "applicationsIssued":  0,
    "applicationsRenewed":  0,
    "applicationValidity":  0
}
```

</details>

## 7. APPROVE

- **Sent by:** TL_APPROVER
- **Call:** `POST http://localhost:8079/tl-services/v1/_update`
- Change to the searched license: action = APPROVE. The role in RequestInfo.userInfo.roles must be TL_APPROVER for tenant pg.smc. The fee is calculated and the demand is created at this step.

Calls tl-services makes to other services while handling it, in order:

1. `POST http://localhost:8094/egov-mdms-service/v1/_search`
2. `POST http://localhost:8085/tl-calculator/billingslab/_search?tenantId=pg.smc`
3. `POST http://localhost:8280/egov-workflow-v2/egov-wf/businessservice/_search?tenantId=pg.smc&businessServices=TL_NEW`
4. `POST http://localhost:8086/egov-location/location/v11/boundarys/_search?tenantId=pg.smc&hierarchyTypeCode=REVENUE&boundaryType=Locality&codes=JLC476`
5. `POST http://localhost:8091/user/_search`
6. `POST http://localhost:8087/property-services/property/_search?tenantId=pg.smc&propertyIds=PG-PT-1013-008993`
7. `POST http://localhost:8280/egov-workflow-v2/egov-wf/process/_transition`
8. `POST http://localhost:8091/user/_search`
9. `POST http://localhost:8091/user/users/_updatenovalidate`
10. `POST http://localhost:8085/tl-calculator/v1/_calculate`
11. `POST http://localhost:8087/property-services/property/_search?tenantId=pg.smc&propertyIds=`

<details><summary>Request body</summary>

```json
{
    "RequestInfo":  {
                        "apiId":  "Rainmaker",
                        "authToken":  "not-checked-locally",
                        "msgId":  "local|en_IN",
                        "userInfo":  {
                                         "id":  1,
                                         "uuid":  "local-test-employee",
                                         "userName":  "LOCALEMP",
                                         "name":  "Local Test Employee",
                                         "mobileNumber":  "9999999999",
                                         "type":  "EMPLOYEE",
                                         "tenantId":  "pg.smc",
                                         "roles":  [
                                                       {
                                                           "code":  "TL_APPROVER",
                                                           "name":  "TL_APPROVER",
                                                           "tenantId":  "pg.smc"
                                                       }
                                                   ]
                                     }
                    },
    "Licenses":  [
                     {
                         "comment":  null,
                         "id":  "2ca4d4e1-4847-4bcd-8928-06ce9058ce70",
                         "tenantId":  "pg.smc",
                         "businessService":  "TL",
                         "licenseType":  "PERMANENT",
                         "applicationType":  "NEW",
                         "workflowCode":  "TL_NEW",
                         "licenseNumber":  null,
                         "applicationNumber":  "PB-TL-2026-10-02-005879",
                         "oldLicenseNumber":  null,
                         "propertyId":  "PG-PT-1013-008993",
                         "oldPropertyId":  null,
                         "accountId":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                         "tradeName":  "Cahndan",
                         "applicationDate":  1790879670758,
                         "commencementDate":  1790812800000,
                         "issuedDate":  null,
                         "financialYear":  "2026-27",
                         "validFrom":  1775001600000,
                         "validTo":  1806537599000,
                         "action":  "APPROVE",
                         "assignee":  null,
                         "wfDocuments":  null,
                         "status":  "PENDINGAPPROVAL",
                         "tradeLicenseDetail":  {
                                                    "id":  "ed7fcb86-52e9-4d7b-bc0c-04abef18f29d",
                                                    "surveyNo":  "1",
                                                    "subOwnerShipCategory":  "INDIVIDUAL.SINGLEOWNER",
                                                    "structureType":  "IMMOVABLE.PUCCA",
                                                    "operationalArea":  1.0,
                                                    "noOfEmployees":  2,
                                                    "adhocExemption":  null,
                                                    "adhocPenalty":  null,
                                                    "adhocExemptionReason":  null,
                                                    "adhocPenaltyReason":  null,
                                                    "owners":  [
                                                                   {
                                                                       "id":  17253,
                                                                       "uuid":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                       "userName":  "8908011908",
                                                                       "password":  null,
                                                                       "salutation":  null,
                                                                       "name":  "OWNER",
                                                                       "gender":  null,
                                                                       "mobileNumber":  "8908011908",
                                                                       "emailId":  null,
                                                                       "altContactNumber":  null,
                                                                       "pan":  null,
                                                                       "aadhaarNumber":  null,
                                                                       "permanentAddress":  null,
                                                                       "permanentCity":  null,
                                                                       "permanentPinCode":  null,
                                                                       "correspondenceCity":  null,
                                                                       "correspondencePinCode":  null,
                                                                       "correspondenceAddress":  null,
                                                                       "active":  true,
                                                                       "dob":  null,
                                                                       "pwdExpiryDate":  null,
                                                                       "locale":  null,
                                                                       "type":  "CITIZEN",
                                                                       "signature":  null,
                                                                       "accountLocked":  null,
                                                                       "roles":  [
                                                                                     {
                                                                                         "id":  null,
                                                                                         "name":  "CITIZEN",
                                                                                         "code":  "CITIZEN",
                                                                                         "tenantId":  "pg"
                                                                                     }
                                                                                 ],
                                                                       "fatherOrHusbandName":  null,
                                                                       "bloodGroup":  null,
                                                                       "identificationMark":  null,
                                                                       "photo":  null,
                                                                       "createdBy":  null,
                                                                       "createdDate":  1790899492000,
                                                                       "lastModifiedBy":  null,
                                                                       "lastModifiedDate":  1790899492000,
                                                                       "otpReference":  null,
                                                                       "tenantId":  "pg",
                                                                       "isPrimaryOwner":  true,
                                                                       "ownerShipPercentage":  null,
                                                                       "ownerType":  null,
                                                                       "institutionId":  null,
                                                                       "additionalDetails":  {
                                                                                                 "name":  "chndndn",
                                                                                                 "aadhaarNumber":  null,
                                                                                                 "ownerSequence":  0,
                                                                                                 "isprimaryowner":  true,
                                                                                                 "residentialAddress":  "ggggfg"
                                                                                             },
                                                                       "documents":  null,
                                                                       "userActive":  true,
                                                                       "relationship":  "FATHER"
                                                                   }
                                                               ],
                                                    "channel":  "CITIZEN",
                                                    "address":  {
                                                                    "id":  "29ee3a78-2f9c-4d71-9808-673f1e82d8f2",
                                                                    "tenantId":  "pg.smc",
                                                                    "doorNo":  null,
                                                                    "latitude":  null,
                                                                    "longitude":  null,
                                                                    "addressId":  null,
                                                                    "addressNumber":  null,
                                                                    "type":  null,
                                                                    "addressLine1":  "gh",
                                                                    "addressLine2":  null,
                                                                    "landmark":  null,
                                                                    "city":  null,
                                                                    "pincode":  "876655",
                                                                    "detail":  null,
                                                                    "buildingName":  null,
                                                                    "street":  null,
                                                                    "locality":  {
                                                                                     "code":  "JLC476",
                                                                                     "name":  "Main Road Abadpura",
                                                                                     "label":  "Locality",
                                                                                     "latitude":  null,
                                                                                     "longitude":  null,
                                                                                     "children":  [

                                                                                                  ],
                                                                                     "materializedPath":  null
                                                                                 }
                                                                },
                                                    "tradeUnits":  [
                                                                       {
                                                                           "id":  "523a8023-02f0-4b80-90d1-b36f902ce98c",
                                                                           "tenantId":  "pg.smc",
                                                                           "active":  true,
                                                                           "tradeType":  "GOODS.MANUFACTURE.SMC-01",
                                                                           "uom":  null,
                                                                           "uomValue":  null,
                                                                           "auditDetails":  null
                                                                       }
                                                                   ],
                                                    "accessories":  null,
                                                    "applicationDocuments":  [
                                                                                 {
                                                                                     "id":  "911173e4-35a1-4f00-bb55-04623faec1da",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "SHOPACTLICENSE",
                                                                                     "fileStoreId":  "local-test-shopactlicense",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "1d03afb8-3264-44c5-b0f1-d6eb4e346c10",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "LANDOWNERCONSENT",
                                                                                     "fileStoreId":  "local-test-landownerconsent",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "1d9e819b-2674-4203-b055-624bd9bd06a2",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "PROPERTYTAXRECEIPT",
                                                                                     "fileStoreId":  "local-test-propertytaxreceipt",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "bebb2fb1-5ebd-4c0e-bb5d-f38838ffb4db",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "AADHAARCARD",
                                                                                     "fileStoreId":  "local-test-aadhaarcard",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "572bbe0a-8176-4772-b57e-6084e6586a1c",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "PROPERTYEXTRACT",
                                                                                     "fileStoreId":  "local-test-propertyextract",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "da52048e-a740-47a5-a981-f35088dc3b13",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "SEVENTWELVEEXTRACT",
                                                                                     "fileStoreId":  "local-test-seventwelveextract",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 }
                                                                             ],
                                                    "verificationDocuments":  null,
                                                    "additionalDetail":  {
                                                                             "ctsNo":  "3",
                                                                             "gatNo":  "2",
                                                                             "plotNo":  "4",
                                                                             "surveyNo":  "1",
                                                                             "waterDues":  0,
                                                                             "propertyId":  "",
                                                                             "tradeGstNo":  null,
                                                                             "legalStatus":  "OWNED",
                                                                             "noOfMachines":  2,
                                                                             "landownerName":  "asit",
                                                                             "ownershipType":  null,
                                                                             "propertyTaxNo":  null,
                                                                             "totalMachines":  2,
                                                                             "propertyTaxDues":  0,
                                                                             "firmRegistrationNo":  null,
                                                                             "isImmovableStructure":  true,
                                                                             "isSameAsPropertyOwner":  null
                                                                         },
                                                    "institution":  null,
                                                    "auditDetails":  {
                                                                         "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                         "lastModifiedBy":  "local-test-employee",
                                                                         "createdTime":  1790879670758,
                                                                         "lastModifiedTime":  1790879670758
                                                                     }
                                                },
                         "calculation":  null,
                         "auditDetails":  {
                                              "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                              "lastModifiedBy":  "local-test-employee",
                                              "createdTime":  1790879670758,
                                              "lastModifiedTime":  1790879689184
                                          },
                         "fileStoreId":  null
                     }
                 ]
}
```

</details>

<details><summary>Response body (HTTP 200)</summary>

```json
{
    "ResponseInfo":  {
                         "apiId":  "Rainmaker",
                         "ver":  null,
                         "ts":  null,
                         "resMsgId":  "uief87324",
                         "msgId":  "local|en_IN",
                         "status":  "successful"
                     },
    "Licenses":  [
                     {
                         "comment":  null,
                         "id":  "2ca4d4e1-4847-4bcd-8928-06ce9058ce70",
                         "tenantId":  "pg.smc",
                         "businessService":  "TL",
                         "licenseType":  "PERMANENT",
                         "applicationType":  "NEW",
                         "workflowCode":  "TL_NEW",
                         "licenseNumber":  null,
                         "applicationNumber":  "PB-TL-2026-10-02-005879",
                         "oldLicenseNumber":  null,
                         "propertyId":  "PG-PT-1013-008993",
                         "oldPropertyId":  null,
                         "accountId":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                         "tradeName":  "Cahndan",
                         "applicationDate":  1790879670758,
                         "commencementDate":  1790812800000,
                         "issuedDate":  null,
                         "financialYear":  "2026-27",
                         "validFrom":  1775001600000,
                         "validTo":  1806537599000,
                         "action":  "APPROVE",
                         "assignee":  null,
                         "wfDocuments":  null,
                         "status":  "PENDINGPAYMENT",
                         "tradeLicenseDetail":  {
                                                    "id":  "ed7fcb86-52e9-4d7b-bc0c-04abef18f29d",
                                                    "surveyNo":  "1",
                                                    "subOwnerShipCategory":  "INDIVIDUAL.SINGLEOWNER",
                                                    "structureType":  "IMMOVABLE.PUCCA",
                                                    "operationalArea":  1.0,
                                                    "noOfEmployees":  2,
                                                    "adhocExemption":  null,
                                                    "adhocPenalty":  null,
                                                    "adhocExemptionReason":  null,
                                                    "adhocPenaltyReason":  null,
                                                    "owners":  [
                                                                   {
                                                                       "id":  1,
                                                                       "uuid":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                       "userName":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                       "password":  null,
                                                                       "salutation":  null,
                                                                       "name":  "OWNER",
                                                                       "gender":  null,
                                                                       "mobileNumber":  "8908011908",
                                                                       "emailId":  null,
                                                                       "altContactNumber":  null,
                                                                       "pan":  null,
                                                                       "aadhaarNumber":  null,
                                                                       "permanentAddress":  null,
                                                                       "permanentCity":  null,
                                                                       "permanentPinCode":  null,
                                                                       "correspondenceCity":  null,
                                                                       "correspondencePinCode":  null,
                                                                       "correspondenceAddress":  null,
                                                                       "active":  true,
                                                                       "dob":  null,
                                                                       "pwdExpiryDate":  null,
                                                                       "locale":  null,
                                                                       "type":  "CITIZEN",
                                                                       "signature":  null,
                                                                       "accountLocked":  null,
                                                                       "roles":  [
                                                                                     {
                                                                                         "id":  null,
                                                                                         "name":  "CITIZEN",
                                                                                         "code":  "CITIZEN",
                                                                                         "tenantId":  "pg"
                                                                                     }
                                                                                 ],
                                                                       "fatherOrHusbandName":  null,
                                                                       "bloodGroup":  null,
                                                                       "identificationMark":  null,
                                                                       "photo":  null,
                                                                       "createdBy":  "local-test-employee",
                                                                       "createdDate":  1790879693058,
                                                                       "lastModifiedBy":  "local-test-employee",
                                                                       "lastModifiedDate":  1790879693058,
                                                                       "otpReference":  null,
                                                                       "tenantId":  "pg",
                                                                       "isPrimaryOwner":  true,
                                                                       "ownerShipPercentage":  null,
                                                                       "ownerType":  null,
                                                                       "institutionId":  null,
                                                                       "additionalDetails":  {
                                                                                                 "name":  "chndndn",
                                                                                                 "aadhaarNumber":  null,
                                                                                                 "ownerSequence":  0,
                                                                                                 "isprimaryowner":  true,
                                                                                                 "residentialAddress":  "ggggfg"
                                                                                             },
                                                                       "documents":  null,
                                                                       "userActive":  true,
                                                                       "relationship":  "FATHER"
                                                                   }
                                                               ],
                                                    "channel":  "CITIZEN",
                                                    "address":  {
                                                                    "id":  "29ee3a78-2f9c-4d71-9808-673f1e82d8f2",
                                                                    "tenantId":  "pg.smc",
                                                                    "doorNo":  null,
                                                                    "latitude":  null,
                                                                    "longitude":  null,
                                                                    "addressId":  null,
                                                                    "addressNumber":  null,
                                                                    "type":  null,
                                                                    "addressLine1":  "gh",
                                                                    "addressLine2":  null,
                                                                    "landmark":  null,
                                                                    "city":  null,
                                                                    "pincode":  "876655",
                                                                    "detail":  null,
                                                                    "buildingName":  null,
                                                                    "street":  null,
                                                                    "locality":  {
                                                                                     "code":  "JLC476",
                                                                                     "name":  "Main Road Abadpura",
                                                                                     "label":  "Locality",
                                                                                     "latitude":  null,
                                                                                     "longitude":  null,
                                                                                     "children":  [

                                                                                                  ],
                                                                                     "materializedPath":  null
                                                                                 }
                                                                },
                                                    "tradeUnits":  [
                                                                       {
                                                                           "id":  "523a8023-02f0-4b80-90d1-b36f902ce98c",
                                                                           "tenantId":  "pg.smc",
                                                                           "active":  true,
                                                                           "tradeType":  "GOODS.MANUFACTURE.SMC-01",
                                                                           "uom":  null,
                                                                           "uomValue":  null,
                                                                           "auditDetails":  null
                                                                       }
                                                                   ],
                                                    "accessories":  null,
                                                    "applicationDocuments":  [
                                                                                 {
                                                                                     "id":  "911173e4-35a1-4f00-bb55-04623faec1da",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "SHOPACTLICENSE",
                                                                                     "fileStoreId":  "local-test-shopactlicense",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "1d03afb8-3264-44c5-b0f1-d6eb4e346c10",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "LANDOWNERCONSENT",
                                                                                     "fileStoreId":  "local-test-landownerconsent",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "1d9e819b-2674-4203-b055-624bd9bd06a2",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "PROPERTYTAXRECEIPT",
                                                                                     "fileStoreId":  "local-test-propertytaxreceipt",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "bebb2fb1-5ebd-4c0e-bb5d-f38838ffb4db",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "AADHAARCARD",
                                                                                     "fileStoreId":  "local-test-aadhaarcard",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "572bbe0a-8176-4772-b57e-6084e6586a1c",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "PROPERTYEXTRACT",
                                                                                     "fileStoreId":  "local-test-propertyextract",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "da52048e-a740-47a5-a981-f35088dc3b13",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "SEVENTWELVEEXTRACT",
                                                                                     "fileStoreId":  "local-test-seventwelveextract",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 }
                                                                             ],
                                                    "verificationDocuments":  null,
                                                    "additionalDetail":  {
                                                                             "ctsNo":  "3",
                                                                             "gatNo":  "2",
                                                                             "plotNo":  "4",
                                                                             "surveyNo":  "1",
                                                                             "waterDues":  0,
                                                                             "propertyId":  "",
                                                                             "tradeGstNo":  null,
                                                                             "legalStatus":  "OWNED",
                                                                             "noOfMachines":  2,
                                                                             "landownerName":  "asit",
                                                                             "ownershipType":  null,
                                                                             "propertyTaxNo":  null,
                                                                             "totalMachines":  2,
                                                                             "propertyTaxDues":  0,
                                                                             "firmRegistrationNo":  null,
                                                                             "isImmovableStructure":  true,
                                                                             "isSameAsPropertyOwner":  null
                                                                         },
                                                    "institution":  null,
                                                    "auditDetails":  {
                                                                         "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                         "lastModifiedBy":  "local-test-employee",
                                                                         "createdTime":  1790879670758,
                                                                         "lastModifiedTime":  1790879670758
                                                                     }
                                                },
                         "calculation":  {
                                             "applicationNumber":  null,
                                             "tradeLicense":  null,
                                             "tenantId":  "pg.smc",
                                             "taxHeadEstimates":  [
                                                                      {
                                                                          "taxHeadCode":  "TL_TAX",
                                                                          "estimateAmount":  500.0,
                                                                          "category":  "TAX"
                                                                      }
                                                                  ],
                                             "tradeTypeBillingIds":  {
                                                                         "id":  "6d433791-1f0c-450d-9544-89655e598a12",
                                                                         "fee":  500.0,
                                                                         "billingSlabIds":  [
                                                                                                "45fbed61-eda8-a9f3-482f-8df916722e6d|0|523a8023-02f0-4b80-90d1-b36f902ce98c"
                                                                                            ]
                                                                     },
                                             "accessoryBillingIds":  null
                                         },
                         "auditDetails":  {
                                              "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                              "lastModifiedBy":  "local-test-employee",
                                              "createdTime":  1790879670758,
                                              "lastModifiedTime":  1790879692959
                                          },
                         "fileStoreId":  null
                     }
                 ],
    "Count":  0,
    "applicationsIssued":  0,
    "applicationsRenewed":  0,
    "applicationValidity":  0
}
```

</details>

## 8. PAY (payment event)

- **Sent by:** collection-services (simulated)
- **Call:** `KAFKA topic egov.collection.payment-create`
- Not an HTTP call. PAY through _update is refused. tl-services consumes this event, moves the application to APPROVED and generates the license number. On a real environment collection-services publishes a full payment; this is the minimum tl-services needs.

Calls tl-services makes to other services while handling it, in order:

1. `POST http://localhost:8086/egov-location/location/v11/boundarys/_search?tenantId=pg.smc&hierarchyTypeCode=REVENUE&boundaryType=Locality&codes=JLC476`
2. `POST http://localhost:8091/user/_search`
3. `POST http://localhost:8280/egov-workflow-v2/egov-wf/businessservice/_search?tenantId=pg.smc&businessServices=TL_NEW`
4. `POST http://localhost:8280/egov-workflow-v2/egov-wf/process/_transition`
5. `POST http://localhost:8088/egov-idgen/id/_generate`
6. `POST http://localhost:8087/property-services/property/_search?tenantId=pg.smc&propertyIds=`
7. `POST http://localhost:8086/egov-location/location/v11/boundarys/_search?tenantId=pg.smc&hierarchyTypeCode=REVENUE&boundaryType=Locality&codes=JLC476`
8. `POST http://localhost:8091/user/_search`

<details><summary>Request body</summary>

```json
{
    "RequestInfo":  {
                        "apiId":  "Rainmaker",
                        "authToken":  "not-checked-locally",
                        "msgId":  "local|en_IN",
                        "userInfo":  {
                                         "id":  17253,
                                         "uuid":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                         "userName":  "8908011908",
                                         "name":  "OWNER",
                                         "mobileNumber":  "8908011908",
                                         "type":  "CITIZEN",
                                         "tenantId":  "pg",
                                         "roles":  [
                                                       {
                                                           "code":  "CITIZEN",
                                                           "name":  "CITIZEN",
                                                           "tenantId":  "pg"
                                                       }
                                                   ]
                                     }
                    },
    "Payment":  {
                    "tenantId":  "pg.smc",
                    "paymentDetails":  [
                                           {
                                               "businessService":  "TL",
                                               "tenantId":  "pg.smc",
                                               "bill":  {
                                                            "consumerCode":  "PB-TL-2026-10-02-005879",
                                                            "tenantId":  "pg.smc"
                                                        }
                                           }
                                       ]
                }
}
```

</details>

## 9. SEARCH (approved license)

- **Sent by:** Citizen
- **Call:** `POST http://localhost:8079/tl-services/v1/_search?tenantId=pg.smc&applicationNumber=PB-TL-2026-10-02-005879`
- Shows status APPROVED with licenseNumber and issuedDate.

<details><summary>Request body</summary>

```json
{
    "RequestInfo":  {
                        "apiId":  "Rainmaker",
                        "authToken":  "not-checked-locally",
                        "msgId":  "local|en_IN",
                        "userInfo":  {
                                         "id":  17253,
                                         "uuid":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                         "userName":  "8908011908",
                                         "name":  "OWNER",
                                         "mobileNumber":  "8908011908",
                                         "type":  "CITIZEN",
                                         "tenantId":  "pg",
                                         "roles":  [
                                                       {
                                                           "code":  "CITIZEN",
                                                           "name":  "CITIZEN",
                                                           "tenantId":  "pg"
                                                       }
                                                   ]
                                     }
                    }
}
```

</details>

<details><summary>Response body (HTTP 200)</summary>

```json
{
    "ResponseInfo":  {
                         "apiId":  "Rainmaker",
                         "ver":  null,
                         "ts":  null,
                         "resMsgId":  "uief87324",
                         "msgId":  "local|en_IN",
                         "status":  "successful"
                     },
    "Licenses":  [
                     {
                         "comment":  null,
                         "id":  "2ca4d4e1-4847-4bcd-8928-06ce9058ce70",
                         "tenantId":  "pg.smc",
                         "businessService":  "TL",
                         "licenseType":  "PERMANENT",
                         "applicationType":  "NEW",
                         "workflowCode":  "TL_NEW",
                         "licenseNumber":  "PB-TL-2026-10-02-001289",
                         "applicationNumber":  "PB-TL-2026-10-02-005879",
                         "oldLicenseNumber":  null,
                         "propertyId":  "PG-PT-1013-008993",
                         "oldPropertyId":  null,
                         "accountId":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                         "tradeName":  "Cahndan",
                         "applicationDate":  1790879670758,
                         "commencementDate":  1790812800000,
                         "issuedDate":  1790879698478,
                         "financialYear":  "2026-27",
                         "validFrom":  1775001600000,
                         "validTo":  1806537599000,
                         "action":  "PAY",
                         "assignee":  null,
                         "wfDocuments":  null,
                         "status":  "APPROVED",
                         "tradeLicenseDetail":  {
                                                    "id":  "ed7fcb86-52e9-4d7b-bc0c-04abef18f29d",
                                                    "surveyNo":  "1",
                                                    "subOwnerShipCategory":  "INDIVIDUAL.SINGLEOWNER",
                                                    "structureType":  "IMMOVABLE.PUCCA",
                                                    "operationalArea":  1.0,
                                                    "noOfEmployees":  2,
                                                    "adhocExemption":  null,
                                                    "adhocPenalty":  null,
                                                    "adhocExemptionReason":  null,
                                                    "adhocPenaltyReason":  null,
                                                    "owners":  [
                                                                   {
                                                                       "id":  17253,
                                                                       "uuid":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                       "userName":  "8908011908",
                                                                       "password":  null,
                                                                       "salutation":  null,
                                                                       "name":  "OWNER",
                                                                       "gender":  null,
                                                                       "mobileNumber":  "8908011908",
                                                                       "emailId":  null,
                                                                       "altContactNumber":  null,
                                                                       "pan":  null,
                                                                       "aadhaarNumber":  null,
                                                                       "permanentAddress":  null,
                                                                       "permanentCity":  null,
                                                                       "permanentPinCode":  null,
                                                                       "correspondenceCity":  null,
                                                                       "correspondencePinCode":  null,
                                                                       "correspondenceAddress":  null,
                                                                       "active":  true,
                                                                       "dob":  null,
                                                                       "pwdExpiryDate":  null,
                                                                       "locale":  null,
                                                                       "type":  "CITIZEN",
                                                                       "signature":  null,
                                                                       "accountLocked":  null,
                                                                       "roles":  [
                                                                                     {
                                                                                         "id":  null,
                                                                                         "name":  "CITIZEN",
                                                                                         "code":  "CITIZEN",
                                                                                         "tenantId":  "pg"
                                                                                     }
                                                                                 ],
                                                                       "fatherOrHusbandName":  null,
                                                                       "bloodGroup":  null,
                                                                       "identificationMark":  null,
                                                                       "photo":  null,
                                                                       "createdBy":  null,
                                                                       "createdDate":  1790899498000,
                                                                       "lastModifiedBy":  null,
                                                                       "lastModifiedDate":  1790899498000,
                                                                       "otpReference":  null,
                                                                       "tenantId":  "pg",
                                                                       "isPrimaryOwner":  true,
                                                                       "ownerShipPercentage":  null,
                                                                       "ownerType":  null,
                                                                       "institutionId":  null,
                                                                       "additionalDetails":  {
                                                                                                 "name":  "chndndn",
                                                                                                 "aadhaarNumber":  null,
                                                                                                 "ownerSequence":  0,
                                                                                                 "isprimaryowner":  true,
                                                                                                 "residentialAddress":  "ggggfg"
                                                                                             },
                                                                       "documents":  null,
                                                                       "userActive":  true,
                                                                       "relationship":  "FATHER"
                                                                   }
                                                               ],
                                                    "channel":  "CITIZEN",
                                                    "address":  {
                                                                    "id":  "29ee3a78-2f9c-4d71-9808-673f1e82d8f2",
                                                                    "tenantId":  "pg.smc",
                                                                    "doorNo":  null,
                                                                    "latitude":  null,
                                                                    "longitude":  null,
                                                                    "addressId":  null,
                                                                    "addressNumber":  null,
                                                                    "type":  null,
                                                                    "addressLine1":  null,
                                                                    "addressLine2":  null,
                                                                    "landmark":  null,
                                                                    "city":  null,
                                                                    "pincode":  "876655",
                                                                    "detail":  null,
                                                                    "buildingName":  null,
                                                                    "street":  null,
                                                                    "locality":  {
                                                                                     "code":  "JLC476",
                                                                                     "name":  "Main Road Abadpura",
                                                                                     "label":  "Locality",
                                                                                     "latitude":  null,
                                                                                     "longitude":  null,
                                                                                     "children":  [

                                                                                                  ],
                                                                                     "materializedPath":  null
                                                                                 }
                                                                },
                                                    "tradeUnits":  [
                                                                       {
                                                                           "id":  "523a8023-02f0-4b80-90d1-b36f902ce98c",
                                                                           "tenantId":  "pg.smc",
                                                                           "active":  true,
                                                                           "tradeType":  "GOODS.MANUFACTURE.SMC-01",
                                                                           "uom":  null,
                                                                           "uomValue":  null,
                                                                           "auditDetails":  null
                                                                       }
                                                                   ],
                                                    "accessories":  null,
                                                    "applicationDocuments":  [
                                                                                 {
                                                                                     "id":  "911173e4-35a1-4f00-bb55-04623faec1da",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "SHOPACTLICENSE",
                                                                                     "fileStoreId":  "local-test-shopactlicense",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "1d03afb8-3264-44c5-b0f1-d6eb4e346c10",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "LANDOWNERCONSENT",
                                                                                     "fileStoreId":  "local-test-landownerconsent",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "1d9e819b-2674-4203-b055-624bd9bd06a2",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "PROPERTYTAXRECEIPT",
                                                                                     "fileStoreId":  "local-test-propertytaxreceipt",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "bebb2fb1-5ebd-4c0e-bb5d-f38838ffb4db",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "AADHAARCARD",
                                                                                     "fileStoreId":  "local-test-aadhaarcard",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "572bbe0a-8176-4772-b57e-6084e6586a1c",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "PROPERTYEXTRACT",
                                                                                     "fileStoreId":  "local-test-propertyextract",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 },
                                                                                 {
                                                                                     "id":  "da52048e-a740-47a5-a981-f35088dc3b13",
                                                                                     "active":  true,
                                                                                     "tenantId":  "pg.smc",
                                                                                     "documentType":  "SEVENTWELVEEXTRACT",
                                                                                     "fileStoreId":  "local-test-seventwelveextract",
                                                                                     "documentUid":  null,
                                                                                     "auditDetails":  null
                                                                                 }
                                                                             ],
                                                    "verificationDocuments":  null,
                                                    "additionalDetail":  {
                                                                             "ctsNo":  "3",
                                                                             "gatNo":  "2",
                                                                             "plotNo":  "4",
                                                                             "surveyNo":  "1",
                                                                             "waterDues":  0,
                                                                             "propertyId":  "",
                                                                             "tradeGstNo":  null,
                                                                             "legalStatus":  "OWNED",
                                                                             "noOfMachines":  2,
                                                                             "landownerName":  "asit",
                                                                             "ownershipType":  null,
                                                                             "propertyTaxNo":  null,
                                                                             "totalMachines":  2,
                                                                             "propertyTaxDues":  0,
                                                                             "firmRegistrationNo":  null,
                                                                             "isImmovableStructure":  true,
                                                                             "isSameAsPropertyOwner":  null
                                                                         },
                                                    "institution":  null,
                                                    "auditDetails":  {
                                                                         "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                                                         "lastModifiedBy":  "local-test-employee",
                                                                         "createdTime":  1790879670758,
                                                                         "lastModifiedTime":  1790879670758
                                                                     }
                                                },
                         "calculation":  null,
                         "auditDetails":  {
                                              "createdBy":  "57a3e9c0-fc9e-480c-bf12-2d6a964d134c",
                                              "lastModifiedBy":  "local-test-employee",
                                              "createdTime":  1790879670758,
                                              "lastModifiedTime":  1790879692959
                                          },
                         "fileStoreId":  null
                     }
                 ],
    "Count":  1,
    "applicationsIssued":  6,
    "applicationsRenewed":  0,
    "applicationValidity":  1
}
```

</details>

