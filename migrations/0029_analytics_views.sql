PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS analytics_views (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  base_id INTEGER NOT NULL,
  scope_kind TEXT NOT NULL, -- 'table' | 'store'
  scope_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  config_json TEXT NOT NULL, -- {rows:[],columns:[],values:[{field,agg}],filters:[{field,op,value}],chartType}
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_analytics_views_scope ON analytics_views(scope_kind, scope_id);
