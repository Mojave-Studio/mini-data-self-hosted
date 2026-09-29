PRAGMA foreign_keys = ON;

-- Base ownership: customer_bases gains a nullable owner. NULL = legacy/shared
-- base (visible to all signed-in users, mutable by admins); a set owner means
-- members only see/mutate bases they own while owner/admin roles retain full
-- visibility.
ALTER TABLE customer_bases ADD COLUMN owner_user_id INTEGER REFERENCES users(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_customer_bases_owner_user_id
  ON customer_bases(owner_user_id);
