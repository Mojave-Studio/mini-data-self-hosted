PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS customer_bases (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS contacts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  base_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  status TEXT NOT NULL DEFAULT 'active',
  metadata_json TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (base_id) REFERENCES customer_bases(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS leads (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  base_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  email TEXT,
  source TEXT,
  status TEXT NOT NULL DEFAULT 'new',
  notes TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (base_id) REFERENCES customer_bases(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS purchases (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  base_id INTEGER NOT NULL,
  contact_id INTEGER,
  amount_cents INTEGER NOT NULL,
  currency TEXT NOT NULL DEFAULT 'USD',
  description TEXT,
  purchased_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (base_id) REFERENCES customer_bases(id) ON DELETE CASCADE,
  FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS datastores (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  base_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  schema_json TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (base_id, name),
  FOREIGN KEY (base_id) REFERENCES customer_bases(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS datastore_entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  datastore_id INTEGER NOT NULL,
  entry_key TEXT NOT NULL,
  data_json TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (datastore_id, entry_key),
  FOREIGN KEY (datastore_id) REFERENCES datastores(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_contacts_base_id ON contacts(base_id);
CREATE INDEX IF NOT EXISTS idx_leads_base_id ON leads(base_id);
CREATE INDEX IF NOT EXISTS idx_purchases_base_id ON purchases(base_id);
CREATE INDEX IF NOT EXISTS idx_datastores_base_id ON datastores(base_id);
CREATE INDEX IF NOT EXISTS idx_datastore_entries_datastore_id ON datastore_entries(datastore_id);
