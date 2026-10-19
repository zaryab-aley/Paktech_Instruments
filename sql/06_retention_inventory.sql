-- Inventory only. No object or file deletion is performed.
SELECT s.name AS schema_name, t.name AS external_table_name,
       t.create_date, e.location AS storage_location,
       CASE WHEN EXISTS (SELECT 1 FROM sys.sql_expression_dependencies d
                         WHERE d.referenced_id = t.object_id)
            THEN 'Referenced - keep' ELSE 'Unreferenced - review' END AS retention_status
FROM sys.external_tables e JOIN sys.tables t ON t.object_id=e.object_id
JOIN sys.schemas s ON s.schema_id=t.schema_id
WHERE s.name='dbo' ORDER BY t.create_date DESC,t.name;
-- Unreferenced does not mean safe to delete: keep verified rollback runs and
-- check for direct consumers. Metadata does not reveal external/dynamic consumers.
