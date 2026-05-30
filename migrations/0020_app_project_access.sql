-- Which projects each Mojave app is allowed to read/write.
-- Access control only — field mapping and routing are handled within the app itself.
CREATE TABLE IF NOT EXISTS app_project_access (
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  base_id        INTEGER NOT NULL,   -- the project this app is connected to (home base)
  app_key        TEXT    NOT NULL,
  target_base_id INTEGER NOT NULL,   -- the project being exposed to the app
  created_at     TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE(base_id, app_key, target_base_id),
  FOREIGN KEY (base_id)        REFERENCES customer_bases(id) ON DELETE CASCADE,
  FOREIGN KEY (target_base_id) REFERENCES customer_bases(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_apa_base_app ON app_project_access(base_id, app_key);
