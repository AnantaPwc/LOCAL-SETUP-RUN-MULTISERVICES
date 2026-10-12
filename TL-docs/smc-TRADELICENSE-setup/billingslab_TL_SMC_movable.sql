-- Sangamner Municipal Council: License Charge Master for the movable business types (list "Movable licenses items")
-- Tenant pg.smc, TEMPORARY, applicationType NEW, flat Rs. 500 for the year. Safe to re-run.
-- Load mdms_TradeLicense_TradeType_SMC_movable.json into MDMS as well: tl-services accepts a business type only when it
-- has a billing slab, and the UI lists it only when it is in MDMS.

BEGIN;

-- Sr. 1 Pan Shop: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '506f6fe7-a73f-d7e0-0bcc-e03e2dc10fc7', 'TEMPORARY', 'ALL', 'GOODS.MOVABLE.SMC-M01', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MOVABLE.SMC-M01' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 2 Vada Pav Sales: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '204f72cd-c105-cf2b-7c3d-4eef21d7486a', 'TEMPORARY', 'ALL', 'GOODS.MOVABLE.SMC-M02', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MOVABLE.SMC-M02' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 3 Tea Sales: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '898d483f-d2f1-2373-2ea4-cbcf79484186', 'TEMPORARY', 'ALL', 'GOODS.MOVABLE.SMC-M03', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MOVABLE.SMC-M03' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 4 Artificial Jewellery: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '04e595bf-dee7-5485-3f06-ad0d7d5a4ebe', 'TEMPORARY', 'ALL', 'GOODS.MOVABLE.SMC-M04', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MOVABLE.SMC-M04' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 5 Ice Cream Sales: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '2446d672-c8ef-4da7-ec89-38123255469f', 'TEMPORARY', 'ALL', 'GOODS.MOVABLE.SMC-M05', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MOVABLE.SMC-M05' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 6 Pav Bhaji and Pizza: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'ec1e4b50-8ba2-bc13-75c1-56b87038521b', 'TEMPORARY', 'ALL', 'GOODS.MOVABLE.SMC-M06', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MOVABLE.SMC-M06' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 7 Cold-Pressed Oil Mill: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '6b10a9f3-495b-b3ff-27d9-55deb7181b79', 'TEMPORARY', 'ALL', 'GOODS.MOVABLE.SMC-M07', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MOVABLE.SMC-M07' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 8 Omelette Pav: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '00cbb263-f66d-6737-50ac-74bda6a07e0b', 'TEMPORARY', 'ALL', 'GOODS.MOVABLE.SMC-M08', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MOVABLE.SMC-M08' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 9 Idli and Dosa: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'f5035d12-0dd0-02fe-9b35-ee11a6ab5c24', 'TEMPORARY', 'ALL', 'GOODS.MOVABLE.SMC-M09', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MOVABLE.SMC-M09' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 10 Vada Pav and Tea: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'e1aec657-b7ef-e3db-8894-c6ae6e773386', 'TEMPORARY', 'ALL', 'GOODS.MOVABLE.SMC-M10', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MOVABLE.SMC-M10' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 11 Country Liquor Shop: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '6a1e89df-0c16-42e8-2313-732751bca83e', 'TEMPORARY', 'ALL', 'GOODS.MOVABLE.SMC-M11', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MOVABLE.SMC-M11' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 12 Cake Sales: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '4f118bc4-fcc7-0877-d104-0f1017e4b3e1', 'TEMPORARY', 'ALL', 'GOODS.MOVABLE.SMC-M12', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MOVABLE.SMC-M12' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 13 Laundry: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '7311f982-fee1-bb91-b505-0c5065e79816', 'TEMPORARY', 'ALL', 'SERVICES.MOVABLE.SMC-M13', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'SERVICES.MOVABLE.SMC-M13' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 14 Welding and Fabrication: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'ed2ddaaa-12b0-cb3f-dc0f-cfedb6796ffb', 'TEMPORARY', 'ALL', 'SERVICES.MOVABLE.SMC-M14', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'SERVICES.MOVABLE.SMC-M14' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 15 Pav Bhaji: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '49290ca1-32f4-b7d6-9bb2-8a3cc56b9a7a', 'TEMPORARY', 'ALL', 'GOODS.MOVABLE.SMC-M15', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MOVABLE.SMC-M15' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 16 Samosa Shop: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '2e22d2b1-5990-8eb7-9c8a-63d7f5ae8b05', 'TEMPORARY', 'ALL', 'GOODS.MOVABLE.SMC-M16', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MOVABLE.SMC-M16' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 17 Pani Puri: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'd87553d7-83df-b8d3-29f1-b2a84b2d2acf', 'TEMPORARY', 'ALL', 'GOODS.MOVABLE.SMC-M17', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MOVABLE.SMC-M17' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 18 Bhel Sales: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '245f34d4-97aa-2fa0-0826-e021be2b973f', 'TEMPORARY', 'ALL', 'GOODS.MOVABLE.SMC-M18', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'GOODS.MOVABLE.SMC-M18' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 19 Fabrication: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', '3176af58-e63c-9035-65ef-1c22d0e0af1c', 'TEMPORARY', 'ALL', 'SERVICES.MOVABLE.SMC-M19', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'SERVICES.MOVABLE.SMC-M19' AND applicationtype = 'NEW' AND accessorycategory IS NULL);
-- Sr. 20 Beauty Parlour: Rs. 500
INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT 'pg.smc', 'ff705b43-2aaf-da8a-802a-bf0353e154e0', 'TEMPORARY', 'ALL', 'SERVICES.MOVABLE.SMC-M20', NULL, 'FLAT', NULL, NULL, NULL, 500, 'NEW', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
WHERE NOT EXISTS (SELECT 1 FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' AND tradetype = 'SERVICES.MOVABLE.SMC-M20' AND applicationtype = 'NEW' AND accessorycategory IS NULL);

COMMIT;
