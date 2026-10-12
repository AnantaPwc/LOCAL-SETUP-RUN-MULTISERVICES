-- Sangamner Municipal Council: License Charge Master for the renewal of the temporary trade license (TTL_RENEW)
-- Tenant pg.smc, applicationType RENEWAL, flat Rs. 500. Safe to re-run.
--
-- tl-calculator looks the slab up by applicationType, so every TEMPORARY / NEW slab (the 53 Annexure 1 business types
-- and the 20 movable ones) gets a RENEWAL copy with the same rate. Run billingslab_TL_SMC_Annexure1.sql and
-- billingslab_TL_SMC_movable.sql first; a business type added later gets its RENEWAL slab by running this file again.
-- The double fee of a late renewal is not a slab: it comes from the MDMS master TradeLicense.Penalty (rate 100).

BEGIN;

INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT n.tenantid, md5('SMC-RENEWAL-' || n.id)::uuid::text, n.licensetype, n.structuretype, n.tradetype, NULL, n.type, n.uom, n.fromuom, n.touom, n.rate, 'RENEWAL', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
FROM eg_tl_billingslab n
WHERE n.tenantid = 'pg.smc' AND n.licensetype = 'TEMPORARY' AND n.applicationtype = 'NEW' AND n.accessorycategory IS NULL
  AND NOT EXISTS (SELECT 1 FROM eg_tl_billingslab r WHERE r.tenantid = n.tenantid AND r.licensetype = n.licensetype
                  AND r.tradetype = n.tradetype AND r.applicationtype = 'RENEWAL' AND r.accessorycategory IS NULL);

COMMIT;

-- Check: NEW and RENEWAL counts must be equal
-- SELECT applicationtype, count(*) FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'TEMPORARY' GROUP BY 1;
