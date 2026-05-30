PRAGMA foreign_keys = ON;

-- Per-link OAuth credentials for auth_links.
-- When set, these override the global OAuth client ID/secret for that link,
-- enabling fine-grained access control per relay endpoint.
ALTER TABLE auth_links ADD COLUMN google_client_id TEXT;
ALTER TABLE auth_links ADD COLUMN google_client_secret TEXT;
ALTER TABLE auth_links ADD COLUMN github_client_id TEXT;
ALTER TABLE auth_links ADD COLUMN github_client_secret TEXT;
