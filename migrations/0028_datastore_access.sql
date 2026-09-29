PRAGMA foreign_keys = ON;

ALTER TABLE datastores ADD COLUMN archived_at TEXT;
ALTER TABLE datastores ADD COLUMN access_mode TEXT NOT NULL DEFAULT 'project';

CREATE TABLE IF NOT EXISTS datastore_user_access (
  datastore_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  permission TEXT NOT NULL CHECK (permission IN ('view', 'edit', 'manage')),
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  PRIMARY KEY (datastore_id, user_id),
  FOREIGN KEY (datastore_id) REFERENCES datastores(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_datastore_user_access_user
  ON datastore_user_access(user_id, datastore_id);
CREATE INDEX IF NOT EXISTS idx_datastores_base_archived
  ON datastores(base_id, archived_at);

CREATE TRIGGER IF NOT EXISTS prevent_archived_datastore_entry_insert
BEFORE INSERT ON datastore_entries
WHEN EXISTS (
  SELECT 1 FROM datastores
  WHERE id = NEW.datastore_id AND archived_at IS NOT NULL
)
BEGIN
  SELECT RAISE(ABORT, 'archived datastore is read-only');
END;

CREATE TRIGGER IF NOT EXISTS prevent_archived_datastore_entry_update
BEFORE UPDATE ON datastore_entries
WHEN EXISTS (
  SELECT 1 FROM datastores
  WHERE id = NEW.datastore_id AND archived_at IS NOT NULL
)
BEGIN
  SELECT RAISE(ABORT, 'archived datastore is read-only');
END;
