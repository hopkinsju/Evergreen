-- Resolve some discrepancies in the auditor schema between a fresh
-- install and an upgraded database.

BEGIN;

INSERT INTO config.upgrade_log (version) VALUES ('0413'); -- Scott McKellar

UPDATE auditor.actor_org_unit_history
SET fiscal_calendar = 1
WHERE fiscal_calendar IS NULL;

ALTER TABLE auditor.actor_org_unit_history
    ALTER COLUMN fiscal_calendar SET NOT NULL;

DROP VIEW auditor.actor_org_unit_lifecycle;

SELECT auditor.create_auditor_lifecycle( 'actor', 'org_unit' );

ALTER TABLE auditor.actor_usr_history
	ALTER COLUMN claims_never_checked_out_count DROP DEFAULT;

DROP VIEW auditor.actor_usr_lifecycle;

SELECT auditor.create_auditor_lifecycle( 'actor', 'usr' );

UPDATE auditor.asset_call_number_history
SET label_class = 1
WHERE label_class IS NULL;

ALTER TABLE auditor.asset_call_number_history
    ALTER COLUMN label_class SET NOT NULL;

DROP VIEW auditor.asset_call_number_lifecycle;

SELECT auditor.create_auditor_lifecycle( 'asset', 'call_number' );

UPDATE auditor.asset_copy_history
SET floating  = false
WHERE floating IS NULL;

ALTER TABLE auditor.asset_copy_history
	ALTER COLUMN floating SET NOT NULL;

DROP VIEW auditor.asset_copy_lifecycle;

SELECT auditor.create_auditor_lifecycle( 'asset', 'copy' );

DROP VIEW auditor.biblio_record_entry_lifecycle;

SELECT auditor.create_auditor_lifecycle( 'biblio', 'record_entry' );

COMMIT;

-- Outside of transaction; failure is okay if the 
-- index already exists

\qecho Creating some indexes outside of a transaction.  If a CREATE
\qecho fails because the index already exists, ignore the failure.

CREATE INDEX aud_actor_usr_address_hist_id_idx
	ON auditor.actor_usr_address_history ( id );

CREATE INDEX aud_actor_usr_hist_id_idx
    ON auditor.actor_usr_history ( id );

CREATE INDEX aud_asset_cn_hist_creator_idx
	ON auditor.asset_call_number_history ( creator );

CREATE INDEX aud_asset_cn_hist_editor_idx
	ON auditor.asset_call_number_history ( editor );

CREATE INDEX aud_asset_cp_hist_creator_idx
	ON auditor.asset_copy_history ( creator );

CREATE INDEX aud_asset_cp_hist_editor_idx
	ON auditor.asset_copy_history ( editor );

CREATE INDEX aud_bib_rec_entry_hist_creator_idx
	ON auditor.biblio_record_entry_history ( creator );

CREATE INDEX aud_bib_rec_entry_hist_editor_idx
	ON auditor.biblio_record_entry_history ( editor );
