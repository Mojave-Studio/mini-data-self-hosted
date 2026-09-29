PRAGMA foreign_keys = ON;

-- Per-project Mojave app configuration (Quote Generator branding, defaults, etc.)
CREATE TABLE IF NOT EXISTS app_config (
  base_id     INTEGER NOT NULL,
  app_key     TEXT NOT NULL,
  config_json TEXT NOT NULL DEFAULT '{}',
  updated_at  TEXT NOT NULL DEFAULT (datetime('now')),
  PRIMARY KEY (base_id, app_key),
  FOREIGN KEY (base_id) REFERENCES customer_bases(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_app_config_base ON app_config(base_id);
