-- Add link_rule_json to table_columns for logic-based table linking (no FK enforcement)
-- link_rule_json stores a JSON object like:
--   { "target_table_slug": "clients", "match_column": "email", "display_columns": ["name","status"] }
-- Values in these columns are plain stored values; resolution is done at query time.

ALTER TABLE table_columns ADD COLUMN link_rule_json TEXT;
ALTER TABLE table_columns ADD COLUMN col_metadata_json TEXT;
