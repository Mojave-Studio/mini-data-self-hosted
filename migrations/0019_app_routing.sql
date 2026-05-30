-- Routing rules: maps each app event type to a target datastore + field mapping.
-- The field_mapping_json column stores { "source_field": "target_column" } pairs.
-- Contact Engine reads this via verify-app-token to know where to send each event.
CREATE TABLE IF NOT EXISTS app_routing (
  id                 INTEGER PRIMARY KEY AUTOINCREMENT,
  base_id            INTEGER NOT NULL,
  app_key            TEXT    NOT NULL,
  event_type         TEXT    NOT NULL,   -- e.g. 'lead', 'contact', 'interaction'
  datastore_id       INTEGER,            -- NULL = event not routed
  field_mapping_json TEXT    NOT NULL DEFAULT '{}',
  created_at         TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at         TEXT    NOT NULL DEFAULT (datetime('now')),
  UNIQUE(base_id, app_key, event_type),
  FOREIGN KEY (base_id)      REFERENCES customer_bases(id) ON DELETE CASCADE,
  FOREIGN KEY (datastore_id) REFERENCES datastores(id)     ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_app_routing_base_app ON app_routing(base_id, app_key);
