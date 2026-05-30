PRAGMA foreign_keys = ON;

-- Managed inbound webhook links per data store.
-- Each link has a unique token embedded in its URL.
-- Optional secret: validated via X-Webhook-Secret request header.
-- Optional callback_url: incoming payloads are forwarded there after storage.
CREATE TABLE IF NOT EXISTS datastore_webhook_links (
  id           INTEGER PRIMARY KEY AUTOINCREMENT,
  datastore_id INTEGER NOT NULL,
  label        TEXT,
  token        TEXT NOT NULL UNIQUE,
  secret       TEXT,
  callback_url TEXT,
  enabled      INTEGER NOT NULL DEFAULT 1,
  created_at   TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (datastore_id) REFERENCES datastores(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_dwl_datastore_id ON datastore_webhook_links(datastore_id);
CREATE INDEX IF NOT EXISTS idx_dwl_token        ON datastore_webhook_links(token);
