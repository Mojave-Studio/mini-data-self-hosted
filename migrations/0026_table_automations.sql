PRAGMA foreign_keys = ON;

-- Monday-style board automations: When [trigger] → Then [action]
CREATE TABLE IF NOT EXISTS table_automations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  base_id INTEGER NOT NULL,
  table_id INTEGER,
  name TEXT NOT NULL,
  enabled INTEGER NOT NULL DEFAULT 1,
  trigger_type TEXT NOT NULL,
  trigger_config_json TEXT NOT NULL DEFAULT '{}',
  conditions_json TEXT NOT NULL DEFAULT '[]',
  actions_json TEXT NOT NULL DEFAULT '[]',
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (base_id) REFERENCES customer_bases(id) ON DELETE CASCADE,
  FOREIGN KEY (table_id) REFERENCES table_definitions(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_table_automations_base ON table_automations(base_id, enabled);
CREATE INDEX IF NOT EXISTS idx_table_automations_table ON table_automations(table_id, enabled);

CREATE TABLE IF NOT EXISTS automation_notifications (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  base_id INTEGER NOT NULL,
  automation_id INTEGER,
  table_id INTEGER,
  row_id INTEGER,
  message TEXT NOT NULL,
  payload_json TEXT,
  read INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (base_id) REFERENCES customer_bases(id) ON DELETE CASCADE,
  FOREIGN KEY (automation_id) REFERENCES table_automations(id) ON DELETE SET NULL,
  FOREIGN KEY (table_id) REFERENCES table_definitions(id) ON DELETE SET NULL,
  FOREIGN KEY (row_id) REFERENCES table_rows(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_automation_notifications_base ON automation_notifications(base_id, read, created_at DESC);

CREATE TABLE IF NOT EXISTS automation_runs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  automation_id INTEGER NOT NULL,
  event_id INTEGER,
  status TEXT NOT NULL,
  detail_json TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (automation_id) REFERENCES table_automations(id) ON DELETE CASCADE,
  FOREIGN KEY (event_id) REFERENCES table_events(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_automation_runs_automation ON automation_runs(automation_id, created_at DESC);
