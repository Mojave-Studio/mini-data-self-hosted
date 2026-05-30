PRAGMA foreign_keys = ON;

-- v1 unified org model (maps existing customer_bases)
CREATE TABLE IF NOT EXISTS orgs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  legacy_base_id INTEGER UNIQUE,
  name TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active',
  metadata_json TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (legacy_base_id) REFERENCES customer_bases(id) ON DELETE SET NULL
);

INSERT OR IGNORE INTO orgs (legacy_base_id, name)
SELECT id, name
FROM customer_bases;

CREATE INDEX IF NOT EXISTS idx_orgs_legacy_base_id ON orgs(legacy_base_id);

-- Unified identity layer for people/org entities
CREATE TABLE IF NOT EXISTS actors (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  org_id INTEGER NOT NULL,
  actor_type TEXT NOT NULL DEFAULT 'person', -- person|organization
  display_name TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active',
  metadata_json TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (org_id) REFERENCES orgs(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_actors_org_id ON actors(org_id);
CREATE INDEX IF NOT EXISTS idx_actors_org_type ON actors(org_id, actor_type);

CREATE TABLE IF NOT EXISTS actor_identifiers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  actor_id INTEGER NOT NULL,
  org_id INTEGER NOT NULL,
  id_type TEXT NOT NULL, -- email|phone|external|crm_key
  id_value TEXT NOT NULL,
  is_primary INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (actor_id) REFERENCES actors(id) ON DELETE CASCADE,
  FOREIGN KEY (org_id) REFERENCES orgs(id) ON DELETE CASCADE,
  UNIQUE (org_id, id_type, id_value)
);

CREATE INDEX IF NOT EXISTS idx_actor_identifiers_actor_id ON actor_identifiers(actor_id);

-- Shared timeline across all modules
CREATE TABLE IF NOT EXISTS activities (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  org_id INTEGER NOT NULL,
  actor_id INTEGER,
  module_key TEXT NOT NULL, -- core|sales|donations|vector|custom
  event_type TEXT NOT NULL,
  event_ref_table TEXT,
  event_ref_id INTEGER,
  payload_json TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (org_id) REFERENCES orgs(id) ON DELETE CASCADE,
  FOREIGN KEY (actor_id) REFERENCES actors(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_activities_org_id ON activities(org_id);
CREATE INDEX IF NOT EXISTS idx_activities_org_actor ON activities(org_id, actor_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_activities_module ON activities(org_id, module_key, created_at DESC);

-- File metadata registry; object bytes remain in R2
CREATE TABLE IF NOT EXISTS files (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  org_id INTEGER NOT NULL,
  actor_id INTEGER,
  owner_module TEXT NOT NULL DEFAULT 'core',
  bucket_key TEXT NOT NULL,
  original_name TEXT,
  content_type TEXT,
  size_bytes INTEGER,
  checksum_sha256 TEXT,
  metadata_json TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (org_id) REFERENCES orgs(id) ON DELETE CASCADE,
  FOREIGN KEY (actor_id) REFERENCES actors(id) ON DELETE SET NULL,
  UNIQUE (org_id, bucket_key)
);

CREATE INDEX IF NOT EXISTS idx_files_org_id ON files(org_id);
CREATE INDEX IF NOT EXISTS idx_files_actor_id ON files(actor_id);

-- Cross-module index for unified context retrieval
CREATE TABLE IF NOT EXISTS module_records (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  org_id INTEGER NOT NULL,
  module_key TEXT NOT NULL, -- sales|donations|vector|custom
  record_table TEXT NOT NULL,
  record_id INTEGER NOT NULL,
  primary_actor_id INTEGER,
  summary_json TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (org_id) REFERENCES orgs(id) ON DELETE CASCADE,
  FOREIGN KEY (primary_actor_id) REFERENCES actors(id) ON DELETE SET NULL,
  UNIQUE (org_id, module_key, record_table, record_id)
);

CREATE INDEX IF NOT EXISTS idx_module_records_org_module ON module_records(org_id, module_key, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_module_records_actor ON module_records(org_id, primary_actor_id, created_at DESC);

-- Managed schema registry for module-typed data
CREATE TABLE IF NOT EXISTS managed_schemas (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  org_id INTEGER NOT NULL,
  module_key TEXT NOT NULL,
  schema_key TEXT NOT NULL,
  current_version INTEGER NOT NULL DEFAULT 1,
  validation_mode TEXT NOT NULL DEFAULT 'strict', -- strict|warn
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (org_id) REFERENCES orgs(id) ON DELETE CASCADE,
  UNIQUE (org_id, module_key, schema_key)
);

CREATE TABLE IF NOT EXISTS managed_schema_versions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  managed_schema_id INTEGER NOT NULL,
  version INTEGER NOT NULL,
  schema_json TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (managed_schema_id) REFERENCES managed_schemas(id) ON DELETE CASCADE,
  UNIQUE (managed_schema_id, version)
);

CREATE INDEX IF NOT EXISTS idx_managed_schemas_org_module ON managed_schemas(org_id, module_key);

-- Sales module
CREATE TABLE IF NOT EXISTS sales_opportunities (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  org_id INTEGER NOT NULL,
  owner_actor_id INTEGER,
  title TEXT NOT NULL,
  stage TEXT NOT NULL DEFAULT 'new',
  amount_cents INTEGER,
  currency TEXT NOT NULL DEFAULT 'USD',
  close_date TEXT,
  metadata_json TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (org_id) REFERENCES orgs(id) ON DELETE CASCADE,
  FOREIGN KEY (owner_actor_id) REFERENCES actors(id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_sales_opportunities_org_id ON sales_opportunities(org_id);
CREATE INDEX IF NOT EXISTS idx_sales_opportunities_stage ON sales_opportunities(org_id, stage);

CREATE TABLE IF NOT EXISTS sales_opportunity_contacts (
  opportunity_id INTEGER NOT NULL,
  actor_id INTEGER NOT NULL,
  role TEXT NOT NULL DEFAULT 'contact',
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  PRIMARY KEY (opportunity_id, actor_id),
  FOREIGN KEY (opportunity_id) REFERENCES sales_opportunities(id) ON DELETE CASCADE,
  FOREIGN KEY (actor_id) REFERENCES actors(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_sales_opportunity_contacts_actor ON sales_opportunity_contacts(actor_id);

-- Donations module
CREATE TABLE IF NOT EXISTS donation_campaigns (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  org_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  goal_cents INTEGER,
  currency TEXT NOT NULL DEFAULT 'USD',
  status TEXT NOT NULL DEFAULT 'active',
  starts_at TEXT,
  ends_at TEXT,
  metadata_json TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (org_id) REFERENCES orgs(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_donation_campaigns_org_id ON donation_campaigns(org_id);

CREATE TABLE IF NOT EXISTS donations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  org_id INTEGER NOT NULL,
  actor_id INTEGER,
  campaign_id INTEGER,
  amount_cents INTEGER NOT NULL,
  currency TEXT NOT NULL DEFAULT 'USD',
  donated_at TEXT NOT NULL DEFAULT (datetime('now')),
  source TEXT NOT NULL DEFAULT 'manual',
  external_id TEXT,
  metadata_json TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (org_id) REFERENCES orgs(id) ON DELETE CASCADE,
  FOREIGN KEY (actor_id) REFERENCES actors(id) ON DELETE SET NULL,
  FOREIGN KEY (campaign_id) REFERENCES donation_campaigns(id) ON DELETE SET NULL,
  UNIQUE (org_id, source, external_id)
);

CREATE INDEX IF NOT EXISTS idx_donations_org_id ON donations(org_id);
CREATE INDEX IF NOT EXISTS idx_donations_actor_id ON donations(org_id, actor_id, donated_at DESC);

-- Vector module v2 metadata layer (provider-agnostic)
CREATE TABLE IF NOT EXISTS vector_stores (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  org_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  provider TEXT NOT NULL DEFAULT 'zilliz',
  dimensions INTEGER NOT NULL DEFAULT 1536,
  metric TEXT NOT NULL DEFAULT 'cosine',
  provider_config_json TEXT,
  metadata_json TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (org_id) REFERENCES orgs(id) ON DELETE CASCADE,
  UNIQUE (org_id, name)
);

CREATE INDEX IF NOT EXISTS idx_vector_stores_org_id ON vector_stores(org_id);

CREATE TABLE IF NOT EXISTS vector_documents (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  org_id INTEGER NOT NULL,
  store_id INTEGER NOT NULL,
  actor_id INTEGER,
  source_file_id INTEGER,
  external_doc_id TEXT,
  title TEXT,
  metadata_json TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (org_id) REFERENCES orgs(id) ON DELETE CASCADE,
  FOREIGN KEY (store_id) REFERENCES vector_stores(id) ON DELETE CASCADE,
  FOREIGN KEY (actor_id) REFERENCES actors(id) ON DELETE SET NULL,
  FOREIGN KEY (source_file_id) REFERENCES files(id) ON DELETE SET NULL,
  UNIQUE (store_id, external_doc_id)
);

CREATE INDEX IF NOT EXISTS idx_vector_documents_org_store ON vector_documents(org_id, store_id);

CREATE TABLE IF NOT EXISTS vector_chunks_v2 (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  org_id INTEGER NOT NULL,
  store_id INTEGER NOT NULL,
  document_id INTEGER,
  chunk_key TEXT NOT NULL,
  content TEXT NOT NULL,
  embedding_ref TEXT,
  metadata_json TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (org_id) REFERENCES orgs(id) ON DELETE CASCADE,
  FOREIGN KEY (store_id) REFERENCES vector_stores(id) ON DELETE CASCADE,
  FOREIGN KEY (document_id) REFERENCES vector_documents(id) ON DELETE SET NULL,
  UNIQUE (store_id, chunk_key)
);

CREATE INDEX IF NOT EXISTS idx_vector_chunks_v2_org_store ON vector_chunks_v2(org_id, store_id);
CREATE INDEX IF NOT EXISTS idx_vector_chunks_v2_doc ON vector_chunks_v2(document_id);
