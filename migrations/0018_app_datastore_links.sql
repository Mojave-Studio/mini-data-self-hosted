-- Designates which datastores are connected to each Mojave app per base.
-- These are passed to the external app via /auth/verify-app-token.
CREATE TABLE IF NOT EXISTS app_datastore_links (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  base_id      INTEGER NOT NULL,
  app_key      TEXT    NOT NULL,
  datastore_id INTEGER NOT NULL,
  role         TEXT,                         -- optional label, e.g. 'contacts', 'catalog'
  created_at   TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(base_id, app_key, datastore_id),
  FOREIGN KEY (base_id)      REFERENCES customer_bases(id) ON DELETE CASCADE,
  FOREIGN KEY (datastore_id) REFERENCES datastores(id)      ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_adl_base_app    ON app_datastore_links(base_id, app_key);
CREATE INDEX IF NOT EXISTS idx_adl_datastore   ON app_datastore_links(datastore_id);
