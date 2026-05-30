-- Calendar events: meetings, emails, calls, texts, notes, tasks
-- linked to contacts from Google Calendar, Cal.com, Calendly, or manual entry
CREATE TABLE IF NOT EXISTS calendar_events (
  id           TEXT    PRIMARY KEY DEFAULT (lower(hex(randomblob(16)))),
  base_id      INTEGER NOT NULL REFERENCES customer_bases(id) ON DELETE CASCADE,
  title        TEXT    NOT NULL,
  description  TEXT,
  event_type   TEXT    NOT NULL DEFAULT 'meeting',
  -- 'meeting' | 'email' | 'call' | 'sms' | 'note' | 'task' | 'other'
  start_at     TEXT,   -- ISO 8601 datetime string
  end_at       TEXT,   -- ISO 8601 datetime string
  location     TEXT,
  provider     TEXT,   -- 'google_calendar' | 'cal' | 'calendly' | 'manual'
  external_id  TEXT,   -- provider's event/booking ID
  external_url TEXT,   -- deeplink back to provider event
  status       TEXT    NOT NULL DEFAULT 'confirmed',
  -- 'confirmed' | 'tentative' | 'cancelled'
  metadata_json TEXT   NOT NULL DEFAULT '{}',
  created_at   TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at   TEXT    NOT NULL DEFAULT (datetime('now'))
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_calendar_events_ext
  ON calendar_events(base_id, provider, external_id)
  WHERE external_id IS NOT NULL AND provider IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_calendar_events_base_start
  ON calendar_events(base_id, start_at);

-- Many-to-many: contacts linked to a calendar event
CREATE TABLE IF NOT EXISTS calendar_event_contacts (
  event_id   TEXT    NOT NULL REFERENCES calendar_events(id) ON DELETE CASCADE,
  contact_id INTEGER NOT NULL REFERENCES contacts(id)        ON DELETE CASCADE,
  role       TEXT    NOT NULL DEFAULT 'attendee',
  -- 'organizer' | 'attendee' | 'cc'
  created_at TEXT    NOT NULL DEFAULT (datetime('now')),
  PRIMARY KEY (event_id, contact_id)
);

CREATE INDEX IF NOT EXISTS idx_cec_contact
  ON calendar_event_contacts(contact_id);
