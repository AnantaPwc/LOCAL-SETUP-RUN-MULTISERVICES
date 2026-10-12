-- Sangamner Municipal Council: License Charge Master (Annexure 1) for the renewal of the permanent trade license (TL_RENEW)
-- Tenant pg.smc, applicationType RENEWAL. Safe to re-run.
--
-- The renewal fee is the Annexure 1 rate of the business type, the same as for a new license. tl-calculator looks
-- the slab up by applicationType, so every PERMANENT / NEW slab gets a RENEWAL copy with the same rate.
-- Run billingslab_TL_SMC_Annexure1.sql first. When a rate changes, change it in both rows (NEW and RENEWAL);
-- a business type added later gets its RENEWAL slab by running this file again.
-- The double fee of a late renewal is not a slab: it comes from the MDMS master TradeLicense.Penalty (rate 100).

BEGIN;

INSERT INTO eg_tl_billingslab (tenantid, id, licensetype, structuretype, tradetype, accessorycategory, type, uom, fromuom, touom, rate, applicationtype, createdtime, createdby, lastmodifiedtime, lastmodifiedby)
SELECT n.tenantid, md5('SMC-RENEWAL-' || n.id)::uuid::text, n.licensetype, n.structuretype, n.tradetype, NULL, n.type, n.uom, n.fromuom, n.touom, n.rate, 'RENEWAL', 1774981800000, 'SMC-SETUP', 1774981800000, 'SMC-SETUP'
FROM eg_tl_billingslab n
WHERE n.tenantid = 'pg.smc' AND n.licensetype = 'PERMANENT' AND n.applicationtype = 'NEW' AND n.accessorycategory IS NULL
  AND NOT EXISTS (SELECT 1 FROM eg_tl_billingslab r WHERE r.tenantid = n.tenantid AND r.licensetype = n.licensetype
                  AND r.tradetype = n.tradetype AND r.applicationtype = 'RENEWAL' AND r.accessorycategory IS NULL);

COMMIT;

-- Check: both counts must be equal, and no row may be returned by the second query
-- SELECT applicationtype, count(*) FROM eg_tl_billingslab WHERE tenantid = 'pg.smc' AND licensetype = 'PERMANENT' GROUP BY 1;
-- SELECT n.tradetype, n.rate AS new_rate, r.rate AS renewal_rate FROM eg_tl_billingslab n JOIN eg_tl_billingslab r
--   ON r.tenantid = n.tenantid AND r.tradetype = n.tradetype AND r.licensetype = n.licensetype AND r.applicationtype = 'RENEWAL'
--   WHERE n.tenantid = 'pg.smc' AND n.licensetype = 'PERMANENT' AND n.applicationtype = 'NEW' AND n.rate <> r.rate;
