-- Deletes ALL trade license applications of one city (Permanent, Temporary and renewals) with everything
-- that hangs on them: workflow history, fee calculation, demands, bills, payments and receipts.
-- Meant for clearing test data before go-live. IT CANNOT BE UNDONE once committed.
--
-- Scope: tenant pg.smc, business service TL. Not touched:
--   - other cities (pg.citya has its own trade licenses) and BPAREG registrations, which share these tables
--   - the setup: billing slabs, workflow definitions (TL_NEW, TTL_NEW, TL_RENEW), MDMS, users (eg_user)
--   - the number sequences: application, license and receipt numbers continue from where they are
--
-- How to run:
--   1. Run the file as it is. It ends with ROLLBACK, so nothing is deleted; read the row counts it prints.
--   2. If the counts are what you expect, change the last statement from ROLLBACK to COMMIT and run it again.
--   psql -v ON_ERROR_STOP=1 -h <host> -U <user> -d <database> -f cleanup_TL_applications_pg_smc.sql

\set tenant '''pg.smc'''

BEGIN;

-- ---- what will be deleted ------------------------------------------------------------------------------
CREATE TEMP TABLE tl_del ON COMMIT DROP AS
SELECT l.id, l.applicationnumber, d.id AS detailid
FROM eg_tl_tradelicense l LEFT JOIN eg_tl_tradelicensedetail d ON d.tradelicenseid = l.id
WHERE l.tenantid = :tenant AND coalesce(l.businessservice, 'TL') = 'TL';

CREATE TEMP TABLE tl_del_demand ON COMMIT DROP AS
SELECT id FROM egbs_demand_v1
WHERE tenantid = :tenant AND businessservice = 'TL' AND consumercode IN (SELECT applicationnumber FROM tl_del);

CREATE TEMP TABLE tl_del_billdetail ON COMMIT DROP AS
SELECT id, billid FROM egbs_billdetail_v1
WHERE tenantid = :tenant AND businessservice = 'TL' AND consumercode IN (SELECT applicationnumber FROM tl_del);

CREATE TEMP TABLE tl_del_clbill ON COMMIT DROP AS
SELECT id FROM egcl_bill
WHERE tenantid = :tenant AND businessservice = 'TL' AND consumercode IN (SELECT applicationnumber FROM tl_del);

CREATE TEMP TABLE tl_del_paymentdetail ON COMMIT DROP AS
SELECT id, paymentid FROM egcl_paymentdetail
WHERE tenantid = :tenant AND businessservice = 'TL' AND billid IN (SELECT id FROM tl_del_clbill);

SELECT 'applications to delete' AS what, count(DISTINCT id) AS rows FROM tl_del
UNION ALL SELECT 'demands', count(*) FROM tl_del_demand
UNION ALL SELECT 'bills', count(DISTINCT billid) FROM tl_del_billdetail
UNION ALL SELECT 'receipts', count(*) FROM tl_del_paymentdetail;

-- ---- payments and receipts (collection-services) ---------------------------------------------------------
DELETE FROM egcl_billdetial_audit WHERE billid IN (SELECT id FROM tl_del_clbill);
DELETE FROM egcl_bill_audit WHERE id IN (SELECT id FROM tl_del_clbill);
DELETE FROM egcl_paymentdetail_audit WHERE id IN (SELECT id FROM tl_del_paymentdetail);
DELETE FROM egcl_billaccountdetail WHERE billdetailid IN (SELECT id FROM egcl_billdetial WHERE billid IN (SELECT id FROM tl_del_clbill));
DELETE FROM egcl_billdetial WHERE billid IN (SELECT id FROM tl_del_clbill);
DELETE FROM egcl_bill WHERE id IN (SELECT id FROM tl_del_clbill);
DELETE FROM egcl_paymentdetail WHERE id IN (SELECT id FROM tl_del_paymentdetail);
-- a payment goes only when no other receipt is left on it
DELETE FROM egcl_payment_audit WHERE id IN (SELECT paymentid FROM tl_del_paymentdetail)
  AND NOT EXISTS (SELECT 1 FROM egcl_paymentdetail pd WHERE pd.paymentid = egcl_payment_audit.id);
DELETE FROM egcl_payment WHERE id IN (SELECT paymentid FROM tl_del_paymentdetail)
  AND NOT EXISTS (SELECT 1 FROM egcl_paymentdetail pd WHERE pd.paymentid = egcl_payment.id);

-- ---- bills and demands (billing-service) ---------------------------------------------------------------
DELETE FROM egbs_billaccountdetail_v1 WHERE tenantid = :tenant AND billdetail IN (SELECT id FROM tl_del_billdetail);
DELETE FROM egbs_billdetail_v1 WHERE tenantid = :tenant AND id IN (SELECT id FROM tl_del_billdetail);
DELETE FROM egbs_bill_v1 WHERE tenantid = :tenant AND id IN (SELECT billid FROM tl_del_billdetail)
  AND NOT EXISTS (SELECT 1 FROM egbs_billdetail_v1 bd WHERE bd.billid = egbs_bill_v1.id AND bd.tenantid = egbs_bill_v1.tenantid);
DELETE FROM egbs_demanddetail_v1_audit WHERE tenantid = :tenant AND demandid IN (SELECT id FROM tl_del_demand);
DELETE FROM egbs_demand_v1_audit WHERE tenantid = :tenant AND demandid IN (SELECT id FROM tl_del_demand);
DELETE FROM egbs_demanddetail_v1 WHERE tenantid = :tenant AND demandid IN (SELECT id FROM tl_del_demand);
DELETE FROM egbs_demand_v1 WHERE tenantid = :tenant AND id IN (SELECT id FROM tl_del_demand);

-- ---- fee calculation (tl-calculator) and workflow history ------------------------------------------------
DELETE FROM eg_tl_calculator_tradetype WHERE tenantid = :tenant AND consumercode IN (SELECT applicationnumber FROM tl_del);
DELETE FROM eg_tl_calculator_accessory WHERE tenantid = :tenant AND consumercode IN (SELECT applicationnumber FROM tl_del);
-- assignees and workflow documents go with the process instance (ON DELETE CASCADE)
DELETE FROM eg_wf_processinstance_v2 WHERE tenantid = :tenant AND businessid IN (SELECT applicationnumber FROM tl_del);

-- ---- the applications (tl-services) ----------------------------------------------------------------------
DELETE FROM eg_tl_tradelicensedetail_audit WHERE tradelicenseid IN (SELECT id FROM tl_del);
DELETE FROM eg_tl_tradelicense_audit WHERE tenantid = :tenant AND id IN (SELECT id FROM tl_del);
DELETE FROM eg_tl_accessory WHERE tradelicensedetailid IN (SELECT detailid FROM tl_del);
DELETE FROM eg_tl_applicationdocument WHERE tradelicensedetailid IN (SELECT detailid FROM tl_del);
DELETE FROM eg_tl_verificationdocument WHERE tradelicensedetailid IN (SELECT detailid FROM tl_del);
DELETE FROM eg_tl_tradeunit WHERE tradelicensedetailid IN (SELECT detailid FROM tl_del);
-- address, owners, owner documents and institution go with the detail (ON DELETE CASCADE)
DELETE FROM eg_tl_tradelicensedetail WHERE id IN (SELECT detailid FROM tl_del);
DELETE FROM eg_tl_tradelicense WHERE id IN (SELECT id FROM tl_del);

-- ---- what is left: every count must be 0 -----------------------------------------------------------------
SELECT 'applications left' AS what, count(*) AS rows FROM eg_tl_tradelicense WHERE tenantid = :tenant AND coalesce(businessservice, 'TL') = 'TL'
UNION ALL SELECT 'workflow rows left', count(*) FROM eg_wf_processinstance_v2 WHERE tenantid = :tenant AND businessid IN (SELECT applicationnumber FROM tl_del)
UNION ALL SELECT 'demands left', count(*) FROM egbs_demand_v1 WHERE tenantid = :tenant AND businessservice = 'TL' AND consumercode IN (SELECT applicationnumber FROM tl_del)
UNION ALL SELECT 'receipts left', count(*) FROM egcl_paymentdetail WHERE id IN (SELECT id FROM tl_del_paymentdetail);

-- Nothing is deleted while this says ROLLBACK. Change it to COMMIT to delete for good.
ROLLBACK;
