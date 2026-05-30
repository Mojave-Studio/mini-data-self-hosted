PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS project_services (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  base_id INTEGER NOT NULL,
  service_key TEXT NOT NULL,
  enabled INTEGER NOT NULL DEFAULT 1,
  config_json TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (base_id, service_key),
  FOREIGN KEY (base_id) REFERENCES customer_bases(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_project_services_base_id ON project_services(base_id);
