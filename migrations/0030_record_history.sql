-- Append-only change history for all records and files.
-- Captures who (actor), how (via), what (action + before/after snapshots), why (reason), and when.
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS record_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  base_id INTEGER,
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  parent_type TEXT,
  parent_id TEXT,
  action TEXT NOT NULL,
  actor TEXT,
  via TEXT,
  reason TEXT,
  detail_json TEXT,
  before_json TEXT,
  after_json TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_record_history_entity
  ON record_history(entity_type, entity_id, created_at);
CREATE INDEX IF NOT EXISTS idx_record_history_base
  ON record_history(base_id, created_at);
CREATE INDEX IF NOT EXISTS idx_record_history_parent
  ON record_history(parent_type, parent_id, created_at);
