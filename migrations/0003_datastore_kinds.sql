PRAGMA foreign_keys = ON;

-- Add datastore "kind" + optional config for typed stores
ALTER TABLE datastores ADD COLUMN kind TEXT NOT NULL DEFAULT 'json';
ALTER TABLE datastores ADD COLUMN config_json TEXT;

CREATE INDEX IF NOT EXISTS idx_datastores_base_kind ON datastores(base_id, kind);
