PRAGMA foreign_keys = ON;

-- Global application settings stored in the database.
-- These supplement or override Worker environment variables.
CREATE TABLE IF NOT EXISTS app_settings (
  key        TEXT PRIMARY KEY,
  value      TEXT NOT NULL,
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
