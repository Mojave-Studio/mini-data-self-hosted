PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS table_definitions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  base_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  slug TEXT NOT NULL,
  description TEXT,
  version INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (base_id, slug),
  FOREIGN KEY (base_id) REFERENCES customer_bases(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS table_columns (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  table_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  slug TEXT NOT NULL,
  data_type TEXT NOT NULL,
  is_nullable INTEGER NOT NULL DEFAULT 1,
  is_unique INTEGER NOT NULL DEFAULT 0,
  default_json TEXT,
  is_computed INTEGER NOT NULL DEFAULT 0,
  formula_expr TEXT,
  formula_deps_json TEXT,
  ref_table_id INTEGER,
  ref_column_id INTEGER,
  on_delete_policy TEXT NOT NULL DEFAULT 'restrict',
  position INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (table_id, slug),
  FOREIGN KEY (table_id) REFERENCES table_definitions(id) ON DELETE CASCADE,
  FOREIGN KEY (ref_table_id) REFERENCES table_definitions(id) ON DELETE SET NULL,
  FOREIGN KEY (ref_column_id) REFERENCES table_columns(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS table_rows (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  table_id INTEGER NOT NULL,
  row_key TEXT NOT NULL,
  source TEXT NOT NULL DEFAULT 'manual',
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (table_id, row_key),
  FOREIGN KEY (table_id) REFERENCES table_definitions(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS table_cells (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  row_id INTEGER NOT NULL,
  column_id INTEGER NOT NULL,
  value_json TEXT,
  value_type TEXT,
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (row_id, column_id),
  FOREIGN KEY (row_id) REFERENCES table_rows(id) ON DELETE CASCADE,
  FOREIGN KEY (column_id) REFERENCES table_columns(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS table_events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  base_id INTEGER NOT NULL,
  table_id INTEGER NOT NULL,
  row_id INTEGER,
  event_type TEXT NOT NULL,
  payload_json TEXT,
  status TEXT NOT NULL DEFAULT 'queued',
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (base_id) REFERENCES customer_bases(id) ON DELETE CASCADE,
  FOREIGN KEY (table_id) REFERENCES table_definitions(id) ON DELETE CASCADE,
  FOREIGN KEY (row_id) REFERENCES table_rows(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS service_connections (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  base_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  kind TEXT NOT NULL,
  provider_key TEXT NOT NULL,
  config_json TEXT,
  enabled INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (base_id) REFERENCES customer_bases(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS service_subscriptions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  connection_id INTEGER NOT NULL,
  event_type TEXT NOT NULL,
  table_id INTEGER,
  filter_expr TEXT,
  enabled INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (connection_id) REFERENCES service_connections(id) ON DELETE CASCADE,
  FOREIGN KEY (table_id) REFERENCES table_definitions(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS delivery_attempts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  event_id INTEGER NOT NULL,
  connection_id INTEGER NOT NULL,
  attempt_no INTEGER NOT NULL DEFAULT 1,
  status TEXT NOT NULL,
  response_code INTEGER,
  response_body TEXT,
  next_retry_at TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (event_id) REFERENCES table_events(id) ON DELETE CASCADE,
  FOREIGN KEY (connection_id) REFERENCES service_connections(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_table_definitions_base ON table_definitions(base_id);
CREATE INDEX IF NOT EXISTS idx_table_columns_table ON table_columns(table_id, position);
CREATE INDEX IF NOT EXISTS idx_table_rows_table ON table_rows(table_id, id);
CREATE INDEX IF NOT EXISTS idx_table_cells_row ON table_cells(row_id);
CREATE INDEX IF NOT EXISTS idx_table_cells_column ON table_cells(column_id);
CREATE INDEX IF NOT EXISTS idx_table_events_base ON table_events(base_id, created_at);
CREATE INDEX IF NOT EXISTS idx_service_connections_base ON service_connections(base_id, enabled);
CREATE INDEX IF NOT EXISTS idx_service_subscriptions_connection ON service_subscriptions(connection_id, enabled);
