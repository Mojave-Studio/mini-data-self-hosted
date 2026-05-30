-- API tokens for Mojave app integrations (Contact Engine, Quote Generator, etc.)
-- Owner generates tokens here; external apps validate via POST /auth/verify-app-token
CREATE TABLE IF NOT EXISTS app_credentials (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  base_id INTEGER,
  label TEXT NOT NULL,
  token TEXT NOT NULL UNIQUE,
  app_key TEXT,
  scopes TEXT NOT NULL DEFAULT 'read',
  expires_at TEXT,
  last_used_at TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (base_id) REFERENCES customer_bases(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_app_credentials_token ON app_credentials(token);
CREATE INDEX IF NOT EXISTS idx_app_credentials_user_id ON app_credentials(user_id);
