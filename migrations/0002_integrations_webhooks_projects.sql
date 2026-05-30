PRAGMA foreign_keys = ON;

-- Purchases: support donations + external sources (Stripe/Shopify)
ALTER TABLE purchases ADD COLUMN kind TEXT NOT NULL DEFAULT 'purchase';
ALTER TABLE purchases ADD COLUMN source TEXT NOT NULL DEFAULT 'manual';
ALTER TABLE purchases ADD COLUMN external_id TEXT;
ALTER TABLE purchases ADD COLUMN metadata_json TEXT;

CREATE INDEX IF NOT EXISTS idx_purchases_base_kind ON purchases(base_id, kind);
CREATE UNIQUE INDEX IF NOT EXISTS uniq_purchases_base_source_external ON purchases(base_id, source, external_id);

-- Projects: preconfigured "project data" storage
CREATE TABLE IF NOT EXISTS projects (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  base_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL DEFAULT 'active',
  start_date TEXT,
  end_date TEXT,
  metadata_json TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (base_id) REFERENCES customer_bases(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_projects_base_id ON projects(base_id);

-- Integrations: per-base configuration and inbound webhook routing tokens
CREATE TABLE IF NOT EXISTS integrations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  base_id INTEGER NOT NULL,
  provider TEXT NOT NULL,
  enabled INTEGER NOT NULL DEFAULT 1,
  webhook_token TEXT NOT NULL UNIQUE,
  config_json TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (base_id, provider),
  FOREIGN KEY (base_id) REFERENCES customer_bases(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_integrations_base_id ON integrations(base_id);
CREATE INDEX IF NOT EXISTS idx_integrations_provider ON integrations(provider);

-- Outbound webhooks: user-defined event subscriptions
CREATE TABLE IF NOT EXISTS webhook_endpoints (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  base_id INTEGER NOT NULL,
  url TEXT NOT NULL,
  description TEXT,
  secret TEXT NOT NULL,
  enabled INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (base_id) REFERENCES customer_bases(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_webhook_endpoints_base_id ON webhook_endpoints(base_id);

CREATE TABLE IF NOT EXISTS webhook_endpoint_events (
  endpoint_id INTEGER NOT NULL,
  event_type TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  PRIMARY KEY (endpoint_id, event_type),
  FOREIGN KEY (endpoint_id) REFERENCES webhook_endpoints(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_webhook_endpoint_events_event_type ON webhook_endpoint_events(event_type);
