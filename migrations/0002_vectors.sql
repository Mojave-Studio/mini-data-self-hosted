PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS vector_collections (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  dim INTEGER NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE TABLE IF NOT EXISTS vector_chunks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  collection_id INTEGER NOT NULL,
  chunk_id TEXT NOT NULL,
  content TEXT NOT NULL,
  embedding_json TEXT NOT NULL,
  metadata_json TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (collection_id) REFERENCES vector_collections(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_vector_chunks_collection ON vector_chunks(collection_id);
CREATE INDEX IF NOT EXISTS idx_vector_chunks_chunk ON vector_chunks(collection_id, chunk_id);
