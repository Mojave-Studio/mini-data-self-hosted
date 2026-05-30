-- Add a token column to service_connections for inbound MCP URL generation.
-- The token is used to build the URL: {origin}/MCP/{token}
ALTER TABLE service_connections ADD COLUMN token TEXT;

CREATE UNIQUE INDEX IF NOT EXISTS idx_service_connections_token
  ON service_connections(token)
  WHERE token IS NOT NULL;
