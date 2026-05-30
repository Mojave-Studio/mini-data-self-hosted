PRAGMA foreign_keys = ON;

-- Add a dedicated tags column to datastore_entries for efficient cross-store tag queries.
-- Tags are stored as a JSON array string, e.g. '["featured","draft"]'.
-- Documents kind: populated on create/update alongside data_json.tags.
-- All other kinds: populated when entries are created/updated with a tags field.
ALTER TABLE datastore_entries ADD COLUMN tags_json TEXT;

CREATE INDEX IF NOT EXISTS idx_datastore_entries_tags ON datastore_entries(datastore_id, tags_json)
  WHERE tags_json IS NOT NULL;
