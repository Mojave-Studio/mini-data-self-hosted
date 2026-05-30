PRAGMA foreign_keys = ON;

-- Auth relay links — each token is a unique OAuth entry point that
-- redirects the authenticated user to a configured destination URL.
CREATE TABLE IF NOT EXISTS auth_links (
  id             INTEGER PRIMARY KEY AUTOINCREMENT,
  token          TEXT NOT NULL UNIQUE,
  label          TEXT NOT NULL,
  destination_url TEXT NOT NULL,
  providers      TEXT NOT NULL DEFAULT 'google,github', -- comma-separated allowed providers
  enabled        INTEGER NOT NULL DEFAULT 1,
  created_at     TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at     TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_auth_links_token ON auth_links(token);
