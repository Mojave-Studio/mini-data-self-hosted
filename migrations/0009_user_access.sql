PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS user_access (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL UNIQUE,
  role TEXT NOT NULL DEFAULT 'member',
  can_manage_users INTEGER NOT NULL DEFAULT 0,
  can_manage_projects INTEGER NOT NULL DEFAULT 1,
  can_manage_integrations INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_user_access_user_id ON user_access(user_id);
CREATE INDEX IF NOT EXISTS idx_user_access_role ON user_access(role);

-- Ensure there is always at least one owner-capable user.
INSERT INTO user_access (user_id, role, can_manage_users, can_manage_projects, can_manage_integrations)
SELECT u.id, 'owner', 1, 1, 1
FROM users u
WHERE u.id = (SELECT MIN(id) FROM users)
  AND NOT EXISTS (SELECT 1 FROM user_access ua WHERE ua.user_id = u.id);

-- Backfill remaining users with member-level access.
INSERT INTO user_access (user_id, role, can_manage_users, can_manage_projects, can_manage_integrations)
SELECT u.id, 'member', 0, 1, 1
FROM users u
WHERE NOT EXISTS (SELECT 1 FROM user_access ua WHERE ua.user_id = u.id);
