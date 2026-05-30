-- App-to-app links: records which Mojave apps are linked together on a base
CREATE TABLE IF NOT EXISTS app_links (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  base_id INTEGER NOT NULL,
  app_a TEXT NOT NULL,
  app_b TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (base_id) REFERENCES customer_bases(id) ON DELETE CASCADE,
  UNIQUE(base_id, app_a, app_b)
);

CREATE INDEX IF NOT EXISTS idx_app_links_base_id ON app_links(base_id);
