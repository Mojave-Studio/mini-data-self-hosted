PRAGMA foreign_keys = ON;

DELETE FROM customer_bases
WHERE name IN (
  'Web Design Clients',
  'Online Shop Customers',
  'Framer CRM',
  'CRM'
);
