-- Backfill MCP connection tokens for rows created before 0021_mcp_token.sql existed.
-- Existing rows can safely receive a generated token so the inbound MCP URL works.
UPDATE service_connections
SET token = lower(hex(randomblob(16)))
WHERE kind = 'mcp'
  AND (token IS NULL OR trim(token) = '');
