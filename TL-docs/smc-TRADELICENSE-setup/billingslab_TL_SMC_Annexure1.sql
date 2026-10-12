-- Sangamner Municipal Council: License Charge Master (Annexure 1), tl-calculator billing slabs
-- Tenant pg.smc, applicationType NEW, rates effective from 2026. Safe to re-run.
-- PERMANENT (TL_NEW): Annexure 1 rate per business type. TEMPORARY (TTL_NEW): flat Rs. 500 for all business types.

BEGIN;

-- PERMANENT
-- Sr. 1 Printing press: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '45fbed61-eda8-a9f3-482f-8df916722e6d', 'PERMANENT', 'ALL', 'GOODS.MANUFACTURE.SMC-01', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.MANUFACTURE.SMC-01' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 2 Flour mill / Grinding mill: Rs. 100
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '1765f873-e7cf-2870-4347-68205eb2e123', 'PERMANENT', 'ALL', 'GOODS.MANUFACTURE.SMC-02', NULL, 'FLAT', NULL, NULL, NULL, 100, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.MANUFACTURE.SMC-02' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 3 Fabrication / Welding: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'c4f45942-d92c-7566-50d3-6d689c84768d', 'PERMANENT', 'ALL', 'GOODS.MANUFACTURE.SMC-03', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.MANUFACTURE.SMC-03' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 4 Lathe machine: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'a5db71f3-e04b-c5dc-677e-6cf0092338cc', 'PERMANENT', 'ALL', 'GOODS.MANUFACTURE.SMC-04', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.MANUFACTURE.SMC-04' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 5 Ice candy manufacturing: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '27cb0f90-cc72-d70e-41a5-9326d1e6c46f', 'PERMANENT', 'ALL', 'GOODS.MANUFACTURE.SMC-05', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.MANUFACTURE.SMC-05' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 6 Soda / lemon drinks: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '930df68b-3e4e-2922-8c1a-d758008617ca', 'PERMANENT', 'ALL', 'GOODS.MANUFACTURE.SMC-06', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.MANUFACTURE.SMC-06' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 7 Pepsi (ice pop) manufacturing: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'b7026019-f80e-e345-fa1b-df065c3d2f98', 'PERMANENT', 'ALL', 'GOODS.MANUFACTURE.SMC-07', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.MANUFACTURE.SMC-07' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 8 Floor tile / stone cutting: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '7649ff9e-9226-e579-8a45-67c021bdf50a', 'PERMANENT', 'ALL', 'GOODS.MANUFACTURE.SMC-08', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.MANUFACTURE.SMC-08' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 9 Tyre vulcanizing (SERVICES.GENERAL.SMC-09): fee not legible in Annexure 1, confirm with SMC and add the slab
-- Sr. 10 Bidi factory: Rs. 100 (verify)
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'd7c7b18f-94a4-29b3-545e-fe52cfb39f5f', 'PERMANENT', 'ALL', 'GOODS.MANUFACTURE.SMC-10', NULL, 'FLAT', NULL, NULL, NULL, 100, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.MANUFACTURE.SMC-10' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 11 Rava (semolina) mill: Rs. 5000 (verify)
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '3d923374-a9fa-0290-4e12-e1a90d88a0e9', 'PERMANENT', 'ALL', 'GOODS.MANUFACTURE.SMC-11', NULL, 'FLAT', NULL, NULL, NULL, 5000, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.MANUFACTURE.SMC-11' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 12 Cotton carding / ginning: Rs. 2500 (verify)
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'ef839325-a729-cf6b-59e9-29227e5395a4', 'PERMANENT', 'ALL', 'GOODS.MANUFACTURE.SMC-12', NULL, 'FLAT', NULL, NULL, NULL, 2500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.MANUFACTURE.SMC-12' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 13 Motor body builder: Rs. 300
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '0b09e1b7-e51b-1cd0-f1f9-aabcebece733', 'PERMANENT', 'ALL', 'GOODS.MANUFACTURE.SMC-13', NULL, 'FLAT', NULL, NULL, NULL, 300, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.MANUFACTURE.SMC-13' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 14 Salon – Non-AC: Rs. 100
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '11842297-7e2f-2351-6bd7-29a8b846b9e2', 'PERMANENT', 'ALL', 'SERVICES.GENERAL.SMC-14', NULL, 'FLAT', NULL, NULL, NULL, 100, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'SERVICES.GENERAL.SMC-14' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 15 Salon – AC: Rs. 100
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '13ba6f38-7bc8-48d1-98b8-0c553638447c', 'PERMANENT', 'ALL', 'SERVICES.GENERAL.SMC-15', NULL, 'FLAT', NULL, NULL, NULL, 100, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'SERVICES.GENERAL.SMC-15' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 16 Spa with beauty parlour: Rs. 100
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '5b769cc5-d174-a4c4-819c-209f6a275f67', 'PERMANENT', 'ALL', 'SERVICES.GENERAL.SMC-16', NULL, 'FLAT', NULL, NULL, NULL, 100, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'SERVICES.GENERAL.SMC-16' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 17 Beauty parlour: Rs. 100
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'eae17575-424b-64ad-5df4-e929ce4ea21f', 'PERMANENT', 'ALL', 'SERVICES.GENERAL.SMC-17', NULL, 'FLAT', NULL, NULL, NULL, 100, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'SERVICES.GENERAL.SMC-17' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 18 Kerosene sale: Rs. 100
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '66b2dcb4-4eaf-bd9f-a0f7-15f7f64f43f5', 'PERMANENT', 'ALL', 'GOODS.RETAIL.SMC-18', NULL, 'FLAT', NULL, NULL, NULL, 100, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.RETAIL.SMC-18' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 19 Bakery: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '1bdf0fcd-ed8b-fc62-f06c-c614c60ce5f9', 'PERMANENT', 'ALL', 'GOODS.RETAIL.SMC-19', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.RETAIL.SMC-19' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 20 Mattress (gadi) factory: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '688f3785-f700-e5dc-044c-2158683fc8f5', 'PERMANENT', 'ALL', 'GOODS.MANUFACTURE.SMC-20', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.MANUFACTURE.SMC-20' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 21 Leather sale: Rs. 300
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'b6baa629-c0c2-91dd-fe16-afd27ffe8dcf', 'PERMANENT', 'ALL', 'GOODS.RETAIL.SMC-21', NULL, 'FLAT', NULL, NULL, NULL, 300, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.RETAIL.SMC-21' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 22 Meat sale: Rs. 100
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '47704b8d-50da-534f-e09b-c63117546ea2', 'PERMANENT', 'ALL', 'GOODS.RETAIL.SMC-22', NULL, 'FLAT', NULL, NULL, NULL, 100, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.RETAIL.SMC-22' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 23 Lime (chuna) making: Rs. 100
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '040baaf5-05ea-912f-a30a-06440c4f241d', 'PERMANENT', 'ALL', 'GOODS.MANUFACTURE.SMC-23', NULL, 'FLAT', NULL, NULL, NULL, 100, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.MANUFACTURE.SMC-23' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 24 Battery charging & repairing: Rs. 1000
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'c2a96594-21b9-da2e-6bf7-c5d30ab46154', 'PERMANENT', 'ALL', 'SERVICES.GENERAL.SMC-24', NULL, 'FLAT', NULL, NULL, NULL, 1000, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'SERVICES.GENERAL.SMC-24' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 25 Wood charcoal: Rs. 100
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '8cc0c39d-8dc8-2ca5-06b2-03e983b912f7', 'PERMANENT', 'ALL', 'GOODS.MANUFACTURE.SMC-25', NULL, 'FLAT', NULL, NULL, NULL, 100, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.MANUFACTURE.SMC-25' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 26 Gas sale: Rs. 400
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '4c8e4568-7d58-8554-4b4e-67cc1d264316', 'PERMANENT', 'ALL', 'GOODS.RETAIL.SMC-26', NULL, 'FLAT', NULL, NULL, NULL, 400, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.RETAIL.SMC-26' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 27 Mess (khanaval) / Canteen: Rs. 2000
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '7efe8093-5d24-ed26-66ec-5832ffd00b6b', 'PERMANENT', 'ALL', 'SERVICES.HOSPITALITY.SMC-27', NULL, 'FLAT', NULL, NULL, NULL, 2000, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'SERVICES.HOSPITALITY.SMC-27' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 28 Farsan (snacks) sale, sweet shop: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '4e345ab3-6b1b-64bd-27a0-56ad5eb8d4b9', 'PERMANENT', 'ALL', 'GOODS.RETAIL.SMC-28', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.RETAIL.SMC-28' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 29 Restaurant – small (500–1,000 sq. ft.): Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '2de5b8ae-2383-60ea-0dd0-d327e5789038', 'PERMANENT', 'ALL', 'SERVICES.HOSPITALITY.SMC-29', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'SERVICES.HOSPITALITY.SMC-29' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 30 Restaurant – large (> 1,000 sq. ft.): Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'c416577f-95b1-e13c-ec47-c09a61b75bc0', 'PERMANENT', 'ALL', 'SERVICES.HOSPITALITY.SMC-30', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'SERVICES.HOSPITALITY.SMC-30' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 31 Restaurant & bar: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'abd0c5af-ffdc-e52e-b05f-b549e2ae0cb2', 'PERMANENT', 'ALL', 'SERVICES.HOSPITALITY.SMC-31', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'SERVICES.HOSPITALITY.SMC-31' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 32 Restaurant with lodging: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '704b8c27-233a-dab7-24ef-aa0b6815a5aa', 'PERMANENT', 'ALL', 'SERVICES.HOSPITALITY.SMC-32', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'SERVICES.HOSPITALITY.SMC-32' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 33 Lodging: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'e284628e-25a6-631e-70fd-85aa1fce5ec7', 'PERMANENT', 'ALL', 'SERVICES.HOSPITALITY.SMC-33', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'SERVICES.HOSPITALITY.SMC-33' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 34 Laundry: Rs. 75
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'afa4916a-f790-6846-7a12-f65d1497f6a8', 'PERMANENT', 'ALL', 'SERVICES.GENERAL.SMC-34', NULL, 'FLAT', NULL, NULL, NULL, 75, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'SERVICES.GENERAL.SMC-34' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 35 Laundry with dry cleaning: Rs. 75
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '20a165f2-3d63-1d62-4eb7-5bb91e1070c6', 'PERMANENT', 'ALL', 'SERVICES.GENERAL.SMC-35', NULL, 'FLAT', NULL, NULL, NULL, 75, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'SERVICES.GENERAL.SMC-35' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 36 Lime processing: Rs. 1000
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'b547c6fe-0541-4a4c-cca0-58758e7fe7c6', 'PERMANENT', 'ALL', 'GOODS.MANUFACTURE.SMC-36', NULL, 'FLAT', NULL, NULL, NULL, 1000, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.MANUFACTURE.SMC-36' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 37 Vehicle service station: Rs. 1000
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'a2bc5196-bfcb-adba-311f-afadb4de2cc0', 'PERMANENT', 'ALL', 'SERVICES.GENERAL.SMC-37', NULL, 'FLAT', NULL, NULL, NULL, 1000, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'SERVICES.GENERAL.SMC-37' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 38 Spice production / chilli grinding: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'ed7c91ed-b9cb-6ad9-0c24-36aa825cd867', 'PERMANENT', 'ALL', 'GOODS.MANUFACTURE.SMC-38', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.MANUFACTURE.SMC-38' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 39 Electroplating / coating: Rs. 75
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '4d15c90b-841d-160a-48b3-6e4f455aa9b0', 'PERMANENT', 'ALL', 'GOODS.MANUFACTURE.SMC-39', NULL, 'FLAT', NULL, NULL, NULL, 75, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.MANUFACTURE.SMC-39' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 40 Furniture: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '638a4329-9585-8949-a12f-aedd62dc10e7', 'PERMANENT', 'ALL', 'GOODS.MANUFACTURE.SMC-40', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.MANUFACTURE.SMC-40' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 41 Timber / storage yard (Vakhar): Rs. 1000
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '41ff35a6-4d58-9c52-98f0-774296b09137', 'PERMANENT', 'ALL', 'GOODS.WHOLESALE.SMC-41', NULL, 'FLAT', NULL, NULL, NULL, 1000, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.WHOLESALE.SMC-41' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 42 Fireworks sale: Rs. 1000
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '9a334d5c-3c82-c684-7c9d-43f0d9729a5b', 'PERMANENT', 'ALL', 'GOODS.RETAIL.SMC-42', NULL, 'FLAT', NULL, NULL, NULL, 1000, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.RETAIL.SMC-42' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 43 Petrol pump: Rs. 2500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'a8082cd0-578f-4704-1f66-3be0867b7419', 'PERMANENT', 'ALL', 'GOODS.RETAIL.SMC-43', NULL, 'FLAT', NULL, NULL, NULL, 2500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.RETAIL.SMC-43' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 44 Puffed rice (murmure) making: Rs. 50
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '3cd1f964-272a-e78e-50bb-87f67d6b37e9', 'PERMANENT', 'ALL', 'GOODS.MANUFACTURE.SMC-44', NULL, 'FLAT', NULL, NULL, NULL, 50, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.MANUFACTURE.SMC-44' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 45 Lodging & bar: Rs. 1000
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '390daf4a-5cd8-ea78-2380-8f2d26d56d85', 'PERMANENT', 'ALL', 'SERVICES.HOSPITALITY.SMC-45', NULL, 'FLAT', NULL, NULL, NULL, 1000, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'SERVICES.HOSPITALITY.SMC-45' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 46 Colour photo lab: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '5a624f0f-cbb3-a310-8813-5e80e98285f5', 'PERMANENT', 'ALL', 'SERVICES.GENERAL.SMC-46', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'SERVICES.GENERAL.SMC-46' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 47 Wheel alignment: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '0304fa88-5b99-9a50-4692-bcb51ca0aa5c', 'PERMANENT', 'ALL', 'SERVICES.GENERAL.SMC-47', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'SERVICES.GENERAL.SMC-47' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 48 Hotel – large (> 1,000 sq. ft.): Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'c20f7f3e-d342-6ba9-d39c-a60dea5cb6b3', 'PERMANENT', 'ALL', 'SERVICES.HOSPITALITY.SMC-48', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'SERVICES.HOSPITALITY.SMC-48' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 49 Hotel – small (< 1,000 sq. ft.): Rs. 0
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'e1d301c6-c834-6077-d114-15fc4a5f3e8c', 'PERMANENT', 'ALL', 'SERVICES.HOSPITALITY.SMC-49', NULL, 'FLAT', NULL, NULL, NULL, 0, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'SERVICES.HOSPITALITY.SMC-49' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 50 Hotel & bar: Rs. 1000
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'f5bc95b6-5868-e5b8-1d1a-e7722520040c', 'PERMANENT', 'ALL', 'SERVICES.HOSPITALITY.SMC-50', NULL, 'FLAT', NULL, NULL, NULL, 1000, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'SERVICES.HOSPITALITY.SMC-50' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 51 Hotel & lodging: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '9601d819-ab07-0e21-fd3f-65901afd7753', 'PERMANENT', 'ALL', 'SERVICES.HOSPITALITY.SMC-51', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'SERVICES.HOSPITALITY.SMC-51' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 52 Country liquor shop: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '4b754524-ddc1-1e3e-0ac5-baa9f540a9b6', 'PERMANENT', 'ALL', 'GOODS.RETAIL.SMC-52', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.RETAIL.SMC-52' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 53 Wine shop: Rs. 1000
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '3f5c69c7-03d1-859f-d6de-a9d75bf1aefa', 'PERMANENT', 'ALL', 'GOODS.RETAIL.SMC-53', NULL, 'FLAT', NULL, NULL, NULL, 1000, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' AND tradetype = 'GOODS.RETAIL.SMC-53' AND applicationtype = 'NEW' AND accessorycategory IS NULL);

-- TEMPORARY
-- Sr. 1 Printing press: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '1aa3eee6-0a90-c7a7-5859-8ea07f344f2b', 'TEMPORARY', 'ALL', 'GOODS.MANUFACTURE.SMC-01', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MANUFACTURE.SMC-01' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 2 Flour mill / Grinding mill: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '83ba3e30-bf4b-d928-7c63-390198e5617e', 'TEMPORARY', 'ALL', 'GOODS.MANUFACTURE.SMC-02', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MANUFACTURE.SMC-02' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 3 Fabrication / Welding: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '1a4a1633-3b23-5d7a-7dfe-976c85d65632', 'TEMPORARY', 'ALL', 'GOODS.MANUFACTURE.SMC-03', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MANUFACTURE.SMC-03' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 4 Lathe machine: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '18999ea1-97ba-e475-2194-33ae2bd5e569', 'TEMPORARY', 'ALL', 'GOODS.MANUFACTURE.SMC-04', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MANUFACTURE.SMC-04' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 5 Ice candy manufacturing: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '77c85666-5248-ecdc-bbea-77bc7f074607', 'TEMPORARY', 'ALL', 'GOODS.MANUFACTURE.SMC-05', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MANUFACTURE.SMC-05' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 6 Soda / lemon drinks: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '1eae8f91-a809-8205-1120-5a43073caeb7', 'TEMPORARY', 'ALL', 'GOODS.MANUFACTURE.SMC-06', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MANUFACTURE.SMC-06' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 7 Pepsi (ice pop) manufacturing: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'b5f89091-0c83-2186-2d91-6cea03bd9b0e', 'TEMPORARY', 'ALL', 'GOODS.MANUFACTURE.SMC-07', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MANUFACTURE.SMC-07' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 8 Floor tile / stone cutting: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'dc84bab7-c5e1-b37e-1b4b-eedf6d0393fa', 'TEMPORARY', 'ALL', 'GOODS.MANUFACTURE.SMC-08', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MANUFACTURE.SMC-08' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 9 Tyre vulcanizing: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '5de9ba09-0732-cb80-3e39-1a1f71274389', 'TEMPORARY', 'ALL', 'SERVICES.GENERAL.SMC-09', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'SERVICES.GENERAL.SMC-09' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 10 Bidi factory: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '1a5d5699-974a-3268-6e2b-01aadfdbb439', 'TEMPORARY', 'ALL', 'GOODS.MANUFACTURE.SMC-10', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MANUFACTURE.SMC-10' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 11 Rava (semolina) mill: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'c1765063-288a-d4e6-0537-416545f2fb27', 'TEMPORARY', 'ALL', 'GOODS.MANUFACTURE.SMC-11', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MANUFACTURE.SMC-11' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 12 Cotton carding / ginning: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '536410f5-6350-978e-6def-8022462bd940', 'TEMPORARY', 'ALL', 'GOODS.MANUFACTURE.SMC-12', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MANUFACTURE.SMC-12' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 13 Motor body builder: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '49bc51f2-7cba-f961-ec3b-e15df7d1edd2', 'TEMPORARY', 'ALL', 'GOODS.MANUFACTURE.SMC-13', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MANUFACTURE.SMC-13' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 14 Salon – Non-AC: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '2a8b089e-bbf0-7da1-f17b-82a7fe193086', 'TEMPORARY', 'ALL', 'SERVICES.GENERAL.SMC-14', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'SERVICES.GENERAL.SMC-14' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 15 Salon – AC: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'b2694603-a8aa-fe18-1d25-1eaf0eff18ff', 'TEMPORARY', 'ALL', 'SERVICES.GENERAL.SMC-15', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'SERVICES.GENERAL.SMC-15' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 16 Spa with beauty parlour: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '3949071c-5477-43b3-eb58-a0f94fabe485', 'TEMPORARY', 'ALL', 'SERVICES.GENERAL.SMC-16', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'SERVICES.GENERAL.SMC-16' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 17 Beauty parlour: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '3af9b987-0235-553e-b190-a25c842fb968', 'TEMPORARY', 'ALL', 'SERVICES.GENERAL.SMC-17', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'SERVICES.GENERAL.SMC-17' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 18 Kerosene sale: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '5a39e65d-df9d-a14e-2fce-54dd3c4bc61c', 'TEMPORARY', 'ALL', 'GOODS.RETAIL.SMC-18', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.RETAIL.SMC-18' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 19 Bakery: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'c6bc8b4c-70bf-06d9-cc6f-0d86804edf89', 'TEMPORARY', 'ALL', 'GOODS.RETAIL.SMC-19', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.RETAIL.SMC-19' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 20 Mattress (gadi) factory: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '85da6b1e-a54f-2ca6-fde5-cfc7638a0660', 'TEMPORARY', 'ALL', 'GOODS.MANUFACTURE.SMC-20', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MANUFACTURE.SMC-20' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 21 Leather sale: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'abc10e32-4c0f-85bf-1f76-6b85af7564db', 'TEMPORARY', 'ALL', 'GOODS.RETAIL.SMC-21', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.RETAIL.SMC-21' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 22 Meat sale: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'a3679cf6-fd63-87d5-2319-ee52ac2042f6', 'TEMPORARY', 'ALL', 'GOODS.RETAIL.SMC-22', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.RETAIL.SMC-22' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 23 Lime (chuna) making: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '28671439-1b13-c68f-806d-9412385ca89e', 'TEMPORARY', 'ALL', 'GOODS.MANUFACTURE.SMC-23', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MANUFACTURE.SMC-23' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 24 Battery charging & repairing: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'dd6db8f9-410c-d0ba-4374-bfbc00d06f3e', 'TEMPORARY', 'ALL', 'SERVICES.GENERAL.SMC-24', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'SERVICES.GENERAL.SMC-24' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 25 Wood charcoal: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '401414df-4fb6-1fbd-c4d8-880b95bcff6e', 'TEMPORARY', 'ALL', 'GOODS.MANUFACTURE.SMC-25', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MANUFACTURE.SMC-25' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 26 Gas sale: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '8164f042-1508-ae2a-a54f-01fd8e2e196c', 'TEMPORARY', 'ALL', 'GOODS.RETAIL.SMC-26', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.RETAIL.SMC-26' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 27 Mess (khanaval) / Canteen: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '28e49282-c86f-34f6-449a-89f0edf34374', 'TEMPORARY', 'ALL', 'SERVICES.HOSPITALITY.SMC-27', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'SERVICES.HOSPITALITY.SMC-27' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 28 Farsan (snacks) sale, sweet shop: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '80f9b111-545d-abb0-1c2c-e92c1fbeb66f', 'TEMPORARY', 'ALL', 'GOODS.RETAIL.SMC-28', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.RETAIL.SMC-28' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 29 Restaurant – small (500–1,000 sq. ft.): Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '06fec155-93ee-6db9-d6a0-faea0dde984e', 'TEMPORARY', 'ALL', 'SERVICES.HOSPITALITY.SMC-29', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'SERVICES.HOSPITALITY.SMC-29' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 30 Restaurant – large (> 1,000 sq. ft.): Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'b297e215-b31c-c35f-1fb9-7db92df49604', 'TEMPORARY', 'ALL', 'SERVICES.HOSPITALITY.SMC-30', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'SERVICES.HOSPITALITY.SMC-30' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 31 Restaurant & bar: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '5074ceb2-2915-a025-2dd1-b37db7c00a26', 'TEMPORARY', 'ALL', 'SERVICES.HOSPITALITY.SMC-31', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'SERVICES.HOSPITALITY.SMC-31' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 32 Restaurant with lodging: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'c0a55e7d-7301-72c7-a151-90aa3b014e4d', 'TEMPORARY', 'ALL', 'SERVICES.HOSPITALITY.SMC-32', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'SERVICES.HOSPITALITY.SMC-32' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 33 Lodging: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '105c6be5-f8cd-62a3-bc66-f7e1de5b23bb', 'TEMPORARY', 'ALL', 'SERVICES.HOSPITALITY.SMC-33', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'SERVICES.HOSPITALITY.SMC-33' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 34 Laundry: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'af55e3cc-e5d6-8626-ab60-c6186cca1107', 'TEMPORARY', 'ALL', 'SERVICES.GENERAL.SMC-34', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'SERVICES.GENERAL.SMC-34' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 35 Laundry with dry cleaning: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '47857245-4c74-ae1e-c8ab-b0e8f3615c71', 'TEMPORARY', 'ALL', 'SERVICES.GENERAL.SMC-35', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'SERVICES.GENERAL.SMC-35' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 36 Lime processing: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '4e951d3f-1ab8-daf5-ac07-753e5bd1d63a', 'TEMPORARY', 'ALL', 'GOODS.MANUFACTURE.SMC-36', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MANUFACTURE.SMC-36' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 37 Vehicle service station: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'c75ab396-c227-5bf3-0f31-b407dc016476', 'TEMPORARY', 'ALL', 'SERVICES.GENERAL.SMC-37', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'SERVICES.GENERAL.SMC-37' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 38 Spice production / chilli grinding: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '130ecfff-df7a-4c27-3424-09e73384f744', 'TEMPORARY', 'ALL', 'GOODS.MANUFACTURE.SMC-38', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MANUFACTURE.SMC-38' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 39 Electroplating / coating: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '19d5f01c-706e-3568-243d-24c89fec44b9', 'TEMPORARY', 'ALL', 'GOODS.MANUFACTURE.SMC-39', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MANUFACTURE.SMC-39' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 40 Furniture: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '90c0f842-ad3c-c8c4-cd97-40cce02078cd', 'TEMPORARY', 'ALL', 'GOODS.MANUFACTURE.SMC-40', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MANUFACTURE.SMC-40' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 41 Timber / storage yard (Vakhar): Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '57a8d073-09dd-1795-2663-00ad4098b6a7', 'TEMPORARY', 'ALL', 'GOODS.WHOLESALE.SMC-41', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.WHOLESALE.SMC-41' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 42 Fireworks sale: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '32eb5e9e-2e8f-af0c-3df9-70668ac853b5', 'TEMPORARY', 'ALL', 'GOODS.RETAIL.SMC-42', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.RETAIL.SMC-42' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 43 Petrol pump: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '203cf2d2-e554-1287-e4a9-348c08b61761', 'TEMPORARY', 'ALL', 'GOODS.RETAIL.SMC-43', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.RETAIL.SMC-43' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 44 Puffed rice (murmure) making: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '7f4f003f-5792-751b-ad71-a791b47b5c14', 'TEMPORARY', 'ALL', 'GOODS.MANUFACTURE.SMC-44', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MANUFACTURE.SMC-44' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 45 Lodging & bar: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'e8cf48d2-902a-9edb-25f0-40ac82d5a1ef', 'TEMPORARY', 'ALL', 'SERVICES.HOSPITALITY.SMC-45', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'SERVICES.HOSPITALITY.SMC-45' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 46 Colour photo lab: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '9eea1c7b-7ba7-04a4-01f6-55376bd55caa', 'TEMPORARY', 'ALL', 'SERVICES.GENERAL.SMC-46', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'SERVICES.GENERAL.SMC-46' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 47 Wheel alignment: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '2468d018-7169-31d7-7f39-cfc091e903c1', 'TEMPORARY', 'ALL', 'SERVICES.GENERAL.SMC-47', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'SERVICES.GENERAL.SMC-47' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 48 Hotel – large (> 1,000 sq. ft.): Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'f9ae8a3c-a468-3eda-089d-8f8af28bd791', 'TEMPORARY', 'ALL', 'SERVICES.HOSPITALITY.SMC-48', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'SERVICES.HOSPITALITY.SMC-48' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 49 Hotel – small (< 1,000 sq. ft.): Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '0c75e452-ec68-eda4-d847-b52c63e0db1e', 'TEMPORARY', 'ALL', 'SERVICES.HOSPITALITY.SMC-49', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'SERVICES.HOSPITALITY.SMC-49' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 50 Hotel & bar: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'eef08bbe-e331-2641-a9ef-76159b55f4fb', 'TEMPORARY', 'ALL', 'SERVICES.HOSPITALITY.SMC-50', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'SERVICES.HOSPITALITY.SMC-50' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 51 Hotel & lodging: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '84a8781e-167f-46b8-d4f0-c32fd5ed43ee', 'TEMPORARY', 'ALL', 'SERVICES.HOSPITALITY.SMC-51', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'SERVICES.HOSPITALITY.SMC-51' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 52 Country liquor shop: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '41c74fae-8e09-8880-3e3f-02b76ede32f7', 'TEMPORARY', 'ALL', 'GOODS.RETAIL.SMC-52', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.RETAIL.SMC-52' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 53 Wine shop: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'cfeb106d-6436-cdda-2179-9dc35bacc3d1', 'TEMPORARY', 'ALL', 'GOODS.RETAIL.SMC-53', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.RETAIL.SMC-53' AND applicationtype = 'NEW' AND accessorycategory IS NULL);

COMMIT;
